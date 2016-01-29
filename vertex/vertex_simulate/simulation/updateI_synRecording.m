function [RecVar] = ...
  updateI_synRecording(SynapseModel,RecVar,iGroup,recTimeCounter)

inGroup = RecVar.I_synRecCellIDArr(:, 2) == iGroup;
if sum(inGroup) ~= 0
  RecVar.I_synRecording(inGroup, :, recTimeCounter) = 0;
  for iSynType = 1:size(SynapseModel, 2)
    RecVar.I_synRecording(inGroup, iSynType, recTimeCounter) = ...
      sum(-SynapseModel{iGroup, iSynType}.I_syn(RecVar.I_synRecCellIDArr(inGroup, 1), :), 2);
  end
end
