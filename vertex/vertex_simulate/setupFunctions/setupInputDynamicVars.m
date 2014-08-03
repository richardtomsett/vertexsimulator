function [InputModelArr] = setupInputDynamicVars(TP, NP, SS)

% assume 1 input, dynamically expand if more

constructorCell = cell(TP.numGroups, 1);
compartsCell = cell(TP.numGroups, 1);
for iGroup=1:TP.numGroups
  for iIn = 1:length(NP(iGroup).Input)
    modelName = lower(NP(iGroup).Input(iIn).inputType);
    constructor = str2func(['InputModel_' modelName]);
    if isfield(NP(iGroup).Input, 'compartments')
      comparts = NP(iGroup).Input.compartments;
    else
      comparts = 1:NP(iGroup).numCompartments;
    end
    constructorCell{iGroup, iIn} = constructor;
    compartsCell{iGroup, iIn} = comparts;
  end
end

if SS.parallelSim
  spmd
    InputModelArr = cell(TP.numGroups, 1);
    for iGroup = 1:TP.numGroups
      for iIn = 1:length(NP(iGroup).Input)
        subsetInLab = find(SS.neuronInLab==labindex());
        subsetInLab = subsetInLab( ...
          subsetInLab <= TP.groupBoundaryIDArr(iGroup+1) & ...
          subsetInLab > TP.groupBoundaryIDArr(iGroup)) - ...
          TP.groupBoundaryIDArr(iGroup);
        
        constructor = constructorCell{iGroup, iIn};
        comparts = compartsCell{iGroup, iIn};
        InputModelArr{iGroup,iIn} = ...
          constructor(NP(iGroup), iIn, ...
          TP.numInGroupInLab(iGroup, labindex()), SS.timeStep, comparts, subsetInLab);
      end
    end
  end
else
  InputModelArr = cell(TP.numGroups, 1);
  numInGroup = diff(TP.groupBoundaryIDArr);
  for iGroup = 1:TP.numGroups
    for iIn = 1:length(NP(iGroup).Input)
      constructor = constructorCell{iGroup, iIn};
      comparts = compartsCell{iGroup, iIn};
      InputModelArr{iGroup, iIn} = ...
        constructor(NP(iGroup), iIn, numInGroup(iGroup), SS.timeStep, comparts);
    end
  end
end
