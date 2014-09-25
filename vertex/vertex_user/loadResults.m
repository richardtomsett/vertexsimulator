function [Results] = loadResults(saveDir, numRuns)
%LOADRESULTS loads the results of a simulation run.
%   RESULTS = LOADRESULTS(SAVEDIR) loads the simulation results saved by
%   RUNSIMULATION. SAVEDIR is a character array (string) specifying the
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
%   RESULTS = LOADRESULTS(SAVEDIR, NUMRUNS) is for use when you have
%   modified runSimulation() to perform several simulation runs (for example,
%   to keep the variable values from the end of the previous simulation run
%   but change some model parameters). NUMRUNS is the number of simulation
%   runs you performed within your implementation of runSimulation().

if ~strcmpi(saveDir(end), '/')
  saveDir = [saveDir '/'];
end

if nargin == 1
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
numSaves = SS.simulationTime/RS.maxRecTime;
maxRecSamples = RS.maxRecTime * (RS.sampleRate / 1000);
maxRecSteps = RS.maxRecTime / SS.timeStep;
minDelaySteps = SS.minDelaySteps;
simulationSamples = (SS.simulationTime*(RS.sampleRate / 1000));

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
  LFP = zeros(numElectrodes, simulationSamples);
else
  LFP = [];
end

% Create matrix to store loaded v_m
if v_m
  intracellular = zeros(length(RS.v_m), simulationSamples);
  if SS.parallelSim
    intraCount = 0;
    intraIDmap = zeros(length(v_m), 1);
  end
else
  intracellular = [];
end
spikeCell = cell(numSaves*ceil(maxRecSteps / minDelaySteps), 1);

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
    
    % Load LFP
    if v_m
      if SS.parallelSim
        if isfield(RecordingVars, 'intraRecording')
          ir = RecordingVars.intraRecording;
          intracellular(intraCount+1:intraCount+size(ir,1), ...
            sampleCount+1:sampleCount+size(ir, 2)) = ir;
          intraID = find(SS.neuronInLab(v_m) == iLab);
          intraIDmap(intraCount+1:intraCount+size(intraID)) = intraID;
          intraCount = intraCount+size(ir,1);
        end
      else
        ir = RecordingVars.intraRecording;
        intracellular(:, sampleCount+1:sampleCount+size(ir, 2)) = ir;
      end
    end
    if RS.LFP
      lr = RecordingVars.LFPRecording;
      if LFPoffline
        for iGroup = 1:TP.numGroups
          for iElectrode = 1:numElectrodes
            LFP(iElectrode, sampleCount+1:sampleCount+maxRecSamples) = ...
              LFP(iElectrode, sampleCount+1:sampleCount+maxRecSamples) +...
              squeeze(sum(sum( bsxfun(@times, ...
                 lr{iGroup},LineSourceConsts{iLab}{iGroup,iElectrode}))))';
          end
        end
      else
        for iGroup = 1:TP.numGroups
          LFP(:, sampleCount+1:sampleCount+size(lr{iGroup},2)) = ...
            LFP(:, sampleCount+1:sampleCount+size(lr{iGroup},2)) + ...
            (lr{iGroup});
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
if SS.parallelSim && ~isempty(intracellular)
  intracellular(intraIDmap, :) = intracellular;
end
% Store loaded results in cell array to return
Results.spikes = spikes;
Results.LFP = LFP; 
Results.v_m = intracellular;
Results.params.TissueParams = TP;
Results.params.NeuronParams = NP;
Results.params.ConnectionParams = CP;
Results.params.RecordingSettings = RS;
Results.params.SimulationSettings = SS;