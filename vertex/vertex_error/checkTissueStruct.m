function [TP] = checkTissueStruct(TP)

%% Check required fields in TissueParams
requiredFields = {'Z','neuronDensity','numLayers','layerBoundaryArr'};
requiredClasses = {'double','double','double','double'};
requiredDimensions = {[1 1], [1 1], [1 1], 1};
checkStructFields(TP, requiredFields, requiredClasses, requiredDimensions);

% Check extra fields (with dependencies, or not required)
%% Z
if ~checkNumericScalarPositive(TP.Z)
  errMsg = ['Tissue parameter Z must be numeric, ', ...
                    'scalar and positive.'];
  error('vertex:checkTissueStruct:ZNumericScalarPositive', errMsg);
end
%% neuronDensity
if ~checkNumericScalarPositive(TP.neuronDensity)
  errMsg = ['Tissue parameter neuronDensity must be numeric, ', ...
                    'scalar and positive.'];
  error('vertex:checkTissueStruct:ZNumericScalarPositive', errMsg);
end
%% numLayers
if ~checkNumericScalarPositive(TP.numLayers)
  errMsg = ['Tissue parameter numLayers must be numeric, ', ...
                    'scalar and a whole number.'];
  error('vertex:checkTissueStruct:ZNumericScalarPositive', errMsg);
end
%% layerBoundaryArr
if length(TP.layerBoundaryArr) ~= TP.numLayers + 1
  errMsg = ['Length of tissue parameters layerBoundaryArr must ',...
                  'be equal to numLayers + 1'];
  error('vertex:checkTissueStruct:layerBoundaryArrWrongLength', errMsg);
end
if TP.layerBoundaryArr(1) - TP.layerBoundaryArr(end) ~= TP.Z
  errMsg = ['Tissue parameters layerBoundaryArr values must be ', ... 
                  'compatible with Z value, ie layerBoundaryArr(1) - ', ...
                  'layerBondaryArr(end) must equal Z'];
  error('vertex:checkTissueStruct:layerBoundaryArrZMismatch', errMsg);
end
if ~issorted(flipud(TP.layerBoundaryArr(:)))
  errMsg = ['Tissue parameters layerBoundaryArr values must be ', ... 
                  'in descending order'];
  error('vertex:checkTissueStruct:layerBoundaryArrOrderError', errMsg);
end

%% R or X, Y
if ~isfield(TP,'R')
  if ~isfield(TP,'X') && ~isfield(TP,'Y')
    errMsg = ['Tissue parameters require either X and Y (for ', ...
                    'cuboid model) or R (for cylindrical model) to be ',...
                    'specified'];
    error('vertex:checkTissueStruct:modelDimensionsUnspecified', errMsg);
  elseif ~checkNumericScalarPositive(TP.X) || ...
         ~checkNumericScalarPositive(TP.Y)
    errMsg = ['Tissue parameters X and Y must be numeric, ', ...
                    'scalar and positive.'];
    error('vertex:checkTissueStruct:XYNumericScalarPositive', errMsg);
  end
elseif ~checkNumericScalarPositive(TP.R)
  errMsg = ['Tissue parameter R must be numeric, ', ...
                    'scalar and positive.'];
  error('vertex:checkTissueStruct:RNumericScalarPositive', errMsg);
end

%% numStrips
if ~isfield(TP,'numStrips')
  disp('numStrips not specified in Tissue params, setting numStrips = 1');
  TP.numStrips = 1;
elseif ~checkNumericScalarPositive(TP.numStrips)
  errMsg = ['Tissue parameter numStrips must be numeric, ', ...
                  'scalar and >= 1'];
  error('vertex:checkTissueStruct:numStripsNumericScalarPositive', errMsg);
end

%% tissueConductivity
if ~isfield(TP,'tissueConductivity')
  disp(['tissueConductivity not specified in Tissue params, ' ...
        'setting tissueConductivity = 0.3 S/m']);
  TP.tissueConductivity = 0.3;
elseif ~checkNumericScalarPositive(TP.numStrips)
  errMsg = ['Tissue parameter tissueConductivity must be numeric, ', ...
            'scalar and positive'];
  error('vertex:checkTissueStruct:tissueConductivityNumericScalarPositive', errMsg);
end

%% maxZOverlap
if ~isfield(TP,'maxZOverlap')
  disp(['maxZOverlap not specified in Tissue params, ' ...
        'setting maxZOverlap = [0, 0]']);
  TP.maxZOverlap = [0, 0];
elseif ~isequal(size(TP.maxZOverlap(:)), [2, 1])
  errMsg = ['Tissue parameter maxZOverlap must be numeric and ' ...
            'two values (for above and below model space)'];
  error('vertex:checkTissueStruct:maxZOverlapDimensions', errMsg);
end