function [chosenCompartments] = ...
  chooseCompartments(NP, CP, iPreGroup, iPostGroup, iLayer, synapsesInLayer)

if NP(iPostGroup).numCompartments == 1
  possiblePostCompartments = 1;
else
  possiblePostCompartments = CP(iPreGroup).targetCompartments{iPostGroup};
end

if  NP(iPostGroup).numCompartments == 1
  chosenCompartments = ones(synapsesInLayer, 1);
elseif sum(NP(iPostGroup).proportionCompartmentAreaInLayer( ...
    iLayer, possiblePostCompartments)) ~=0
  compartmentWeights = ...
    NP(iPostGroup).proportionCompartmentAreaInLayer(iLayer,possiblePostCompartments);
  % choose which comparts to connect to on the postsynaptic neurons according to
  % their weights (WITH replacement)
  edges = min([0; cumsum(compartmentWeights(:) ./ sum(compartmentWeights))], 1);
  edges(end) = 1; % get the upper edge exact
  [~, chosenCompartments] = histc(rand(synapsesInLayer, 1), edges);
  chosenCompartments = possiblePostCompartments(chosenCompartments);
else
  % closestCompartmentToLayer is a variable that is set in 
  % calculateCompartmentConnectionProbability()
  chosenCompartments = ones(synapsesInLayer, 1) .* ...
    NP(iPostGroup).closestCompartmentToLayer(iLayer);
end