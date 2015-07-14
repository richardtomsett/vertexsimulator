function [synapsesArr, SS] = modelConnect(CP, NP, SS, TP)

% Create mapping of neuron ID -> neuron group
neuronInGroup = createGroupsFromBoundaries(TP.groupBoundaryIDArr);

if SS.parallelSim
  minDelaySteps = Inf;
  maxDelaySteps = 0;
  % Get loop length for complete pairwise exchange algorithm given number of
  % labs in use
  [cpexLoopTotal, partnerLab] = cpexGetExchangePartners();
  spmd
    p_postLabConnectionCell = cell(numlabs(), 1);
    for iLab = 1:numlabs
      p_postLabConnectionCell{iLab} = cell(TP.N, 3);
    end
    
    p_minDelaySteps = Inf;
    p_maxDelaySteps = 0;
    p_neuronInLab = uint32(find(SS.neuronInLab == labindex()));
    p_neuronInGroup = neuronInGroup(p_neuronInLab);
    p_numNeurons = length(p_neuronInLab);
    p_somaPositionMat = TP.somaPositionMat(p_neuronInLab, :);
    
    p_numSynapses = ...
      calculateNumSynapsesRemaining(CP, TP, p_somaPositionMat, ...
      p_numNeurons, p_neuronInGroup);
    
    if labindex() == 1
      PR = ProgressReporter(p_numNeurons, 5, 'connected ...');
    end
    
    for iPreInLab = 1:p_numNeurons
      iPre = p_neuronInLab(iPreInLab);
      [targetIDs, targetComparts, targetDelays] = ...
        connectNeuronToTargets(TP,NP,CP,SS,iPreInLab,iPre, ...
                               neuronInGroup(iPre),p_numSynapses);
        
      [targetDelaySteps,p_maxDelaySteps,p_minDelaySteps] = ...
        convertDelaysToTimesteps(SS,targetDelays, ...
                                 p_maxDelaySteps,p_minDelaySteps);

      targetLabs = SS.neuronInLab(targetIDs);
      for iLab = 1:numlabs()
        tl = targetLabs == iLab;
        p_postLabConnectionCell{iLab}{iPre, 1} = targetIDs(tl);
        p_postLabConnectionCell{iLab}{iPre, 2} = targetComparts(tl);
        p_postLabConnectionCell{iLab}{iPre, 3} = targetDelaySteps(tl);
      end
      
      if labindex() == 1
        printProgress(PR, iPreInLab);
      end
    end
    
    synapsesArr = ...
      labExchangeSynapses(TP,SS,cpexLoopTotal,partnerLab,p_postLabConnectionCell);
  end % spmd
  
  % get max delay time
  for iLab=1:getNumOpenLabs()
    maxds = p_maxDelaySteps{iLab};
    minds = p_minDelaySteps{iLab};
    maxDelaySteps = max(maxDelaySteps, maxds);
    minDelaySteps = min(minDelaySteps, minds);
  end
  
else %serial
  synapsesArr = cell(TP.N, 3);
  
  minDelaySteps = Inf;
  maxDelaySteps = 0;
  numNeurons = TP.N;
  
  numSynapses = calculateNumSynapsesRemaining(CP, TP, TP.somaPositionMat, ...
                                              numNeurons, neuronInGroup);
  
  PR = ProgressReporter(numNeurons, 5, 'connected ...');
  
  for iPreInLab = 1:numNeurons
    iPre = iPreInLab;
    [targetIDs, targetComparts, targetDelays] = ...
      connectNeuronToTargets(TP,NP,CP,SS,iPreInLab,iPre,neuronInGroup(iPre),numSynapses);
    
    [targetDelaySteps,maxDelaySteps,minDelaySteps] = ...
      convertDelaysToTimesteps(SS,targetDelays,maxDelaySteps,minDelaySteps);

    synapsesArr{iPre, 1} = targetIDs;
    synapsesArr{iPre, 2} = targetComparts;
    synapsesArr{iPre, 3} = targetDelaySteps;
    
    printProgress(PR, iPreInLab);
  end
  
end

if minDelaySteps == Inf
  minDelaySteps = 1;
end
if maxDelaySteps == 0
  maxDelaySteps = 1;
end
SS.maxDelaySteps = maxDelaySteps;
SS.minDelaySteps = minDelaySteps;
