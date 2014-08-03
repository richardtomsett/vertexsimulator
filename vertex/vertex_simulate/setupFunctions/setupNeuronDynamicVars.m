function [NeuronModelArr] = ...
  setupNeuronDynamicVars(TP, NP, SS, NeuronIDMap, loadedSpikeTimeCell)

numInGroup = diff(TP.groupBoundaryIDArr);

modelCell = cell(TP.numGroups, 1);
constructorCell = cell(TP.numGroups, 1);
for iGroup = 1:TP.numGroups
  modelCell{iGroup} = lower(NP(iGroup).neuronModel);
  
  if NP(iGroup).numCompartments == 1
    funString = ['PointNeuronModel_' modelCell{iGroup}];
  else
    funString = ['NeuronModel_' modelCell{iGroup}];
  end
  
  if strcmp(funString(end), '_')
    funString = funString(1:end-1);
  end
  constructorCell{iGroup} = str2func(funString);
end

if SS.parallelSim
  spmd
    NeuronModelArr = cell(TP.numGroups, 1);
    for iGroup = 1:TP.numGroups
      if strcmpi(modelCell{iGroup}, 'loadspiketimes')
        spikeTimeIDs = NeuronIDMap.cellIDToModelIDMap{iGroup} - ...
          TP.groupBoundaryIDArr(iGroup);
        p_spikeTimeCell = loadedSpikeTimeCell{iGroup}(spikeTimeIDs);
        if TP.numInGroupInLab(iGroup,labindex()) ~= length(p_spikeTimeCell)
          errMsg = ['Loaded spiketime cell for group ' num2str(iGroup) ...
            ' does not match number of neurons in the group ' ...
            '(parallel, lab ID ' num2str(labindex)];
          error('vertex:setupNeuronDynamicVarsParallel:spikeLoadMismatch',...
            errMsg);
        end
        NeuronModelArr{iGroup} = ...
          constructorCell{iGroup}(NP(iGroup), TP.numInGroupInLab(iGroup,labindex()), ...
          p_spikeTimeCell);
      else
        NeuronModelArr{iGroup} = ...
          constructorCell{iGroup}(NP(iGroup), TP.numInGroupInLab(iGroup,labindex()));
      end % if loadedspiketimes
    end % for each group
  end % spmd
else
  NeuronModelArr = cell(TP.numGroups, 1);
  for iGroup = 1:TP.numGroups
    if strcmpi(modelCell{iGroup}, 'loadspiketimes')
      if numInGroup(iGroup) ~= length(loadedSpikeTimeCell{iGroup})
        errMsg = ['Loaded spiketime cell for group ' num2str(iGroup) ...
          ' does not match number of neurons in the group'];
        error('vertex:setupNeuronDynamicVars:spikeLoadMismatch',...
          errMsg);
      end
      NeuronModelArr{iGroup} = ...
        constructorCell{iGroup}(NP(iGroup), numInGroup(iGroup), ...
        loadedSpikeTimeCell{iGroup});
    else
      NeuronModelArr{iGroup} = ...
        constructorCell{iGroup}(NP(iGroup), numInGroup(iGroup));
    end
  end
end