function [NeuronIDMap] = setupNeuronIDMapping(TP, SS)

% Neuron ID mappings
modelIDToCellIDMap = zeros(TP.N, 2, 'uint32');
cellIDToModelIDMap = cell(TP.numGroups, 1);
numInGroup = diff(TP.groupBoundaryIDArr);
neuronInGroup = createGroupsFromBoundaries(TP.groupBoundaryIDArr);

if SS.parallelSim
  spmd
    p_modelIDToCellIDMap = zeros(TP.N, 2, 'uint32');
    p_cellIDToModelIDMap = cell(TP.numGroups, 1);
    
    p_numInGroup = zeros(TP.numGroups, 1);
    
    p_neuronInThisLab = find(SS.neuronInLab == labindex);
    p_neuronInGroup = neuronInGroup(p_neuronInThisLab);
    
    for iGroup = 1:TP.numGroups
      p_inGroup = p_neuronInGroup == iGroup;
      p_numInGroup(iGroup) = sum(p_inGroup);
      p_modelIDToCellIDMap(p_neuronInThisLab(p_inGroup), 1) = ...
        1:p_numInGroup(iGroup);
      p_modelIDToCellIDMap(p_neuronInThisLab(p_inGroup), 2) = iGroup;
      p_cellIDToModelIDMap{iGroup} = p_neuronInThisLab(p_inGroup);
    end
    
    NeuronIDMap.modelIDToCellIDMap = p_modelIDToCellIDMap;
    NeuronIDMap.cellIDToModelIDMap = p_cellIDToModelIDMap;
  end
else
  for iGroup = 1:TP.numGroups
    inGroup = neuronInGroup == iGroup;
    modelIDToCellIDMap( ...
      TP.groupBoundaryIDArr(iGroup)+1:TP.groupBoundaryIDArr(iGroup+1), 1) = ...
      1:numInGroup(iGroup);
    modelIDToCellIDMap( ...
      TP.groupBoundaryIDArr(iGroup)+1:TP.groupBoundaryIDArr(iGroup+1), 2) = iGroup;
    cellIDToModelIDMap{iGroup} = find(inGroup);
  end
  
  NeuronIDMap.modelIDToCellIDMap = modelIDToCellIDMap;
  NeuronIDMap.cellIDToModelIDMap = cellIDToModelIDMap;
end