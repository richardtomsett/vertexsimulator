function [RecVar] = ...
  updateI_synRecording(SynapseModel,synMap,RecVar,iPostGroup,recTimeCounter)

inGroup = RecVar.I_synRecCellIDArr(:, 2) == iPostGroup;
if sum(inGroup) ~= 0
  RecVar.I_synRecording(inGroup, :, recTimeCounter) = 0;
  for iSynType = 1:size(SynapseModel, 2)
    if ~isempty(SynapseModel{iPostGroup, synMap{iPostGroup}(iSynType)})
      RecVar.I_synRecording(inGroup, iSynType, recTimeCounter) = ...
        sum(-SynapseModel{iPostGroup, synMap{iPostGroup}(iSynType)}.I_syn(RecVar.I_synRecCellIDArr(inGroup, 1), :), 2);
    end
  end
end