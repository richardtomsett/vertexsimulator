function [NeuronModel, SynModel, InModel] = ...
  groupUpdateSchedule(NP,SS,NeuronModel,SynModel,InModel,iGroup)

% update synaptic conductances/currents according to buffers
for iSyn = 1:size(SynModel, 2)
  if ~isempty(SynModel{iGroup, iSyn})
    updateBuffer(SynModel{iGroup, iSyn});
    updateSynapses(SynModel{iGroup, iSyn}, NeuronModel{iGroup}, SS.timeStep);
  end
end

% update axial currents
if NP(iGroup).numCompartments > 1
  updateI_ax(NeuronModel{iGroup}, NP(iGroup));
end

% update inputs
if ~isempty(InModel)
  for iIn = 1:size(InModel, 2)
    if ~isempty(InModel{iGroup, iIn})
      updateInput(InModel{iGroup, iIn}, NeuronModel{iGroup});
    end
  end
end

% update neuron model variables
if ~isempty(InModel)
  updateNeurons(NeuronModel{iGroup}, InModel(iGroup, :), ...
                NP(iGroup), SynModel(iGroup, :), SS.timeStep);
else
  updateNeurons(NeuronModel{iGroup}, [], ...
                NP(iGroup), SynModel(iGroup, :), SS.timeStep);
end