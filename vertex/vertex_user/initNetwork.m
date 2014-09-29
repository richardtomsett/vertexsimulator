function [params, connections, electrodes] = ...
  initNetwork(TP, NP, CP, RS, SS, control)
%INITNETWORK Initialise simulation environment, setup the network and
%calculate constants for extracellular potential simulation.
%
%   [PARAMS, CONNECTIONS, ELECTRODES] = INITNETWORK(TP, NP, CP, RS, SS)
%   sets up the simulation environment according to the simulation settings
%   in the SS structure (including initialising the parallel environment if
%   specified), sets up the neuron groups and positions the neurons in the
%   model space according to the tissue parameters in the TP structure and
%   neuron group parameters in the NP structure array, connects the neurons
%   together into a network according to the connectivity parameters in the
%   CP structure array, and calculates the constants used in the extracellular
%   potential calculation (if the extracellular potential is being
%   simulated). PARAMS is a structure with fields TissueParams,
%   NeuronParams, ConnectionParams, RecordingSettings and
%   SimulationSettings, that will be passed to the RUNSIMULATION function.
%   In serial mode, CONNECTIONS is an N by 3 cell array containing connectivity
%   information, where N is the total number of neurons. The first column
%   of the cell array contains lists of postsynaptic neuron IDs for each
%   presynaptic neuron. The second column contains the corresponding
%   postsynaptic compartment IDs, and the third column contains the
%   corresponding axonal conduction delays, specified in number of
%   simulation timesteps. In parallel mode, CONNECTIONS is a composite
%   containing the connection cell array for the neurons in each lab.
%   In serial mode, ELECTRODES contains an N by E cell array with the
%   constants used in the extracellular potential calculation for each
%   neuron compartment and each electrode in the model. N is the total
%   number of neurons in the model, and E is the number of extracellular
%   electrodes. Each cell contains an array with the relevant constant for
%   each compartment in that neuron for that electrode. In parallel mode,
%   ELECTRODES is a composite containing the electrode cell array for the
%   neurons in each lab. PARAMS, CONNECTIONS and ELECTRODES can then be
%   used as inputs to the RUNSIMULATION function.
%
%   [PARAMS, CONNECTIONS, ELECTRODES] = INITNETWORK(TP, NP, CP, RS, SS, CONTROL)
%   allows you to specify how far through the network initialisation
%   process you want INITNETWORK to go. CONTROL is a structure with three
%   possible, optional fields (if any is omitted, its default value is
%   true).
%   - CONTROL.init is a logical (boolean) value specifying whether to run
%   the initialising functions to setup the simulation environment and
%   position the neurons
%   - CONTROL.connect is a logical (boolean) value specifying whether to
%   generate the connectivity
%   - CONTROL.LFPconsts is a logical (boolean) value specifying whether to
%   generate the LFP simulation constants
%   If CONTROL.connect is false, CONNECTIONS will be returned as an empty
%   cell array. If CONTROL.LFPconsts is false, ELECTRODES will be returned
%   as an empty cell array.

if nargin == 6
  if ~isfield(control, 'init')
    control.init = true;
  end
  if ~isfield(control, 'connect')
    control.connect = true;
  end
  if ~isfield(control, 'LFPconsts')
    control.LFPconsts = true;
  end
else
  control.init = true;
  control.connect = true;
  control.LFPconsts = true;
end

% Check the parameter structures for errors
TP = checkTissueStruct(TP);
NP = checkNeuronStruct(NP);
CP = checkConnectivityStruct(CP);
RS = checkRecordingStruct(RS);
SS = checkSimulationStruct(SS);

if control.init
  % Calculate sampling constants
  [RS, SS] = setupSamplingConstants(RS, SS);
  
  % Setup parallel simulation environment, if necessary
  SS = setupEnvironment(SS);
  setRandomSeed(SS);
  
  % Check if multiSyn.cpp has been compiled and set SS.multiSyn accordingly
  multiSyn = exist(['multiSynapse.' mexext()], 'file');
  SS.multiSyn = multiSyn == 3;
  
  % Calculate number of neurons and set group boundaries
  [SS, TP, NP] = setupGroupBounds(NP, SS, TP);
  
  % Setup the "strip" boundaries
  TP = setupStripBounds(TP);
  
  % Position neurons
  TP = positionNeurons(NP, TP);
  
  % Calculate compartment connectivity probabilities according to positions
  % in layers
  NP = calculateCompartmentConnectionProbabilities(NP, TP);
  
  % Distribute neurons among parallel processes if this is a parallel sim
  if SS.parallelSim
    [SS, TP] = distributeNeurons(SS, TP);
  end
end

if control.connect
  % Generate the connectivity
  [connections, SS] = modelConnect(CP, NP, SS, TP);
else
  connections = {};
end

% If recording the LFP, pre-calculate line-source constants
if control.LFPconsts
  if RS.LFP
    disp('Pre-calculating LFP simulation constants...')
    [dummy, electrodes] = setupLFPConstants(NP, RS, SS, TP);
  else
    electrodes = {};
  end
else
  electrodes = {};
end

% Store the parameters in a single params structure
params.TissueParams = TP;
params.NeuronParams = NP;
params.ConnectionParams = CP;
params.RecordingSettings = RS;
params.SimulationSettings = SS;
disp('Model successfully initialised!');


