function [NeuronArr] = ...
  calculatePassiveProperties(NeuronArr, TissueProperties)

% Calculate passive neuron properties in correct units
numGroups = TissueProperties.numGroups;
for iGroup = 1:numGroups
  if NeuronArr(iGroup).numCompartments > 1
    l = NeuronArr(iGroup).compartmentLengthArr .* 10^-4; % in cm
    d = NeuronArr(iGroup).compartmentDiameterArr .* 10^-4; % in cm
    %if NeuronArr(iGroup).homogeneous
    %if ~isfield(NeuronArr(iGroup), 'g_l')
    R_M = NeuronArr(iGroup).R_M ./ (pi .* l .* d); % in Ohms
    NeuronArr(iGroup).g_l = 10^9 ./ R_M; % in nanoSiemens
    %end
    %if ~isfield(NeuronArr(iGroup), 'g_ax')
    R_A = (4 .* l .* NeuronArr(iGroup).R_A) ./ (pi .* d .^ 2); % in Ohms
    parents = NeuronArr(iGroup).compartmentParentArr(:)';
    maxNumChildren = sum(parents==mode(parents));
    axialConnectionCell = cell(1, maxNumChildren+1);
    axialConnectionCell{1} = [2:length(parents); parents(2:end)];
    axialConductanceCell = cell(1, maxNumChildren+1);
    axialConductanceCell{1} = ...
      10^9 ./ ((R_A(axialConnectionCell{1}(1,:)) + ...
      R_A(axialConnectionCell{1}(2,:))) ./ 2); %nanoSiemens
    for iComp = 1:length(parents)
      children = find(parents == iComp);
      if ~isempty(children)
        for iIndex = 1:length(children)
          axialConnectionCell{iIndex + 1} = ...
            [axialConnectionCell{iIndex + 1}, ...
            [iComp; children(iIndex)]];
          axialConductanceCell{iIndex + 1} = ...
            10^9 ./ ((R_A(axialConnectionCell{iIndex + 1}(1,:)) + ...
            R_A(axialConnectionCell{iIndex + 1}(2,:))) ./ 2);
        end
      end
    end
    
    NeuronArr(iGroup).adjCompart = axialConnectionCell;
    NeuronArr(iGroup).g_ax = axialConductanceCell;
    %end
    %if ~isfield(NeuronArr(iGroup), 'C_m') || ...
    %    length(NeuronArr(iGroup).C_m) ~= NeuronArr(iGroup).numCompartments
    NeuronArr(iGroup).C_m = ...
      NeuronArr(iGroup).C .* pi .* l .* d .* 10^6; % in nanoFarads
    %end
    %else
    % TODO: implement heterogeneous group dynamics
    %end
  end
end