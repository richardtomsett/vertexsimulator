function [IP] = checkInputStruct(IP)

%% Check required fields in Input

numInputs = length(IP);

for iIn = 1:numInputs
  
  checkStructFields(IP(iIn), {'inputType'}, {'char'});
  
  className = IP(iIn).inputType;
  
  if isempty(className)
    eval('pars = InputModel.getRequiredParams();')
  else
    eval(['pars = InputModel_' className '.getRequiredParams();'])
  end
  for ii = 1:length(pars)
    if ~isfield(IP(iIn), pars{ii})
      error('vertex:checkInputStruct:missingInputParameter', ...
        ['The Input structure (attached to the neuron parameters structure '...
        'is missing parameter ' pars{ii}]);
    end
  end
end