function [Results] = loadResults(saveDir, combineLFPs, numRuns)
%LOADRESULTS loads the results of a simulation run.
%   RESULTS = LOADRESULTS(SAVEDIR) loads the simulation results saved by
%   runSimulation(). SAVEDIR is a character array (string) specifying the
%   directory where the simulation results were saved. RESULTS is a
%   structure with several fields that store the loaded results.
%
%   RESULTS.spikes contains the spike times of all neurons in the model in
%   an n by 2 matrix (where n is the total number of spikes from all
%   neurons). Its first column contains the IDs of the neurons that spiked,
%   and its second column contains the corresponding spike times in
%   milliseconds.
%
%   RESULTS.v_m contains the soma membrane potentials of any neurons that
%   were recorded during the simulation run. Each row contains the data for
%   one recorded neuron, and each column is a membrane potential sample.
%
%   RESULTS.LFP contains the simulated local field potentials at each
%   electrode. Each row contains the data for one electrode, and each
%   column contains an extracellular potential sample. If you specified for
%   the LFP to be calculated offline, then the LFP will be calculated by
%   LOADRESULTS from the saved membrane currents of all the neurons. This
%   can take some time, depending on the size of the model and the number
%   of electrodes.
%
%   RESULTS.params is another structure containing the model parameters,
%   including extra values that were calculated by VERTEX during
%   initialisation such as the neuron group boundaries, and the lab index
%   that each neuron was on if running in parallel mode.
%
%   RESULTS = LOADRESULTS(SAVEDIR, COMBINELFPS) also allows you to
%   tell LOADRESULTS whether to combine the LFP due to each group into a
%   total compound LFP (as done by default), or whether to keep the group
%   LFP contributions separate. If COMBINELFPS is set to true, then
%   RESULTS.LFP will be a numGroups x 1 cell array, with each group's
%   (postsynaptic) contribution to the LFP in each cell. The contents of
%   the cells can be summed to get the total LFP.
%
%   RESULTS = LOADRESULTS(SAVEDIR, COMBINELFPS, NUMRUNS) is for use when you have
%   modified runSimulation() to perform several simulation runs (for example,
%   to keep the variable values from the end of the previous simulation run
%   but change some model parameters). NUMRUNS is the number of simulation
%   runs you performed within your implementation of runSimulation().

if ~strcmpi(saveDir(end), '/')
  saveDir = [saveDir '/'];
end

if nargin == 1
  numRuns = 1;
  combineLFPs = true;
elseif nargin == 2
  numRuns = 1;
end

params = load([saveDir 'parameters.mat']);
pFields = fields(params);

% Order of cells in parameterCell:
% TissueParams, NeuronParams, ConnectionParams, RecordingSettings,
% SimulationSettings
TP = params.(pFields{1}){1};
NP = params.(pFields{1}){2};
CP = params.(pFields{1}){3};
RS = params.(pFields{1}){4};
SS = params.(pFields{1}){5};

% Calculate relevant numbers for loading recordings
SS.simulationTime = SS.simulationTime * numRuns;
numSaves = floor(SS.simulationTime/RS.maxRecTime);
maxRecSamples = RS.maxRecSamples;
maxRecSteps = RS.maxRecSteps;
minDelaySteps = SS.minDelaySteps;
simulationSamples = length(RS.samplingSteps); %(SS.simulationTime*(RS.sampleRate / 1000));

if SS.parallelSim
  numLabs = SS.poolSize;
else
  numLabs = 1;
end

% Has v_m been recorded?
if isfield(RS, 'v_m')
  v_m = RS.v_m;
else
  v_m = false;
end

% Has I_syn been recorded?
if isfield(RS, 'I_syn')
  I_syn = RS.I_syn;
else
  I_syn = false;
end

% Are we to calculate the LFP offline?
if isfield(RS, 'LFPoffline') && RS.LFPoffline
  LFPoffline = true;
  LineSourceConsts = cell(numLabs, 1);
  for iLab = 1:numLabs
    if SS.parallelSim
      fName = sprintf('%sLineSourceConsts_%d.mat', saveDir, iLab);
    else
      fName = sprintf('%sLineSourceConsts.mat', saveDir);
    end
    lsc = load(fName);
    ff = fields(lsc);
    LineSourceConsts{iLab} = lsc.(ff{1});
  end
else
  LFPoffline = false;
end

% Create matrix to store loaded LFP
if RS.LFP
  numElectrodes = length(RS.meaXpositions(:));
  if combineLFPs
    LFP = zeros(numElectrodes, simulationSamples);
  else
    LFP = cell(TP.numGroups, 1);
    for iGroup = 1:TP.numGroups
      LFP{iGroup} = zeros(numElectrodes, simulationSamples);
    end
  end
else
  LFP = [];
end

% Create matrix to store loaded v_m
if v_m
  v_m_recording = zeros(length(RS.v_m), simulationSamples);
  if SS.parallelSim
    intraCount = 0;
    intraIDmap = zeros(length(v_m), 1);
  end
else
  v_m_recording = [];
end
spikeCell = cell(numSaves*ceil(maxRecSteps / minDelaySteps), 1);

% Create matrix to store loaded I_syn
if I_syn
  I_syn_recording = cell(TP.numGroups, 1);
  for iGroup=1:TP.numGroups
    I_syn_recording{iGroup} = zeros(length(RS.I_syn), simulationSamples);
  end
  if SS.parallelSim
    I_synCount = 0;
    I_synIDmap = zeros(length(I_syn), 1);
  end
else
  I_syn_recording = [];
end

sampleCount = 0;

% Load each save file in turn and store in the relevant matrices
numSpikeTransmissions = 0;
for iSaves = 1:numSaves
  for iLab = 1:numLabs
    if SS.parallelSim
      fName = sprintf('%sRecordings%d_%d.mat', saveDir, iSaves, iLab);
    else
      fName = sprintf('%sRecordings%d', saveDir, iSaves);
    end
    
    loadedData = load(fName);
    ff = fields(loadedData);
    RecordingVars = loadedData.(ff{1});
    
    % Load
    if v_m
      if SS.parallelSim
        if isfield(RecordingVars, 'intraRecording')
          ir = RecordingVars.intraRecording;
          v_m_recording(intraCount+1:intraCount+size(ir,1), ...
            sampleCount+1:sampleCount+size(ir, 2)) = ir;
          intraID = find(SS.neuronInLab(v_m) == iLab);
          intraIDmap(intraCount+1:intraCount+size(intraID)) = intraID;
          intraCount = intraCount+size(ir,1);
        end
      else
        ir = RecordingVars.intraRecording;
        v_m_recording(:, sampleCount+1:sampleCount+size(ir, 2)) = ir;
      end
    end
    if I_syn
      if SS.parallelSim
        if isfield(RecordingVars, 'I_synRecording')
          i_Syn = RecordingVars.I_synRecording;
          for iGroup = 1:TP.numGroups
            I_syn_recording{iGroup}(I_synCount+1:I_synCount+size(i_Syn,1), ...
              sampleCount+1:sampleCount+size(i_Syn, 3)) = ...
              squeeze(i_Syn(:,iGroup,:));
          end
          I_synID = find(SS.neuronInLab(I_syn) == iLab);
          I_synIDmap(I_synCount+1:I_synCount+size(I_synID)) = I_synID;
          I_synCount = I_synCount+size(i_Syn,1);
        end
      else
        i_Syn = RecordingVars.I_synRecording;
        for iGroup = 1:TP.numGroups
          I_syn_recording{iGroup}(:, sampleCount+1:sampleCount+size(i_Syn, 3)) = ...
            squeeze(i_Syn(:,iGroup,:));
        end
      end
    end
    if RS.LFP
      lr = RecordingVars.LFPRecording;
      if LFPoffline
        for iGroup = 1:TP.numGroups
          for iElec = 1:numElectrodes
            if combineLFPs
            LFP(iElec, sampleCount+1:sampleCount+maxRecSamples) = ...
              LFP(iElec, sampleCount+1:sampleCount+maxRecSamples) +...
              squeeze(sum(sum( bsxfun(@times, ...
                 lr{iGroup},LineSourceConsts{iLab}{iGroup,iElec}))))';
            else
              LFP{iGroup}(iElec, sampleCount+1:sampleCount+maxRecSamples) = ...
                LFP{iGroup}(iElec, sampleCount+1:sampleCount+maxRecSamples) + ...
                squeeze(sum(sum( bsxfun(@times, ...
                 lr{iGroup},LineSourceConsts{iLab}{iGroup,iElec}))))';
            end
          end
        end
      else
        for iGroup = 1:TP.numGroups
          if combineLFPs
            LFP(:, sampleCount+1:sampleCount+size(lr{iGroup},2)) = ...
              LFP(:, sampleCount+1:sampleCount+size(lr{iGroup},2)) + ...
              lr{iGroup};
          else
            LFP{iGroup}(:, sampleCount+1:sampleCount+size(lr{iGroup},2)) = ...
              LFP{iGroup}(:, sampleCount+1:sampleCount+size(lr{iGroup},2)) + ...
              lr{iGroup};
          end
        end
      end 
    end
    
    sr = RecordingVars.spikeRecording;
    for iSpk = 1:size(sr, 1)
      if ~isempty(sr{iSpk})
        d = cell2mat(sr{iSpk}(1, 2));
        d = double(minDelaySteps - d) + ...
          ((iSpk-1) * double(minDelaySteps)) + ...
          ((iSaves-1) * double(maxRecSteps));
        id = double(cell2mat(sr{iSpk}(1, 1)));
      
        spikeCell{iSpk + numSpikeTransmissions} = ...
          [spikeCell{iSpk + numSpikeTransmissions}; ...
          [double(id), double(d).*SS.timeStep]];
      end
    end
  end % numLabs
  numSpikeTransmissions = numSpikeTransmissions + size(sr,1);
  %numSpikeTransmissions = 0;
  sampleCount = sampleCount + maxRecSamples;
  intraCount = 0;
end % numSaves

spikes = cell2mat(spikeCell);
if SS.parallelSim && ~isempty(v_m_recording)
  v_m_recording(intraIDmap, :) = v_m_recording;
end
if SS.parallelSim && ~isempty(I_syn_recording)
  for iGroup = 1:TP.numGroups
    I_syn_recording{iGroup}(I_synIDmap, :) = I_syn_recording{iGroup};
  end
end
% Store loaded results in cell array to return
Results.spikes = spikes;
Results.LFP = LFP; 
Results.v_m = v_m_recording;
Results.I_syn = I_syn_recording;
Results.params.TissueParams = TP;
Results.params.NeuronParams = NP;
Results.params.ConnectionParams = CP;
Results.params.RecordingSettings = RS;
Results.params.SimulationSettings = SS;