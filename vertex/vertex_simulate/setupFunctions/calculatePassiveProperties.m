function [NP] = calculatePassiveProperties(NP, TP)

% Calculate passive neuron properties in correct units
numGroups = TP.numGroups;
for iGroup = 1:numGroups
  
  % Get the required parameters for the particular model
  modelName = generateNeuronModelName(NP(iGroup));
  requiredParams = eval([modelName '.getRequiredParams()']);

  % if C_m is required and not supplied, calculate it
  if sum(strcmp('C_m', requiredParams)) ~= 0 && ...
      ( ~isfield(NP(iGroup),'C_m') || isempty(NP(iGroup).C_m) )
    [l, d] = getDimensionsInCentimetres(NP(iGroup));
    NP(iGroup).C_m = ...
      NP(iGroup).C .* pi .* l .* d .* 10^6; % in nanoFarads
  end
  
  % if g_l is required and not supplied, calculate it
  if sum(strcmp('g_l', requiredParams)) ~= 0 && ...
      ( ~isfield(NP(iGroup),'g_l') || isempty(NP(iGroup).g_l) )
    [l, d] = getDimensionsInCentimetres(NP(iGroup));
    R_M = NP(iGroup).R_M ./ (pi .* l .* d); % in Ohms
    NP(iGroup).g_l = 10^9 ./ R_M; % in nanoSiemens
  end
  
  % if g_ax is required and not supplied, calculate it and the adjacent
  % compartment cell array
  if sum(strcmp('g_ax', requiredParams)) ~= 0 && ...
      ( ~isfield(NP(iGroup),'g_ax') || isempty(NP(iGroup).g_ax) )
    [l, d] = getDimensionsInCentimetres(NP(iGroup));
    R_A = (4 .* l .* NP(iGroup).R_A) ./ (pi .* d .^ 2); % in Ohms
    parents = NP(iGroup).compartmentParentArr(:)';
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
    
    NP(iGroup).adjCompart = axialConnectionCell;
    NP(iGroup).g_ax = axialConductanceCell;
  end

  % TODO: implement heterogeneous group dynamics
end
end

% convert user provided lengths and diameters from microns to cm
function [l, d] = getDimensionsInCentimetres(NP)
l = NP.compartmentLengthArr .* 10^-4;
d = NP.compartmentDiameterArr .* 10^-4;
end