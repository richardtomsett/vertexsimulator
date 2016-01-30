%% VERTEX TUTORIAL 8
% In this tutorial we will use VERTEX's neuronDynamics() function to
% investigate the dynamics of individual neuron models prior to network
% simulation. This function simulates the dynamics of a single neuron in
% response to input from one of VERTEX's input current/conductance types so
% that you can check the neuron model's response to this input.

%% Neuron parameters
% As in previous tutorials, we will use the adaptive exponential (AdEx)
% model (Brette & Gerstner 2005), this time with one dendritic compartment.

NeuronParams.neuronModel = 'adex';
NeuronParams.V_t = -50;
NeuronParams.delta_t = 2;
NeuronParams.a = 2;
NeuronParams.tau_w = 75;
NeuronParams.b = 150;
NeuronParams.v_reset = -65;
NeuronParams.v_cutoff = -45;
NeuronParams.numCompartments = 2;
NeuronParams.compartmentParentArr = [0, 1];
NeuronParams.compartmentLengthArr = [30, 350];
NeuronParams.compartmentDiameterArr = [30, 2];
NeuronParams.compartmentXPositionMat = [0, 0; 0, 0];
NeuronParams.compartmentYPositionMat = [0, 0; 0, 0];
NeuronParams.compartmentZPositionMat = [ -30, 0; 0, 350];
NeuronParams.C = 3;
NeuronParams.R_M = 6700;
NeuronParams.R_A = 150;
NeuronParams.E_leak = -70;

%%
% We will use a step current input to test out the dynamics of this neuron
% model. The parameters of the step current are amplitude in picoAmps,
% timeOn - the time the current is switched on in ms, and timeOff - the
% time the current is switched off in ms. Here we use an array for the
% amplitude parameter. neuronDynamics simulates one neuron per input value
% so that multiple input values can be tested simultaneously.

NeuronParams.Input.inputType = 'i_step';
NeuronParams.Input.amplitude = [150; 200; 250; 300; 350];
NeuronParams.Input.timeOn = 50;
NeuronParams.Input.timeOff = 350;
NeuronParams.Input.compartmentsInput = 1;

%% Extra parameters
% We need to create another parameter struct to tell neuronDynamics the
% simulation time step to use and how long to run the simulation for:

SimulationParams.timeStep = 0.03125;
SimulationParams.simulationTime = 400;

%% Run the simulation
% We are now ready to run the simulation...
[v_m, I_input] = neuronDynamics(NeuronParams, SimulationParams);

%% Plot the results
% ... and plot the results. Note that v_m and I_input are 3-dimensional
% matrices. The first dimension holds the individual neurons, the second
% dimension the neuron compartments, and the third dimension the
% samplesbover time. So to plot the soma membrane potentials of all the
% neurons, we can do:

step = SimulationParams.timeStep;
time = step:step:SimulationParams.simulationTime;
figure(1);
plot(time, squeeze(v_m(:,1,:))', 'linewidth', 2);
set(gca, 'FontSize', 16);
title('Tutorial 8: neuronDynamics()', 'FontSize', 16)
ylabel('Membrane potential (mV)', 'FontSize', 16)
xlabel('Time (ms)', 'FontSize', 16)
axis([0 SimulationParams.simulationTime -85 -40]);
set(gcf, 'color', 'w');

%%
% To plot the dendrite (2nd) compartment membrane potentials of neurons 1:3
% along with the soma input currents, we can do:
figure(2);
subplot(211);
plot(time, squeeze(v_m(1:3,2,:))', 'linewidth', 2);
set(gca, 'FontSize', 16);
title('Tutorial 8: neuronDynamics()', 'FontSize', 16)
ylabel('Membrane potential (mV)', 'FontSize', 16)
xlabel('Time (ms)', 'FontSize', 16)
axis([0 SimulationParams.simulationTime -85 -40]);

subplot(212);
plot(time, squeeze(I_input(1:3,1,:))', 'linewidth', 2);
set(gca, 'FontSize', 16);
ylabel('Input current (pA)', 'FontSize', 16)
axis([0 SimulationParams.simulationTime -10 380]);
set(gcf, 'color', 'w');

%%
% If you have experienced any problems when trying to run this tutorial,
% or if you have any suggestions for improvements, please email Richard
% Tomsett: r _at_ autap _dot_ se