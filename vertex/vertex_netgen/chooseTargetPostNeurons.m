function [chosenTargets] = ...
  chooseTargetPostNeurons(CP, SS, iPreGroup, iPostGroup, iLayer, ...
                          synapsesInLayer, distsSquared)
                      
if ~isfield(CP(iPreGroup), 'allowMultipleSynapses')
    allowMultiSyn = SS.multiSyn;
  else
    allowMultiSyn = CP(iPreGroup).allowMultipleSynapses{iPostGroup};
end

numPotentialTargets = size(distsSquared, 1);
maxLoops = 15;
countLoops = 1;

if strcmp(CP(iPreGroup).axonArborSpatialModel, 'gaussian')
  % get the axon arbour radius
  preAxonArbourInLayer = CP(iPreGroup).axonArborRadius(iLayer) ;
  % assign target weights according to 2D Gaussian distribution
  targetWeights = exp(-(distsSquared(:,1) + distsSquared(:,2)) ./ ...
    (2 .* preAxonArbourInLayer^2)) ./ ...
    (2 .* pi .* preAxonArbourInLayer^2);
  
  % pick target neurons according to their distance weighting (WITH replacement)
  edges = min([0; cumsum(targetWeights(:) ./ sum(targetWeights))], 1);
  edges(end) = 1;
  
  if SS.multiSyn && allowMultiSyn
    [~, chosenTargets] = histc(rand(synapsesInLayer, 1), edges);
  else
    if numPotentialTargets < synapsesInLayer
      synapsesInLayer = numPotentialTargets;
    end
    stillToChoose = synapsesInLayer;
    chosenTargets = zeros(synapsesInLayer, 1);
    counter = 0;
    while stillToChoose ~= 0 && countLoops <= maxLoops
      [nn, ct] = histc(rand(stillToChoose, 1), edges);
      uct = unique(ct);
      chosenTargets(counter+1:counter+length(uct)) = uct;
      counter = counter + length(uct);
      
      % recalculate edges
      targetWeights(nn ~= 0) = 0;
      edges = min([0; cumsum(targetWeights(:) ./ sum(targetWeights))], 1);
      edges(end) = 1;
      
      nn(nn > 1) = 1;
      stillToChoose = stillToChoose - sum(nn);
      countLoops = countLoops + 1;
    end
    if counter < length(chosenTargets)
      chosenTargets(counter+1:end) = [];
    end
  end
elseif strcmp(CP(iPreGroup).axonArborSpatialModel, 'uniform')
  if SS.multiSyn && allowMultiSyn
    chosenTargets = randi(numPotentialTargets, synapsesInLayer, 1);
  else
    if numPotentialTargets < synapsesInLayer
      synapsesInLayer = numPotentialTargets;
      chosenTargets = 1:synapsesInLayer;
    else
      chosen = zeros(1, numPotentialTargets);
      sumChosen = 0;
      
      while sumChosen < synapsesInLayer && countLoops <= maxLoops
        chosen(randi(numPotentialTargets, 1, synapsesInLayer-sumChosen)) = 1; 
        sumChosen = sum(chosen);
        countLoops = countLoops + 1;
      end
      chosenTargets = find(chosen > 0);
      chosenTargets = chosenTargets(randperm(synapsesInLayer));
    end
  end
else
  error('vertex:chooseTargetPostNeurons:nonexistentArborSpatialModel', ...
        ['The axon arbor spatial model you defined for group ' num2str(iPreGroup) ...
        ' (' CP(iPreGroup.axonArborSpatialModel) ' does not exist']);
end