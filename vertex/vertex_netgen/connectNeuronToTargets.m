function [targetIDs, targetComparts, targetDelays] = ...
  connectNeuronToTargets(TP,NP,CP,SS,iPreInLab,iPre,iPreGroup,numSynapses)

% Calculate remaining number of synapses after slicing, and allocate
% memory to store synapses for each presynaptic neuron
iPreNumSyn = squeeze(numSynapses(iPreInLab, :, :));
if TP.numLayers == 1
  iPreNumSyn = iPreNumSyn';
end

% Pre-allocate memory to store synapse information for each neuron
targetIDs = zeros(1, sum(iPreNumSyn(:)), SS.nIDintSize);
targetComparts = zeros(1, sum(iPreNumSyn(:)), 'uint8');
targetDelays = zeros(1, sum(iPreNumSyn(:)));

% var to keep track of how many synapses have been made, so that we can
% preallocate memory rather than expanding arrays every time:
numSynapsesCounter = 0;
for iPostGroup = 1:TP.numGroups
  if sum(iPreNumSyn(:, iPostGroup)) ~= 0
    iPostGroupOffset = TP.groupBoundaryIDArr(iPostGroup);
    % Get all neurons of the relevant type
    potentialTargetXYZArr = TP.somaPositionMat( ...
     TP.groupBoundaryIDArr(iPostGroup)+1:TP.groupBoundaryIDArr(iPostGroup+1),:);
    % (remove the neuron itself to prevent autapses)
    if iPreGroup == iPostGroup
      potentialTargetXYZArr(iPre - iPostGroupOffset, :) = [];
    end
    % find the X-Y distances between the pre and all post neurons
    distancesSquared = calculateDistancesSquared(TP,iPre,potentialTargetXYZArr);
    %end
    % Go through each layer and assign relevant number of synapses
    for iLayer = 1:TP.numLayers
      %find the number of synapses made with the postsynaptic group in
      %the current layer
      synapsesInLayer = iPreNumSyn(iLayer, iPostGroup);
      % only go further if this number is > 0
      if synapsesInLayer ~= 0

        chosenTargets = chooseTargetPostNeurons(CP,SS,iPreGroup,iPostGroup, ...
          iLayer, synapsesInLayer,distancesSquared);

        % get the absolute IDs, for the chosen postsynaptic targets
        chosenIDs = potentialTargetXYZArr(chosenTargets, 4);
        numChosen = length(chosenIDs);

        % for calculating which compartments to connect to on the
        % postsynaptic neurons, first find the weightings for the
        % compartments
        chosenCompartments = chooseCompartments(NP, CP, iPreGroup, ...
          iPostGroup, iLayer, numChosen);
        axonDelays =...
          calculateAxonDelays(CP, iPreGroup, chosenTargets, distancesSquared);
        
        % Store the postsynaptic targets and delays
        targetIDs(numSynapsesCounter+1:numSynapsesCounter+numChosen) = ...
          chosenIDs;
        targetComparts(numSynapsesCounter+1:numSynapsesCounter+numChosen)= ...
          chosenCompartments;
        targetDelays(numSynapsesCounter+1:numSynapsesCounter+numChosen) = ...
          axonDelays;
        
        % move on the counter
        numSynapsesCounter = numSynapsesCounter + numChosen;
      end
    end %for each layer
  end % if any synapses to assign
end %for all postsynaptic groups

% if necessary, trim the connection arrays
if numSynapsesCounter ~= length(targetIDs)
  targetIDs = targetIDs(1:numSynapsesCounter);
  targetComparts = targetComparts(1:numSynapsesCounter);
  targetDelays = targetDelays(1:numSynapsesCounter);
end

% sort by target ID
[targetIDs, idx] = sort(targetIDs);
targetComparts = targetComparts(idx);
targetDelays = targetDelays(idx);
