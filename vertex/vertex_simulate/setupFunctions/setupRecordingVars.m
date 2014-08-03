function [RS, RecordingVars] = setupRecordingVars(TP, NP, SS, RS, IDMap, LSM)

groupBoundaryIDArr = TP.groupBoundaryIDArr;
neuronInGroup = createGroupsFromBoundaries(groupBoundaryIDArr);

if RS.LFP
  numElectrodes = length(RS.meaXpositions(:));
  RS.numElectrodes = numElectrodes;
end

% Intracellular recording:
if SS.parallelSim
  intraRecLab = SS.neuronInLab(RS.v_m);
  spmd
    if ismember(labindex(), unique(intraRecLab))
      recordIntra = true;
      p_intraRecModelIDArr = RS.v_m(intraRecLab == labindex());
      p_intraRecCellIDArr = ...
        IDMap.modelIDToCellIDMap(p_intraRecModelIDArr, :);
      p_numToRecordIntra = size(p_intraRecModelIDArr, 1);
      p_intraRecording = zeros(p_numToRecordIntra, RS.maxRecSamples);
      
      RecordingVars.intraRecCellIDArr = p_intraRecCellIDArr;
      RecordingVars.intraRecording = p_intraRecording;
    else
      recordIntra = false;
    end
    RecordingVars.recordIntra = recordIntra;
  end
else
  if ~isempty(RS.v_m)
    recordIntra = true;
    intraRecCellIDArr = IDMap.modelIDToCellIDMap(RS.v_m, :);
    numToRecordIntra = size(intraRecCellIDArr, 1);
    intraRecording = zeros(numToRecordIntra, RS.maxRecSamples);
    
    RecordingVars.intraRecCellIDArr = intraRecCellIDArr;
    RecordingVars.intraRecording = intraRecording;
  else
    recordIntra = false;
  end
  RecordingVars.recordIntra = recordIntra;
end

% for LFPs:
if RS.LFP
  if SS.parallelSim
    spmd
      p_neuronInThisLab = SS.neuronInLab == labindex();
      p_neuronInGroup = neuronInGroup(p_neuronInThisLab);
      LFPRecording = cell(TP.numGroups, 1);
      lineSourceModCell = cell(TP.numGroups, numElectrodes);
      if isfield(RS, 'LFPoffline') && RS.LFPoffline
        for iGroup = 1:TP.numGroups
          LFPRecording{iGroup} = zeros(sum(p_neuronInGroup==iGroup,1), ...
            NP(iGroup).numCompartments, RS.maxRecSamples);
        end
      else
        for iGroup = 1:TP.numGroups
          LFPRecording{iGroup} = zeros(numElectrodes, RS.maxRecSamples);
        end
      end
      for iGroup = 1:TP.numGroups
        for iElectrode = 1:numElectrodes
          lineSourceModCell{iGroup, iElectrode} = ...
            cell2mat(LSM(neuronInGroup==iGroup, iElectrode)')';
        end
      end
      RecordingVars.LFPRecording = LFPRecording;
      RecordingVars.lineSourceModCell = lineSourceModCell;
    end
  else
    LFPRecording = cell(TP.numGroups, 1);
    lineSourceModCell = cell(TP.numGroups, numElectrodes);
    if isfield(RS, 'LFPoffline') && RS.LFPoffline
      for iGroup = 1:TP.numGroups
        LFPRecording{iGroup} = zeros(sum(neuronInGroup==iGroup, 1), ...
          NP(iGroup).numCompartments, RS.maxRecSamples);
      end
    else
      for iGroup = 1:TP.numGroups
        LFPRecording{iGroup} = zeros(numElectrodes, RS.maxRecSamples);
      end
    end
    for iGroup = 1:TP.numGroups
      for iElectrode = 1:numElectrodes
        lineSourceModCell{iGroup, iElectrode} = ...
          cell2mat(LSM(neuronInGroup==iGroup, iElectrode)')';
      end
    end
    RecordingVars.LFPRecording = LFPRecording;
    RecordingVars.lineSourceModCell = lineSourceModCell;
  end % if parallelSim
  RS.numElectrodes = numElectrodes;
end % if LFP

% for spikes
if SS.parallelSim
  spmd
    RecordingVars.spikeRecording=cell(round(RS.maxRecSteps/SS.minDelaySteps),1);
  end
else
  RecordingVars.spikeRecording = cell(round(RS.maxRecSteps/SS.minDelaySteps),1);
end



