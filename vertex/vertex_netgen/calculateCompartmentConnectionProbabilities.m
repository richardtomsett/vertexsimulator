function [NeuronArr] = ...
  calculateCompartmentConnectionProbabilities(NeuronArr, ...
  TissueProperties)

%proportionAreaInLayerArr = cell(TissueProperties.numNeuronGroups,1);
somaLayerArr = [NeuronArr.somaLayer];
layerBoundaryArr = [TissueProperties.layerBoundaryArr];
layerThicknessArr = abs(diff(layerBoundaryArr));
layerCentreArr = layerBoundaryArr(2:end) + layerThicknessArr./2;
neuronCentreArr = layerCentreArr(somaLayerArr);
numNeuronGroups = TissueProperties.numGroups;

for iGroup = 1:numNeuronGroups
  if NeuronArr(iGroup).numCompartments > 1
    neuronGroup = NeuronArr(iGroup);
    ZPosMat = NeuronArr(iGroup).compartmentZPositionMat + ...
      neuronCentreArr(iGroup);
    
    membraneAreaInLayer = ...
      zeros(TissueProperties.numLayers, neuronGroup.numCompartments);
    closestCompartmentToLayer = zeros(1, TissueProperties.numLayers);
    closestCompartmentToLayerDist = Inf(1, TissueProperties.numLayers);
    for iCompartment = 1:neuronGroup.numCompartments
      % Find which layer the start and end of the compartment are in. As we
      % know that layers are numbered in descending z-height order, we can do
      % this by summing the number of layers whose boundaries are below the
      % compartment's z-coordinates
      compartmentEndZ = ZPosMat(iCompartment, 2);
      compartmentStartZ = ZPosMat(iCompartment, 1);
      if compartmentStartZ >= compartmentEndZ
        compartmentMiddleZ = compartmentEndZ + ...
          (compartmentStartZ - compartmentEndZ)/2;
        compartmentTopZ = compartmentStartZ;
        compartmentBottomZ = compartmentEndZ;
        compartmentTopLayer = ...
          max(sum(compartmentStartZ < layerBoundaryArr(1:end - 1)), 1);
        compartmentBottomLayer = ...
          sum(compartmentEndZ < layerBoundaryArr(1:end - 1));
      else % compartmentStartZ < compartmentEndZ
        compartmentMiddleZ = compartmentStartZ + ...
          (compartmentEndZ - compartmentStartZ)/2;
        compartmentTopZ = compartmentEndZ;
        compartmentBottomZ = compartmentStartZ;
        compartmentTopLayer = ...
          max(sum(compartmentEndZ < layerBoundaryArr(1:end - 1)), 1);
        compartmentBottomLayer = ...
          sum(compartmentStartZ < layerBoundaryArr(1:end - 1));
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      compartmentTopLayer = max(1, compartmentTopLayer);
      compartmentBottomLayer = ...
        max(min(TissueProperties.numLayers, compartmentBottomLayer), 1);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % For each layer, store the compartment whose centre is closest to the
      % layer centre. This is used when assigning synapses that are supposed
      % to be made in a particular layer, but the neuron has no compartments
      % in that layer.
      compartmentDistToLayerCentres = ...
        abs(layerCentreArr - compartmentMiddleZ);
      closer = compartmentDistToLayerCentres < closestCompartmentToLayerDist;
      closestCompartmentToLayerDist(closer) = ...
        compartmentDistToLayerCentres(closer);
      closestCompartmentToLayer(closer) = iCompartment;
      
      % Get compartment length and diameter
      compartmentLength = neuronGroup.compartmentLengthArr(iCompartment);
      compartmentDiameter = ...
        neuronGroup.compartmentDiameterArr(iCompartment);
      
      % If start and end are in the same layer, then the whole compartment
      % is in a single layer
      if compartmentTopLayer == compartmentBottomLayer
        membraneAreaInLayer(compartmentTopLayer, iCompartment) = ...
          compartmentLength * compartmentDiameter * pi;
        % Otherwise, a fraction is in the top's layer and a fraction in the
        % bottom's layer
      else
        % Check to see if the compartment spans more than two layers
        layersFullySpanned = ...
          (compartmentTopLayer - compartmentBottomLayer) - 1;
        if layersFullySpanned ~= 0
          for iLayersSpanned = 1:layersFullySpanned
            % Find proportion of the whole compartment length in the
            % relevant layer
            proportionInLayer = ...
              layerThicknessArr(compartmentTopLayer + iLayersSpanned) ...
              / (compartmentEndZ - compartmentStartZ);
            % Store compartment area in relevant layer row
            membraneAreaInLayer(compartmentTopLayer ...
              + iLayersSpanned, iCompartment) = ...
              proportionInLayer * compartmentLength * ...
              compartmentDiameter * pi;
          end
        end
        % Find proportion of whole compartment length in the compartment
        % start and end containing layers
        proportionInTopLayer = ...
          (compartmentTopZ - layerBoundaryArr( ...
          compartmentTopLayer + 1)) ...
          / (compartmentTopZ - compartmentBottomZ);
        proportionInBottomLayer = (layerBoundaryArr( ...
          compartmentBottomLayer) - compartmentBottomZ) ...
          / (compartmentTopZ - compartmentBottomZ);
        % Store compartment area in relevant layer row
        membraneAreaInLayer(compartmentTopLayer, iCompartment) = ...
          proportionInTopLayer * compartmentLength ...
          * compartmentDiameter * pi;
        membraneAreaInLayer(compartmentBottomLayer , iCompartment) = ...
          proportionInBottomLayer * compartmentLength ...
          * compartmentDiameter * pi;
      end
      
      %     if compartmentBottomLayer == neuronGroup.somaLayer ...
      %     || compartmentTopLayer == neuronGroup.somaLayer
      %       neuronGroup.compartmentsInSomaLayer = ...
      %         [neuronGroup.compartmentsInSomaLayer iCompartment];
      %     end
    end
    totalAreaInLayer = sum(membraneAreaInLayer,2);
    proportionAreaInLayer = bsxfun(@rdivide, membraneAreaInLayer, ...
      totalAreaInLayer(:));
    proportionAreaInLayer(isnan(proportionAreaInLayer)) = 0;
    NeuronArr(iGroup).proportionCompartmentAreaInLayer = ...
      proportionAreaInLayer;
    NeuronArr(iGroup).closestCompartmentToLayer = ...
      closestCompartmentToLayer;
  end
end