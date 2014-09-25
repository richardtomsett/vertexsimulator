function [NeuronModel, SynModel, InModel, numSaves] = ...
  simulateParallel(TP, NP, SS, RS, ...
    IDMap, NeuronModel, SynModel, InModel, RecVar, lineSourceModCell, synArr, wArr, synMap, nsaves)

outputDirectory = RS.saveDir;

nIntSize = 'uint32';
tIntSize = 'uint16';

%excitatory = [NP.isExcitatory];
groupComparts = [NP.numCompartments];

N = TP.N;
numInGroup = TP.numInGroupInLab;
neuronInGroup = createGroupsFromBoundaries(TP.groupBoundaryIDArr);
bufferLength = SS.maxDelaySteps;
simulationSteps = round(SS.simulationTime / SS.timeStep);

if isfield(SS,'spikeLoad')
  S.spikeLoad = SS.spikeLoad;
else
  S.spikeLoad = false;
end
          
if S.spikeLoad
  inputDirectory = SS.spikeLoadDir;
end

[cpexLoopTotal, partnerLab] = cpexGetExchangePartners();

spmd
  recordIntra = RecVar.recordIntra;
  comCount = SS.minDelaySteps;
  % vars to keep track of where we are in recording buffers:

  recTimeCounter = 1;
  sampleStepCounter = 1;
  spikeRecCounter = 1;
  
  % vars to keep track of spikes
  S.spikes = zeros(N * SS.minDelaySteps, 1, nIntSize);
  S.spikeStep = zeros(N * SS.minDelaySteps, 1, tIntSize);
  receivedSpikes = cell(numlabs, 2); 
  S.spikeCount = zeros(1, 1, nIntSize);
  numSaves = 1;
  if nargin == 13
    nsaves = 0;
  end
  
  if S.spikeLoad
    fName = sprintf('%sRecordings%d_.mat', inputDirectory, numSaves);
    loadedSpikes = pload(fName);
  end
  
  % simulation loop
  labBarrier();
  for simStep = 1:simulationSteps
    for iGroup = 1:TP.numGroups
      [NeuronModel, SynModel, InModel] = ...
        groupUpdateSchedule(NP,SS,NeuronModel,SynModel,InModel,iGroup);
      
      S = addGroupSpikesToSpikeList(NeuronModel,IDMap,S,iGroup,comCount);
      
      % store group-collected recorded variables for membrane potential:
      if simStep == RS.samplingSteps(sampleStepCounter)
        if recordIntra
          RecVar = ...
            updateIntraRecording(NeuronModel,RecVar,iGroup,recTimeCounter);
        end
        
        % for LFP:
        if RS.LFP && NP(iGroup).numCompartments ~= 1
          RecVar = ...
            updateLFPRecording(RS,NeuronModel,RecVar,lineSourceModCell,iGroup,recTimeCounter);
        end
      end
    end % for each group
    
    % increment the recording sample pointer
    if simStep == RS.samplingSteps(sampleStepCounter)
      recTimeCounter = recTimeCounter + 1;
      sampleStepCounter = sampleStepCounter + 1;
    end
    
    % communicate spikes
    if comCount == 1
      % update neuron event queues
      % first process own spikes
      if ~S.spikeLoad
        if S.spikeCount ~= 0
          receivedSpikes(labindex(), :) = {S.spikes(1:S.spikeCount), ...
            S.spikeStep(1:S.spikeCount)};
        else
          receivedSpikes(labindex(), :) = {zeros(0, nIntSize), ...
            zeros(0, tIntSize)};
        end
      else
        tt = loadedSpikes.data.spikeRecording{spikeRecCounter};
        toKeep = ismember(tt{1}, S.spikeLoad);
        tt{1} = tt{1}(toKeep);
        tt{2} = tt{2}(toKeep);
        if S.spikeCount ~= 0
          tt{1} = [tt{1}; S.spikes(1:S.spikeCount)];
          tt{2} = [tt{2}; S.spikeStep(1:S.spikeCount)];
        end
        if isempty(tt)
          tt = {zeros(0, nIntSize), zeros(0, tIntSize)};
        end
        receivedSpikes(labindex(), :) = tt;
      end
      
      for iLab = 1:cpexLoopTotal
        if partnerLab(iLab) == -1
          %no partner
        else
          % exchange spikes with partner iLab
            receivedSpikes(partnerLab(iLab), :) = ...
              labSendReceive(partnerLab(iLab), partnerLab(iLab), ...
              receivedSpikes(labindex(), :));
        end
        labBarrier();
      end % for each pairwise exchange
      
      % Record the spikes
      RecVar.spikeRecording{spikeRecCounter} = ...
        receivedSpikes(labindex(), :);
      spikeRecCounter = spikeRecCounter + 1;

      allSpike = cell2mat(receivedSpikes(:, 1));
      allSpikeTimes = cell2mat(receivedSpikes(:, 2));
      
      % Go through spikes and insert events into relevant buffers
      % mat3d(ii+((jj-1)*x)+((kk-1)*y)*x))
      for iSpk = 1:length(allSpike)
        % Get which groups the targets are in
        postInGroup = neuronInGroup(synArr{allSpike(iSpk), 1});
        for iPostGroup = 1:TP.numGroups
          iSpkSynGroup = synMap{iPostGroup}(neuronInGroup(allSpike(iSpk)));
          if ~isempty(SynModel{iPostGroup, iSpkSynGroup})
            tBufferLoc = synArr{allSpike(iSpk), 3} + ...
              SynModel{iPostGroup, iSpkSynGroup}.bufferCount - allSpikeTimes(iSpk);
            tBufferLoc(tBufferLoc > bufferLength) = ...
              tBufferLoc(tBufferLoc > bufferLength) - bufferLength;
            inGroup = postInGroup == iPostGroup;
            if sum(inGroup ~= 0)
              ind = ...
                uint32(IDMap.modelIDToCellIDMap(synArr{allSpike(iSpk), 1}(inGroup), 1)') + ...
                (uint32(synArr{allSpike(iSpk), 2}(inGroup)) - ...
                uint32(1)) .* ...
                uint32(numInGroup(iPostGroup, labindex())) + ...
                (uint32(tBufferLoc(inGroup)) - ...
                uint32(1)) .* ...
                uint32(groupComparts(iPostGroup)) .* ...
                uint32(numInGroup(iPostGroup, labindex()));
              
              bufferIncomingSpikes(SynModel{iPostGroup, iSpkSynGroup}, ind, ...
                wArr{allSpike(iSpk)}(inGroup));
            end
          end
        end
      end
      
      S.spikeCount = 0;
      comCount = SS.minDelaySteps;
    else
      comCount = comCount - 1;
    end
    
    if labindex() == 1 && mod(simStep * SS.timeStep, 5) == 0
      disp(num2str(simStep * SS.timeStep));
    end
    
    % write recorded variables to disk
    if simStep == RS.dataWriteSteps(numSaves)
      recTimeCounter = 1;
      fName = sprintf('Recordings%d_.mat', numSaves+nsaves);
      saveDataSPMD(outputDirectory, fName, RecVar);
      numSaves = numSaves + 1;
      spikeRecCounter = 1;
      
      if S.spikeLoad
        if numSaves <= length(RS.dataWriteSteps)
          fName = sprintf('%sRecordings%d_.mat',inputDirectory,numSaves+nsaves);
          loadedSpikes = pload(fName);
          disp(size(loadedSpikes.data.spikeRecording));
        end
      end
    end
  end % end of simulation time loop
  
  if isfield(RS,'LFPoffline') && RS.LFPoffline
    saveDataSPMD(outputDirectory, 'LineSourceConsts_.mat', lineSourceModCell);
  end
  numSaves = numSaves - 1;
end % spmd