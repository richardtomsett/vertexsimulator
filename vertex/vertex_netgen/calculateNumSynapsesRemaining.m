function [numSynapses] = ...
  calculateNumSynapsesRemaining(CP, TP, somaPositionMat, number, neuronInGroup)

ratioRemaining = ones(number, TP.numLayers);
numSynapses = zeros(number, TP.numLayers, TP.numGroups, 'uint16');
for iPreGroup = 1:TP.numGroups
  inGroup = neuronInGroup == iPreGroup;
  if CP(iPreGroup).sliceSynapses
    ratioRemaining(inGroup, :) = ...
      calculateArbourProportionRemaining( ...
          somaPositionMat(inGroup, :), TP.X, TP.Y, ...
          CP(iPreGroup).axonArborRadius, CP(iPreGroup).axonArborSpatialModel);
  else
    %ratioRemaining(inGroup, :) = ...
    %  ones(size(TP.somaPositionMat(inGroup, 1), 1), TP.numLayers);
  end
  preC = cell2mat(CP(iPreGroup).numConnectionsToAllFromOne')';
  for iLayer = 1:TP.numLayers
    numSynapses(inGroup, iLayer, :) = ...
      bsxfun(@times, ratioRemaining(inGroup, iLayer), preC(iLayer, :));
  end
end