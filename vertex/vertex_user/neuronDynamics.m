function [v_m, I, NParams] = neuronDynamics(NeuronParams, pars)
%NEURONDYNAMICS runs a simulation of a single neuron group
%   V_M = neuronDynamics(NEURONPARAMS, PARS) creates a neuron group
%   according to the parameters in the structure NEURONPARAMS.
%   It then runs a simulation for the amount of time specified in the PARS
%   structure. This is useful for testing the dynamics of neuron models in
%   response to arbitrary input currents.
%
%   NEURONPARAMS is a structure containing the parameters defining a neuron
%   group (for details, see the VERTEX tutorials at www.vertexsimulator.org).
%   You should define NEURONPARAMS.Input to create an input current to the
%   neurons. The number of neurons created depends on the number of values
%   set for the input current parameters (Input.meanInput or
%   Input.amplitude - see documentation for the relevant input model).
%
%   PARS is a structure with two fields. PARS.timeStep specifies the
%   simulation timestep in ms, and PARS.simulationTime specifies the total
%   simulation time in ms.
%
%   V_M contains the membrane potentials for the neurons in the group;
%   the first dimension represents the neurons, the second their compartments
%   and the third the time (sampled every PARS.timeStep milliseconds). To
%   get all soma membrane potentials for the whole simulation, for example,
%   you would run: somaPotentials = squeeze(V_M(:, 1, :));
%
%   [V_M, I] = neuronDynamics(NEURONPARAMS, PARS) additionally returns the
%   input currents applied to the neurons, in the same format as the
%   membrane potentials (units of picoAmps).
%
%   [V_M, I, NPARAMS] = neuronDynamics(NEURONPARAMS, PARS) also returns the
%   neuron group parameter structure in NPARAMS. This contains the same
%   values as NEURONPARAMS, in addition to the calculated passive
%   properties of the neurons (axial conductances between compartments,
%   membrane conductances for each compartment etc.).

tp.numGroups = 1;
NParams = calculatePassiveProperties(NeuronParams, tp);

model = lower(NParams.neuronModel);
inputModel = lower(NParams.Input.inputType);

if NParams.numCompartments == 1
  nFunString = ['PointNeuronModel_' model];
else
  nFunString = ['NeuronModel_' model];
end
iFunString = ['InputModel_' inputModel];

if isfield(NParams.Input, 'compartmentsInput')
  comparts = NParams.Input.compartmentsInput;
else
  comparts = 1:NParams.numCompartments;
end

if strcmp(nFunString(end), '_')
  nFunString = nFunString(1:end-1);
end
nConstructor = str2func(nFunString);
iConstructor = str2func(iFunString);

if isfield(NParams.Input, 'meanInput')
  number = size(NParams.Input.meanInput(:), 1);
elseif isfield(NParams.Input, 'amplitude')
  number = size(NParams.Input.amplitude(:), 1);
else
  if strcmpi(NParams.Input.inputType, 'i_step')
    errMsg = ...
      ['The Input structure in the neuron parameter structure is missing a ' ...
     'field: amplitude'];
  else
    errMsg = ...
      ['The Input structure in the neuron parameter structure is missing a ' ...
     'field: meanInput'];
  end
  error('vertex:neuronDynamics:InputMissingField', errMsg);
end

NeuronModel = {nConstructor(NParams, number)};
InputModel = {iConstructor(NParams, 1, number, pars.timeStep, comparts)};

stepsPerms = 1 / pars.timeStep;
if ~( stepsPerms == round(stepsPerms) )
  disp(['Incompatible timeStep supplied: ' num2str(pars.timeStep)]);
  pars.timeStep = 1 / (2^nextpow2(stepsPerms));
  disp(['Setting timeStep to ' num2str(pars.timeStep) ' ms']);
end
simulationSteps = round(pars.simulationTime / pars.timeStep);
v_m = zeros(number, NParams.numCompartments, simulationSteps);
I = zeros(number, NParams.numCompartments, simulationSteps);

for simStep = 1:simulationSteps
  if NParams.numCompartments > 1
    updateI_ax(NeuronModel{1}, NParams);
  end
  updateInput(InputModel{1}, NeuronModel{1});
  updateNeurons(NeuronModel{1}, InputModel, NParams, [], pars.timeStep);
  v_m(:, :, simStep) = NeuronModel{1}.v;
  I(:, :, simStep) = InputModel{1}.I_input;
  if mod(simStep * pars.timeStep, 5) == 0
   disp(num2str(simStep * pars.timeStep));
  end
end