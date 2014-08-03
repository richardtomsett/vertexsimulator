%% VERTEX TUTORIAL 7
% In this tutorial we will use some of VERTEX's visualisation functions to
% inspect the network that we generate. We're going to use the same model
% as in tutorial 5: 6 neuron groups (3 excitatory and 3 inhibitory)
% arranged into 3 layers (though this time, as we aren't going to simulate
% dynamics, we have set |SimulationSettings.LFP| to |false| so that VERTEX
% doesn't calculate line-source constants during initialisation).

%% Model parameters
% We have stored the parameters for this model in a Matlab script called
% tutorial_7_params.m, so first we will load this script:

tutorial_7_params;

%% Viewing the neuron morphologies
% VERTEX includes a function to plot a basic visualisation of the neuron
% morphologies specified in the neuron parameter structure. This is useful
% to check if you have made any mistakes when specifying your neuron's
% mophology. The function is called |viewMorphology()|, and we give it as
% input the neuron structure that we want to plot. So to plot the shape of
% neurons in group 1, we do:

viewMorphology(NeuronParams(1));

%%
% |viewMorphology()| returns a figure handle in case you want to access
% the figure later on:

neuron2Plot = viewMorphology(NeuronParams(2));

%%
% The plots are 3D, so you can spin and rotate them to check the morphology
% is correct.

%% Generate the network
% Having checked our neuron morphologies, we are ready to generate our
% network:

[params, connections, electrodes] = ...
  initNetwork(TissueParams, NeuronParams, ConnectionParams, ...
              RecordingSettings, SimulationSettings);
            
%% Plotting neuron positions
% Now we've initialised the model, we want to check that VERTEX has
% positioned our neuron groups correctly. We can plot the locations of the
% neurons' somas using the |plotSomaPositions()| function:

plotSomaPositions(params.TissueParams);

%%
% This plot isn't very helpful at all: it's too dense and we can't identify
% neurons in different groups! |plotSomaPositions()| can take a second
% input, which is a structure specifying some options for the plot.

N = params.TissueParams.N;
pars.toPlot = N/400:N/400:N;
pars.markers = {'^', 'o', '^', 'o', '^', 'o'};
pars.colors = {'m', 'k', ...
               [.7, 0, .7], [.35, .35, .35], ...
               [.4, 0, .4], [.7, .7, .7]};
pars.figureID = 4;

%%
% |toPlot| lists the IDs of the neurons we want to plot. Here we are going
% to plot a subset of 400 neurons, covering all the neuron groups.
% |markers| tells |plotSomaPositions()| which marker types to use for each
% neuron group. We're going to plot pyramidal cell somas as triangles and
% interneuron cell somas as circles. |colors| lists the colours to use to
% plot the neuron groups in; we have used different colours for each so we
% can distinguish between them more easily. Finally, |figureID| sets the
% figure number. Let's now call |plotSomaPositions()| again, this time
% storing the figure handle it returns:

somaPlot = plotSomaPositions(params.TissueParams, pars);

%%
% This plot reveals that the neuron groups are positioned in their correct
% layers in the model. It is also a 3D plot so you can rotate and view it
% from any angle.

%% Analysing connectivity
% Finally we would like to know about the connectivity in the model. VERTEX
% provides two functions to help with this. The first is
% |getSparseConnectivity()|, which returns a sparse matrix listing every
% neuron's connections (rows are presynaptic neurons, with each row
% containing a list of target neuron IDs):

sparseConnectivity = getSparseConnectivity(params, connections);

%%
% You can use this sparse matrix to calculate further statistics about the
% connectivity in the model. However, it can be quite difficult to
% visualise this data. We therefore also provide the
% |getGroupConnectivity()| function. This returns the total number of
% connections per group, the group convergent connectivity (i.e. how many
% connections, on average, one neuron in the group receives from all
% neurons in all other groups) and the group divergent connectivity (i.e. how
% many connections, on average, one neuron in the group makes to all
% neurons in all other groups).
%
% |getGroupConnectivity()| can either be given a sparse connectivity matrix
% calculated by |getSparseConnectivity()|, or the raw connection data
% calculated by |initNetwork()| (in which case it runs
% |getSparseConnectivity()| first). As we have already calculated the
% sparse connectivity, we will use this as this input:

[total, convergent, divergent] = ...
  getGroupConnectivity(params, sparseConnectivity);

%%
% Note that both of these functions will work in both serial and parallel
% mode.
%
% We can now plot this information however we like; for example as a
% connectivity heat map:

figure;
imagesc(convergent); % plot convergent connectivity
colormap hot;
colorbar('EastOutside');
set(gcf,'color','w');
set(gca,'FontSize',16);
title('Tutorial 7: convergent connectivity', 'FontSize', 16);
xlabel('Presynaptic groups', 'FontSize', 16);
ylabel('Postsynaptic groups', 'FontSize', 16);

%%
% If you have experienced any problems when trying to run this tutorial,
% or if you have any suggestions for improvements, please email Richard
% Tomsett: r _at_ autap _dot_ se