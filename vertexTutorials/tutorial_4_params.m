%% VERTEX TUTORIAL 4 PARAMETERS
% Parameters for Tutorial 3

%% Tissue parameters
TissueParams.X = 2500;
TissueParams.Y = 400;
TissueParams.Z = 200;
TissueParams.neuronDensity = 25000;
TissueParams.numLayers = 1;
TissueParams.layerBoundaryArr = [200, 0];
TissueParams.numStrips = 10;
TissueParams.tissueConductivity = 0.3;
TissueParams.maxZOverlap = [-1 , -1];

%% Neuron parameters
NeuronParams(1).modelProportion = 0.85;
NeuronParams(1).somaLayer = 1;
NeuronParams(1).numCompartments = 8;
NeuronParams(1).compartmentParentArr = [0, 1, 2, 2, 4, 1, 6, 6];
NeuronParams(1).compartmentLengthArr = [13 48 124 145 137 40 143 143];
NeuronParams(1).compartmentDiameterArr = ...
  [29.8, 3.75, 1.91, 2.81, 2.69, 2.62, 1.69, 1.69];
NeuronParams(1).compartmentXPositionMat = ...
[   0,    0;
    0,    0;
    0,  124;
    0,    0;
    0,    0;
    0,    0;
    0, -139;
    0,  139];
NeuronParams(1).compartmentYPositionMat = ...
[   0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0];
NeuronParams(1).compartmentZPositionMat = ...
[ -13,    0;
    0,   48;
   48,   48;
   48,  193;
  193,  330;
  -13,  -53;
  -53, -139;
  -53, -139];
NeuronParams(1).axisAligned = 'z';
NeuronParams(1).C = 1.0*2.96;
NeuronParams(1).R_M = 20000/2.96;
NeuronParams(1).R_A = 150;
NeuronParams(1).E_leak = -70;
NeuronParams(1).somaID = 1;
NeuronParams(1).basalID = [6, 7, 8];
NeuronParams(1).apicalID = [2 3 4 5];

NeuronParams(2).modelProportion = 0.15;
NeuronParams(2).somaLayer = 1;
NeuronParams(2).axisAligned = '';
NeuronParams(2).numCompartments = 7;
NeuronParams(2).compartmentParentArr = [0 1 2 2 1 5 5];
NeuronParams(2).compartmentLengthArr = [10 56 151 151 56 151 151];
NeuronParams(2).compartmentDiameterArr = ...
  [24 1.93 1.95 1.95 1.93 1.95 1.95];
NeuronParams(2).compartmentXPositionMat = ...
[   0,    0;
    0,    0;
    0,  107;
    0, -107; 
    0,    0; 
    0, -107;
    0,  107];
NeuronParams(2).compartmentYPositionMat = ...
[   0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0;
    0,    0];
NeuronParams(2).compartmentZPositionMat = ...
[ -10,    0;
    0,   56;
   56,  163;
   56,  163; 
  -10,  -66;
  -66, -173;
  -66, -173];
NeuronParams(2).C = 1.0*2.93;
NeuronParams(2).R_M = 15000/2.93;
NeuronParams(2).R_A = 150;
NeuronParams(2).E_leak = -70;
NeuronParams(2).dendritesID = [2 3 4 5 6 7];

%% Connectivity parameters
ConnectionParams(1).numConnectionsToAllFromOne{1} = 1700;
ConnectionParams(1).synapseType{1} = 'i_exp';
ConnectionParams(1).targetCompartments{1} = [NeuronParams(1).basalID, ...
                                             NeuronParams(1).apicalID];
ConnectionParams(1).weights{1} = 5;
ConnectionParams(1).tau{1} = 2;
ConnectionParams(1).numConnectionsToAllFromOne{2} = 300;
ConnectionParams(1).synapseType{2} = 'i_exp';
ConnectionParams(1).targetCompartments{2} = NeuronParams(2).dendritesID;
ConnectionParams(1).weights{2} = 10;
ConnectionParams(1).tau{2} = 0.8;
ConnectionParams(1).axonArborSpatialModel = 'gaussian';
ConnectionParams(1).sliceSynapses = true;
ConnectionParams(1).axonArborRadius = 250;
ConnectionParams(1).axonArborLimit = 500;
ConnectionParams(1).axonConductionSpeed = 0.3;
ConnectionParams(1).synapseReleaseDelay = 0.5;

ConnectionParams(2).numConnectionsToAllFromOne{1} = 1000;
ConnectionParams(2).synapseType{1} = 'i_exp';
ConnectionParams(2).targetCompartments{1} = NeuronParams(1).somaID;
ConnectionParams(2).weights{1} = -10;
ConnectionParams(2).tau{1} = 6;
ConnectionParams(2).numConnectionsToAllFromOne{2} = 250;
ConnectionParams(2).synapseType{2} = 'i_exp';
ConnectionParams(2).targetCompartments{2} = NeuronParams(2).dendritesID;
ConnectionParams(2).weights{2} = -10;
ConnectionParams(2).tau{2} = 3;
ConnectionParams(2).axonArborSpatialModel = 'gaussian';
ConnectionParams(2).sliceSynapses = true;
ConnectionParams(2).axonArborRadius = 200;
ConnectionParams(2).axonArborLimit = 500;
ConnectionParams(2).axonConductionSpeed = 0.3;
ConnectionParams(2).synapseReleaseDelay = 0.5;

%% Recording and simulation settings
RecordingSettings.saveDir = '~/VERTEX_results_tutorial_4/';
RecordingSettings.LFP = true;
[meaX, meaY, meaZ] = meshgrid(0:1250:2500, 200, 500:-250:0);
RecordingSettings.meaXpositions = meaX;
RecordingSettings.meaYpositions = meaY;
RecordingSettings.meaZpositions = meaZ;
RecordingSettings.minDistToElectrodeTip = 20;
RecordingSettings.v_m = 250:250:4750;
RecordingSettings.maxRecTime = 100;
RecordingSettings.sampleRate = 1000;

SimulationSettings.simulationTime = 500;
SimulationSettings.timeStep = 0.03125;
SimulationSettings.parallelSim = false;
