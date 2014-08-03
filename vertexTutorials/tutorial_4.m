%% VERTEX TUTORIAL 4
% This tutorial shows how to use pre-generated spike times in a network of
% passive neurons to generate the LFP.

%% Load parameters and run the simulation
% We have set the parameters in the tutorial_4_params.m file. These are the
% same as for the previous tutorial, but we haven't given the neurons any
% information about their dynamics or the model to use.

tutorial_4_params;
RecordingSettings.saveDir = '~/VERTEX_results_tutorial_4/';

%%
% VERTEX has a special type of neuron model for loading pre-computed spike
% times, called loadspiketimes:

NeuronParams(1).neuronModel = 'loadspiketimes';

%%
% This model requires the |spikeTimeFile| parameter to be specified. This
% is the location of the file that sets the spike times for each neuron in
% the group. So first let's create this file.
%
% The format for the spike times is a cell array with one cell per neuron
% in the group. Each cell holds the spike times for that neuron, in ms. For
% illustration we will simply generate random spike times, but you can use
% any method you like to create a particular set of spike times that
% interests you.
%
% First we get the size of the neuron group:

totalSize = (TissueParams.neuronDensity * ...
             TissueParams.X * TissueParams.Y * TissueParams.Z) / 1000^3;
group1Size = NeuronParams(1).modelProportion * totalSize;

%%
% Then we'll populate a cell array of this size with spike times for each
% neuron. We will set the spike times for each neuron to be at 30 ms, 60
% ms, 90 ms etc. plus some random Gaussian jitter:

spikeTimes = cell(group1Size, 1);
baseSpikeTimes = 30:30:480;
jitter = randn(group1Size, length(baseSpikeTimes)) .* 5;
spikeTimesMatrix = bsxfun(@plus, baseSpikeTimes, jitter);
spikeTimesCell = mat2cell(spikeTimesMatrix, ...
                          ones(group1Size,1), length(baseSpikeTimes));

%%
% We'll save this cell array to disk, and specify its location in the
% |NeuronParams(1).spikeTimeFile| field:

save('~/spikeTimesGroup1.mat', 'spikeTimesCell');
NeuronParams(1).spikeTimeFile = '~/spikeTimesGroup1.mat';

%%
% We'll keep the group 2 (basket) cells as AdEx neurons:

NeuronParams(2).neuronModel = 'adex';
NeuronParams(2).V_t = -50;
NeuronParams(2).delta_t = 2;
NeuronParams(2).a = 0.04;
NeuronParams(2).tau_w = 10;
NeuronParams(2).b = 40;
NeuronParams(2).v_reset = -65;
NeuronParams(2).v_cutoff = -45;

%% Initialise and run the simulation
% Now we can initialise and run our simulation, and plot the results:

[params, connections, electrodes] = ...
  initNetwork(TissueParams, NeuronParams, ConnectionParams, ...
              RecordingSettings, SimulationSettings);

runSimulation(params, connections, electrodes);
Results = loadResults(RecordingSettings.saveDir);

rasterParams.colors = {'k', 'm'};
rasterParams.groupBoundaryLines = 'c';
rasterParams.title = 'Tutorial 4 Spike Raster (original)';
rasterParams.xlabel = 'Time (ms)';
rasterParams.ylabel = 'Neuron ID';
rasterParams.figureID = 1;
rasterFigure1 = plotSpikeRaster(Results, rasterParams);

figure(2)
plot(Results.LFP', 'LineWidth', 2)
set(gcf, 'color', 'w');
set(gca, 'FontSize', 16);
title('Tutorial 4: LFP at all electrodes', 'FontSize', 16)
xlabel('Time (ms)', 'FontSize', 16)
ylabel('LFP (mV)', 'FontSize', 16)

%%
% Note that the pyramidal neurons in group one fire randomly at the times
% precalculated in the code above, while the basket interneurons in group
% two are driven to fire by the input from pyramidal cells as well as being
% inhibited by within-group connections. This kind of input pattern to the
% interneurons causes them to fire syncrhonously after a build-up of input
% from the pyramidal cells. In the LFP, this manifests as double troughs:
% the initial trough caused by dendritic excitation onto the pyramidal
% cells from the other pyramidal cells, and the second deeper trough
% resulting from synchronous somatic inhibition from the interneurons. At
% the electrodes positioned above the phase-inversion point, a double peak
% is not so easily apparent without zooming in. The inhibition and
% excitation produce defelctions in the LFP in the same direction because
% of their opposing locations on the dendritic trees of the pyramidal
% neurons.
%
% If you have experienced any problems when trying to run this tutorial,
% or if you have any suggestions for improvements, please email Richard
% Tomsett: r _at_ autap _dot_ se
