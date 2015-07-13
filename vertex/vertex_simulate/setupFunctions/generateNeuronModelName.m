function modelName = generateNeuronModelName(NP)

if NP.numCompartments == 1
  modelName = ['PointNeuronModel_' lower(NP.neuronModel)];
else
  modelName = ['NeuronModel_' lower(NP.neuronModel)];
end

if strcmp(modelName(end), '_')
  modelName = modelName(1:end-1);
end