%% VERTEX TUTORIAL 2
% In the previous tutorial we looked at a network of 5000 layer 2/3
% pyramidal cells, connected to each other and firing randomly. In this
% tutorial, we will create a more interesting model containing excitatory
% and inhibitory neurons with intrinsic spiking dynamics. We will stimulate
% the neurons using random input currents, resulting in the generation of a
% network oscillation.
% 
%% Tissue parameters
% First we specify the same tissue parameters as in tutorial 1:

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
% Next we will specify the parameters for our two neuron groups. We will
% use the neuron models described in (Tomsett et al. 2014) for layer 2/3
% pyramidal neurons and basket interneurons. We are going to set 85% of the
% neurons to be pyramidal cells, in neuron group 1.

NeuronParams(1).modelProportion = 0.85;
NeuronParams(1).somaLayer = 1;

%%
% We are going to use the adaptive exponential (AdEx) model to generate
% spiking dynamics (Brette & Gerstner 2005). Our models will be different
% from the original AdEx model as they will also contain dendritic
% compartments so that they can generate an extracellular potential. The
% AdEx dynamics are in the soma compartment, while the dendrites are
% passive. The AdEx model requires us to specify some extra parameters that
% control the model dynamics:

NeuronParams(1).neuronModel = 'adex';
NeuronParams(1).V_t = -50;
NeuronParams(1).delta_t = 2;
NeuronParams(1).a = 2.6;
NeuronParams(1).tau_w = 65;
NeuronParams(1).b = 220;
NeuronParams(1).v_reset = -60;
NeuronParams(1).v_cutoff = -45;

%%
% |V_t| is the spike generation threshold (in mV), |delta_t| is the spike
% steepness parameter (in mV), |a| is the scale factor of the spike
% after-hyperpolarisation (AHP) current (in nanoSiemens), |tau_w| is the
% AHP current time constant (in ms), |b| is the instantaneous change in the
% AHP current after a spike (in pA), |v_reset| is the membrane potential
% that the soma compartment is reset to after firing a spike (in mV), and
% |v_cutoff| is the membrane potential at which a spike is detected (in
% mV). We recommend that this parameter is set to |V_t + 5|; if it is set 
% much higher, the exponential term in the AdEx equations can lead to the 
% membrane potentialexploding to a not-a-number (NaN) value, which breaks 
% things.
%
% The remaining parameters defining the structure and passive properties
% are the same as in Tutorial 1:
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

%%
% In order to generate spikes, we need to provide the neurons with some
% input. We set the inputs to our neuron group in another structure array,
% called Inptut, that we create as a field in our NeuronParams(1)
% structure. Input is a structure array rather than just a structure
% so that we can specify multiple different inputs to the neurons in
% multiple Input array elements. For the moment, we're just going to use
% one input type: random currents with a mean value of 330 pA, a standard
% deviation of 90 pA, and a time constant of 2 ms. The type of random
% current we use is an Ornstein Uhlenbeck process, so the input type is set
% to |'i_ou'| (we could also apply our input as a conductance |'g_ou'|, in
% which case we would also need to set an |E_reversal| parameter to set the
% reversal potential).

NeuronParams(1).Input(1).inputType = 'i_ou';
NeuronParams(1).Input(1).meanInput = 330;
NeuronParams(1).Input(1).stdInput = 90;
NeuronParams(1).Input(1).tau = 2;

%%
% Next we set the parameters for the 2nd neuron group, which represent
% basket interneurons. These cells' dendrites are not aligned along a
% particular axis, so we set the |axisAligned| parameters to be empty. We
% set the parameters to give this neuron type fast-spiking behaviour.

NeuronParams(2).modelProportion = 0.15;
NeuronParams(2).somaLayer = 1;
NeuronParams(2).axisAligned = '';
NeuronParams(2).neuronModel = 'adex';
NeuronParams(2).V_t = -50;
NeuronParams(2).delta_t = 2;
NeuronParams(2).a = 0.04;
NeuronParams(2).tau_w = 10;
NeuronParams(2).b = 40;
NeuronParams(2).v_reset = -65;
NeuronParams(2).v_cutoff = -45;
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
NeuronParams(2).Input(1).inputType = 'i_ou';
NeuronParams(2).Input(1).meanInput = 190;
NeuronParams(2).Input(1).tau = 0.8;
NeuronParams(2).Input(1).stdInput = 50;


%% Connectivity parameters
% We set the connectivity parameters in the same way as in tutorial 1, but
% this time we need to specify the parameters for connections between the
% two groups. First we set the parameters for connections from group 1 (the
% pyramidal cells) to itself:

ConnectionParams(1).numConnectionsToAllFromOne{1} = 1700;
ConnectionParams(1).synapseType{1} = 'i_exp';
ConnectionParams(1).targetCompartments{1} = [NeuronParams(1).basalID, ...
                                             NeuronParams(1).apicalID];
ConnectionParams(1).weights{1} = 1;
ConnectionParams(1).tau{1} = 2;

%%
% Then the parameters for connections from group 1 to group 2 (the basket
% interneurons):

ConnectionParams(1).numConnectionsToAllFromOne{2} = 300;
ConnectionParams(1).synapseType{2} = 'i_exp';
ConnectionParams(1).targetCompartments{2} = NeuronParams(2).dendritesID;
ConnectionParams(1).weights{2} = 28;
ConnectionParams(1).tau{2} = 1;

%%
% And then the generic parameters for connections from group 1:

ConnectionParams(1).axonArborSpatialModel = 'gaussian';
ConnectionParams(1).sliceSynapses = true;
ConnectionParams(1).axonArborRadius = 250;
ConnectionParams(1).axonArborLimit = 500;
ConnectionParams(1).axonConductionSpeed = 0.3;
ConnectionParams(1).synapseReleaseDelay = 0.5;

%%
% We repeat this process for connections from group 2:

ConnectionParams(2).numConnectionsToAllFromOne{1} = 1000;
ConnectionParams(2).synapseType{1} = 'i_exp';
ConnectionParams(2).targetCompartments{1} = NeuronParams(1).somaID;
ConnectionParams(2).weights{1} = -5;
ConnectionParams(2).tau{1} = 6;

ConnectionParams(2).numConnectionsToAllFromOne{2} = 200;
ConnectionParams(2).synapseType{2} = 'i_exp';
ConnectionParams(2).targetCompartments{2} = NeuronParams(2).dendritesID;
ConnectionParams(2).weights{2} = -4;
ConnectionParams(2).tau{2} = 3;

ConnectionParams(2).axonArborSpatialModel = 'gaussian';
ConnectionParams(2).sliceSynapses = true;
ConnectionParams(2).axonArborRadius = 200;
ConnectionParams(2).axonArborLimit = 500;
ConnectionParams(2).axonConductionSpeed = 0.3;
ConnectionParams(2).synapseReleaseDelay = 0.5;

%%
% Note that for the weights in |ConnectionParams(2)| we use negative
% values, as basket interneurons are inhibitory. Of course, if we used
% conductance-based synapses instead, then we would use positive weights as
% the inhibitory nature of the synapses would be controlled by the
% synapses' reversal potential.

%% Recording and simulation settings
% We will use the same recording and simulation settings as in the previous
% tutorial. Note that the simulation will take longer to run than in
% tutorial 1, as the AdEx dyamics add complexity to the calculations.

RecordingSettings.saveDir = '~/VERTEX_results_tutorial_2/';
RecordingSettings.LFP = true;
[meaX, meaY, meaZ] = meshgrid(0:1000:2000, 200, 600:-300:0);
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

%% Generate the network
% We generate the network in exactly the same way as in tutorial 1, by
% calling the |initNetwork| function:

[params, connections, electrodes] = ...
  initNetwork(TissueParams, NeuronParams, ConnectionParams, ...
              RecordingSettings, SimulationSettings);

%% Run the simulation
% Now we can run the simulatio, and load the results:

runSimulation(params, connections, electrodes);
Results = loadResults(RecordingSettings.saveDir);

%% Plot the results
% Rather than manually plotting the spike raster, we will make use of
% VERTEX's |plotSpikeRaster| function, which does some automatic
% prettyfication of spike raster plots. |plotSpikeRaster| accepts the
% Results structure we loaded using |loadResults| and a structure of
% parameters that set some properties of the figure. It returns a handle to
% the created figure.
%
% The minimal parameter structure simply contains a cell array of color
% values that set the color of each neuron group:

rasterParams.colors = {'k', 'm'};

%%
% Using these parameters, we obtain the following figure:

rasterFigure = plotSpikeRaster(Results, rasterParams);

%%
% We can add some further fields to the parameter structure for enhanced
% prettiness. |groupBoundaryLines| is a color value, which if set will make
% |plotSpikeRaster| draw separating lines between the neuron groups in this
% color. You can also set a |title|, |xlabel| and |ylabel|. Finally, we can
% specify which Matlab figure number to use. If we don't specify this,
% a new figure window will be opened.

rasterParams.groupBoundaryLines = [0.7, 0.7, 0.7];
rasterParams.title = 'Tutorial 2 Spike Raster';
rasterParams.xlabel = 'Time (ms)';
rasterParams.ylabel = 'Neuron ID';
rasterParams.figureID = 2;

rasterFigureImproved = plotSpikeRaster(Results, rasterParams);

%%
% The spike raster shows a gamma oscillation occurring in the population
% (for details on the mechanism of this oscillation, see Tomsett et al.
% 2014). The precise details of the spiking in your simulation will depend
% on the random number generation, which we did not seed explicitly
% (seeding random numbers in VERTEX is covered in tutorial 5). The
% oscillation can be seen in the LFP:

figure(3)
plot(Results.LFP', 'LineWidth', 2)
set(gcf,'color','w');
set(gca,'FontSize',16)
title('Tutorial 2: LFP at all electrodes', 'FontSize', 16)
xlabel('Time (ms)', 'FontSize', 16)
ylabel('LFP (mV)', 'FontSize', 16)

%%
% Plotting the LFP from all electrodes also reveals a phase inversion,
% which depends on the location of the electrodes in relation to the
% pyramidal neuron somas (Tomsett et al. 2014).
%
% If you have experienced any problems when trying to run this tutorial,
% or if you have any suggestions for improvements, please email Richard
% Tomsett: r _at_ autap _dot_ se
%
%% References
% Tomsett RJ, Ainsworth M, Thiele A, Sanayei M, Chen X et al. (2014)
% Virtual Electrode Recording Tool for EXtracellular potentials (VERTEX):
% comparing multi-electrode recordings from simulated and biological
% mammalian cortical tissue, Brain Structure and Function.
% doi:10.1007/s00429-014-0793-x