function [] = simulate(TP, NP, SS, RS, IDMap, ...
                       NeuronModel, SynModel, InModel, RecVar, lineSourceModCell, synArr, wArr, synMap)

outputDirectory = RS.saveDir;

nIntSize = 'uint32';
tIntSize = 'uint16';

groupComparts = [NP.numCompartments];

numInGroup = diff(TP.groupBoundaryIDArr);
neuronInGroup = ...
  createGroupsFromBoundaries(TP.groupBoundaryIDArr);
bufferLength = SS.maxDelaySteps;
comCount = SS.minDelaySteps;
% vars to keep track of where we are in recording buffers:
recTimeCounter = 1;
sampleStepCounter = 1;
spikeRecCounter = 1;

% vars to keep track of spikes
S.spikes = zeros(TP.N * SS.minDelaySteps, 1, nIntSize);
S.spikeStep = zeros(TP.N * SS.minDelaySteps, 1, tIntSize);
S.spikeCount = zeros(1, 1, nIntSize);
numSaves = 1;

simulationSteps = round(SS.simulationTime / SS.timeStep);

if isfield(SS,'spikeLoad')
  S.spikeLoad = SS.spikeLoad;
else
  S.spikeLoad = false;
end
          
if S.spikeLoad
  inputDirectory = SS.spikeLoadDir;
  fName = sprintf('%sRecordings%d.mat', inputDirectory, numSaves);
  loadedSpikes = load(fName);
  dataFieldName = fields(loadedSpikes);
end

recordIntra = RecVar.recordIntra;
  
% simulation loop
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
  
  % increment the recording sample counter
  if simStep == RS.samplingSteps(sampleStepCounter)
    recTimeCounter = recTimeCounter + 1;
    sampleStepCounter = sampleStepCounter + 1;
  end
  
  % communicate spikes
  if comCount == 1
    % update neuron event queues
    if ~S.spikeLoad
      if S.spikeCount ~= 0
        allSpike = S.spikes(1:S.spikeCount);
        allSpikeTimes = S.spikeStep(1:S.spikeCount);
      else
        allSpike = zeros(0, nIntSize);
        allSpikeTimes = zeros(0, tIntSize);
      end
    else
      tt = loadedSpikes.(dataFieldName{1}).spikeRecording{spikeRecCounter};
      toKeep = ismember(tt{1}, S.spikeLoad);
      aS = tt{1}(toKeep);
      aST = tt{2}(toKeep);
      if S.spikeCount ~= 0
        allSpike = [aS; S.spikes(1:S.spikeCount)];
        allSpikeTimes = [aST; S.spikeStep(1:S.spikeCount)];
      else
        allSpike = aS;
        allSpikeTimes = aST;
      end
      if isempty(allSpike)
        allSpike = zeros(0, nIntSize);
        allSpikeTimes = zeros(0, tIntSize);
      end
    end
   
    % Record the spikes
    RecVar.spikeRecording{spikeRecCounter} = {allSpike, allSpikeTimes};
    spikeRecCounter = spikeRecCounter + 1;
    
    % Go through spikes and insert events into relevant buffers
    % mat3d(ii+((jj-1)*x)+((kk-1)*y)*x))
    for iSpk = 1:length(allSpike)
      % Get which groups the targets are in
      postInGroup = neuronInGroup(synArr{allSpike(iSpk), 1});
      % Eac
      for iPostGroup = 1:TP.numGroups
        iSpkSynGroup = synMap{iPostGroup}(neuronInGroup(allSpike(iSpk)));
        if ~isempty(SynModel{iPostGroup, iSpkSynGroup})
          % Adjust time indeces according to circular buffer index
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
              uint32(numInGroup(iPostGroup)) + ...
              (uint32(tBufferLoc(inGroup)) - ...
              uint32(1)) .* ...
              uint32(groupComparts(iPostGroup)) .* ...
              uint32(numInGroup(iPostGroup));
            
            bufferIncomingSpikes( ...
              SynModel{iPostGroup, iSpkSynGroup}, ...
              ind, wArr{allSpike(iSpk)}(inGroup));
          end
        end
      end
    end
    
    S.spikeCount = 0;
    comCount = SS.minDelaySteps;
  else
    comCount = comCount - 1;
  end

  % write recorded variables to disk
  if mod(simStep * SS.timeStep, 5) == 0
   disp(num2str(simStep * SS.timeStep));
  end
  if simStep == RS.dataWriteSteps(numSaves)
    recTimeCounter = 1;
    fName = sprintf('%sRecordings%d.mat', outputDirectory, numSaves);
    save(fName, 'RecVar');
    numSaves = numSaves + 1;
    spikeRecCounter = 1;
    
    if S.spikeLoad
      if numSaves <= length(RS.dataWriteSteps)
        fName = sprintf('%sRecordings%d.mat',inputDirectory,numSaves);
        loadedSpikes = load(fName);
        dataFieldName = fields(loadedSpikes);
        disp(size(loadedSpikes.(dataFieldName{1}).spikeRecording));
      end
    end
  end
end % end of simulation time loop
if isfield(RS,'LFPoffline') && RS.LFPoffline
  save(outputDirectory, 'LineSourceConsts.mat', lineSourceModCell);
end