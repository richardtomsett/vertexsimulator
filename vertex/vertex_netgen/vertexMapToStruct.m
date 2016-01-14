function outputStruct = vertexMapToStruct(inputMap, printGroupNames)

if nargin == 1
  printGroupNames = false;
end
if printGroupNames
  disp('Converting neuron parameter map to struct for internal use...');
end

if isa(inputMap,'containers.Map')
  outputStruct = struct();
  k = inputMap.keys();
  if isa(inputMap(k{1}),'containers.Map')
    for iGroup = 1:length(k)
      outputStruct(iGroup).groupName = k{iGroup};
      if printGroupNames
        disp(['Neuron group ' k{iGroup} ' is group number ' num2str(iGroup)]);
      end
      kg = inputMap(k{iGroup}).keys();
      for iField = 1:length(kg)
        v = inputMap(k{iGroup});
        outputStruct(iGroup).(kg{iField}) = v(kg{iField});
      end
    end
  else
    for iField = 1:length(k)
      outputStruct.(k{iField}) = inputMap(k{iField});
    end
  end
elseif isstruct(inputMap)
  outputStruct = inputMap;
else
  errMsg = 'Input neither a struct nor a Map object!';
  error('vertex:wrongInputType', errMsg);
end