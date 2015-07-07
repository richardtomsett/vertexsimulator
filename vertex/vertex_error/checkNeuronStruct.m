function NP = checkNeuronStruct(NP)

%% Check required fields in NeuronParams

numGroups = length(NP);
if numGroups == 1
  NP.modelProportion = 1;
end
requiredFields = {'modelProportion','neuronModel','numCompartments'};
requiredClasses = {'double', 'char', 'double'};
requiredDimensions = {[1 1],[],[1 1]};
requiredFieldsMulti = {'compartmentParentArr', 'compartmentDiameterArr', ...
                       'compartmentXPositionMat', 'compartmentYPositionMat', ...
                       'compartmentZPositionMat', 'axisAligned', 'C', 'R_M', ...
                       'R_A', 'E_leak'};
requiredClassesMulti = {'double','double','double','double',...
                   'double','char', 'double','double','double',...
                   'double'};
requiredDimensionsMulti = {1, 1, 2, 2, 2, [], 1, 1, 1, 1};

for iGroup = 1:numGroups
  checkStructFields(NP(iGroup),requiredFields,...
                    requiredClasses,requiredDimensions);

  % modelProportion
  if ~checkNumericScalarPositive(NP(iGroup).modelProportion) || ...
     NP(iGroup).modelProportion > 1
    errMsg = ['Neuron parameter modelProportion must be numeric, ', ...
              'scalar, > 0 and <= 1 (neuron group ' num2str(iGroup) ')'];
    error('vertex:checkNeuronStruct:modelProportionNumericScalarPositive', errMsg);
  end
  
  % numCompartments
  if ~checkNumericScalarPositive(NP(iGroup).numCompartments)
    errMsg = ['Neuron parameter numCompartments must be numeric, ', ...
              'scalar and a positive whole numer (' ...
              'neuron group ' num2str(iGroup) ')'];
    error('vertex:checkNeuronStruct:numCompartmentsNumericScalarPositive', errMsg);
  end
  
  if NP(iGroup).numCompartments > 1
    checkStructFields(NP(iGroup),requiredFieldsMulti,requiredClassesMulti, ...
      requiredDimensionsMulti);
    
    % axisAligned
    if ~isempty(NP(iGroup).axisAligned) && ...
        ~strcmpi(NP(iGroup).axisAligned,'x') && ...
        ~strcmpi(NP(iGroup).axisAligned,'y') && ...
        ~strcmpi(NP(iGroup).axisAligned,'z')
      errMsg = ['Neuron parameter axisAligned must be x, y, z or empty ', ...
        '(neuron group ' num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:axisAlignedWrongValue', errMsg);
    end
    
    % compartmentParentArr
    if length(NP(iGroup).compartmentParentArr) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter compartmentParentArr is longer than ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentParentArrLength', errMsg);
    elseif max(NP(iGroup).compartmentParentArr) > NP(iGroup).numCompartments || ...
        min(NP(iGroup).compartmentParentArr) < 0
      errMsg = ['Neuron parameter compartmentParentArr contains an invalid '...
        'value for a compartment parent (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentParentArrValues', errMsg);
    end
    
    % compartmentLengthArr
    if length(NP(iGroup).compartmentLengthArr) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter compartmentLengthArr is longer than ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentLengthArrLength', errMsg);
    elseif min(NP(iGroup).compartmentLengthArr) < 0
      errMsg = ['Neuron parameter compartmentLengthArr contains an invalid '...
        'negative value for a compartment length (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentLengthArrValues', errMsg);
    end
    
    % compartmentDiameterArr
    if length(NP(iGroup).compartmentDiameterArr) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter compartmentDiameterArr is longer than ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentDiameterArrLength', errMsg);
    elseif min(NP(iGroup).compartmentDiameterArr) < 0
      errMsg = ['Neuron parameter compartmentDiameterArr contains an invalid '...
        'negative value for a compartment diameter (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentDiameterArrValues', errMsg);
    end
    
    % compartmentXPositionMat
    s = size(NP(iGroup).compartmentXPositionMat);
    if s(1) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter compartmentXPositionMat is incompatible with ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentXPositionMatLength', errMsg);
    end
    
    % compartmentYPositionMat
    s = size(NP(iGroup).compartmentYPositionMat);
    if s(1) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter compartmentYPositionMat is incompatible with ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentYPositionMatLength', errMsg);
    end
    
    % compartmentZPositionMat
    s = size(NP(iGroup).compartmentZPositionMat);
    if s(1) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter compartmentZPositionMat is incompatible with ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:compartmentZPositionMatLength', errMsg);
    end
    
    % C
    if length(NP(iGroup).C) > 1 && ...
       length(NP(iGroup).C) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter C should be of length equal to ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:CArrLength', errMsg);
    end
    if min(NP(iGroup).C) < 0
      errMsg = ['Neuron parameter C contains an invalid '...
        'negative value for a compartment C (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:CArrValues', errMsg);
    end
    
    % R_A
    if length(NP(iGroup).R_A) > 1 && ...
       length(NP(iGroup).R_A) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter R_A should be of length equal to ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:R_AArrLength', errMsg);
    end
    if min(NP(iGroup).R_A) < 0
      errMsg = ['Neuron parameter R_A contains an invalid '...
        'negative value for a compartment R_A (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:R_AArrValues', errMsg);
    end
    
    % R_M
    if length(NP(iGroup).R_M) > 1 && ...
       length(NP(iGroup).R_M) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter R_M should be of length equal to ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:R_MArrLength', errMsg);
    end
    if min(NP(iGroup).R_M) < 0
      errMsg = ['Neuron parameter R_M contains an invalid '...
        'negative value for a compartment R_M (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:R_MArrValues', errMsg);
    end
    
    % E_leak
    if length(NP(iGroup).E_leak) > 1 && ...
       length(NP(iGroup).E_leak) ~= NP(iGroup).numCompartments
      errMsg = ['Neuron parameter E_leak should be of length equal to ' ...
        'the specified number of compartments (neuron group ' ...
        num2str(iGroup) ')'];
      error('vertex:checkNeuronStruct:E_leakArrLength', errMsg);
    end
  end
  
  % input
  if isfield(NP(iGroup), 'Input')
    checkInputStruct(NP(iGroup).Input);
  end
end
 