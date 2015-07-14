function [SimulationSettings, TissueProperties] = ...
  distributeNeurons(SimulationSettings, TissueProperties)

numGroups = TissueProperties.numGroups;
groupBoundaryIDArr = TissueProperties.groupBoundaryIDArr;
groupSizeArr = TissueProperties.groupSizeArr;
N = TissueProperties.N;
numLabs = getNumOpenLabs();
numInGroupInLab = zeros(numGroups, numLabs);

% Assign neurons to labs
% This method ensures neurons from all groups are distributed evenly
% amongst all labs. This is naively the most efficient distribution.
% Other methods for distribution to be investigated in the future.
labParts = round(interp1( (0:numGroups)', groupBoundaryIDArr, ...
  (0:(1/numLabs):numGroups)', 'linear' ));
groupNumInLabs = diff(labParts);
neuronInLabInit = zeros(N, 1, 'uint8');
gc = 0;
for iGroup = 1:numGroups
  for iLab = 1:numLabs
    neuronInLabInit(labParts(iLab+gc)+1:labParts(iLab+gc+1)) = iLab;
    numInGroupInLab(iGroup, iLab) = ...
      groupNumInLabs((numLabs*(iGroup-1))+iLab);
  end
  gc = gc + numLabs;
end
neuronInLab = zeros(N, 1, 'uint8');

for iGroup = 1:numGroups
  randInd = randperm(groupSizeArr(iGroup)) + groupBoundaryIDArr(iGroup);
  neuronInLab(groupBoundaryIDArr(iGroup)+1: ...
    groupBoundaryIDArr(iGroup+1)) = neuronInLabInit(randInd);
end

% Store neuronInLab in SimuationSettings
SimulationSettings.neuronInLab = neuronInLab;
TissueProperties.numInGroupInLab = numInGroupInLab;