function [neuronInGroup] = createGroupsFromBoundaries(groupBoundaryIDArr)

neuronInGroup = zeros(groupBoundaryIDArr(end), 1, 'uint8');
for iGroup = 1:length(groupBoundaryIDArr)-1
  neuronInGroup(groupBoundaryIDArr(iGroup)+1: ...
    groupBoundaryIDArr(iGroup+1)) = iGroup;
end