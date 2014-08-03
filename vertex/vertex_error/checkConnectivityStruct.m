function [CP] = checkConnectivityStruct(CP)

%% Check required fields in ConnectivityParams
% add something for sliceSynapses
% make sure sliceSynapses cannot be true when cylindrical
numGroups = length(CP);

requiredFields = {'numConnectionsToAllFromOne','synapseType', ...
    'targetCompartments', 'weights', 'axonArborSpatialModel', ...
    'axonConductionSpeed', 'synapseReleaseDelay'};
requiredClasses = {'cell','cell','cell','cell','char','double','double'};
requiredDimensions = {numGroups, numGroups, numGroups, numGroups, ...
                      [], [1 1], [1 1]};

for iPre = 1:numGroups
  checkStructFields(CP(iPre), requiredFields, ...
                    requiredClasses, requiredDimensions);
  
  for iPost = 1:numGroups
    if ~isempty(CP(iPre).numConnectionsToAllFromOne{iPost}) && ...
       ~checkNumericPositiveOrZero(CP(iPre).numConnectionsToAllFromOne{iPost})
      errMsg = ['Content of numConnectionsToAllFromOne cell array must be numerical, ', ...
                'scalar and >= 0 (pre->post connection: ' num2str(iPre) ...
                ' -> ' num2str(iPost) ')'];
      error('vertex:checkConnectivityStruct:numConnectionsNotNumericScalar', errMsg);
    end
    
    synModel = ['SynapseModel_' CP(iPre).synapseType{iPost}];
    if ~isempty(CP(iPre).synapseType{iPost}) && ...
       ~exist(synModel,'file')
      errMsg = ['Synapse model ' CP(iPre).synapseType{iPost} ' does ' ...
                'not exist (pre->post connection: ' num2str(iPre) ...
                ' -> ' num2str(iPost) ')'];
      error('vertex:checkConnectivityStruct:synapseModelNotFound', errMsg);
    end
    
    if ~isempty(CP(iPre).weights{iPost}) && ...
       ~checkNumeric(CP(iPre).weights{iPost})
      errMsg = ['Content of weights cell array must be numeric ', ...
                '(pre->post connection: ' num2str(iPre) ...
                ' -> ' num2str(iPost) ')'];
      error('vertex:checkConnectivityStruct:weightNotNumericScalar', errMsg);
    end
  end
  
  if ~checkNumericScalarPositive(CP(iPre).axonConductionSpeed)
    errMsg = ['Axon conduction speed must be positive, numeric ', ...
              'scalar (pre->post connection: ' num2str(iPre) ...
                ' -> ' num2str(iPost) ')'];
    error('vertex:checkConnectivityStruct:axonConductionPositiveNumericScalar', errMsg);
  end
  
  if ~checkNumericScalarPositive(CP(iPre).synapseReleaseDelay)
    errMsg = ['Synapse release delay must be positive, numeric ', ...
              'scalar (pre->post connection: ' num2str(iPre) ...
                ' -> ' num2str(iPost) ')'];
    error('vertex:checkConnectivityStruct:synapseReleasePositiveNumericScalar', errMsg);
  end
  
end
