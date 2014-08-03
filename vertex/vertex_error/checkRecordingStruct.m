function [RS] = checkRecordingStruct(RS)

% Check required fields in Recording parameters

requiredFields = {'saveDir','LFP', 'maxRecTime', 'sampleRate'};
requiredClasses = {'char', 'logical', 'double', 'double'};
requiredDimensions = {1, [1 1], [1 1], [1 1]};

checkStructFields(RS, requiredFields, requiredClasses, requiredDimensions);

if RS.LFP
  extraFields = {'meaXpositions', 'meaYpositions', 'meaZpositions'};
  extraClasses = {'double', 'double', 'double'};
  checkStructFields(RS, extraFields, extraClasses);
end

if isfield(RS, 'minDistToElectrodeTip')
  if ~checkNumericScalarPositive(RS.minDistToElectrodeTip)
    error('vertex:checkRecordingStruct:minDistToElectrodeTipError', ...
          ['minDistToElectrodeTip in Recording settings must be ' ...
          'numerical, scalar, and positive']);
  end
elseif RS.LFP
  disp(['Setting minimum distance from an electrode tip to a ' ...
        'compartment to 20 micrometres.'])
  RS.minDistToElectrodeTip = 20;
end
