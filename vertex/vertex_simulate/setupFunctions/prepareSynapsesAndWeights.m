function [synapseArrMod, weightArr] = ...
  prepareSynapsesAndWeights(TP, CP, SS, synapseArr)

neuronInGroup = createGroupsFromBoundaries(TP.groupBoundaryIDArr);

if SS.parallelSim
  spmd
    [synapseArrMod, weightArr] = prep(CP, SS, synapseArr, neuronInGroup);
  end
else
  [synapseArrMod, weightArr] = prep(CP, SS, synapseArr, neuronInGroup);
end


function [synapseArrMod,weightArr] = prep(CP, SS, synapseArr, neuronInGroup)
weightArr = cell(size(synapseArr, 1), 1);
synapseArrMod = synapseArr;
for iN = 1:size(synapseArrMod, 1)
  if ~isempty(synapseArrMod{iN, 1})
    iNeuronGroup = neuronInGroup(iN);
    postGroups = neuronInGroup(synapseArrMod{iN, 1});
    % fill empty weights entries with zeros
    for iW = 1:length(CP(iNeuronGroup).weights)
      if isempty(CP(iNeuronGroup).weights{iW})
        CP(iNeuronGroup).weights{iW} = 0;
      end
    end
    w = cell2mat(CP(iNeuronGroup).weights);
    weights = w(postGroups);

    % if weights are to be randomised, do this here...
    % TO IMPLEMENT
    if SS.multiSyn
      weightArr{iN, 1} = multiSynapse(double(synapseArrMod{iN, 1}), ...
                                      double(synapseArrMod{iN, 2}), weights);
    else
      weightArr{iN, 1} = weights(:)';
    end
    
    toDelete = weightArr{iN, 1} == 0;
    synapseArrMod{iN, 1}(toDelete) = [];
    synapseArrMod{iN, 2}(toDelete) = [];
    synapseArrMod{iN, 3}(toDelete) = [];
    weightArr{iN, 1}(toDelete) = [];
  end
end