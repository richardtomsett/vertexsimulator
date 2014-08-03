function [RecVar] = ...
  updateIntraRecording(NeuronModel,RecVar,iGroup,recTimeCounter)

inGroup = RecVar.intraRecCellIDArr(:, 2) == iGroup;
if sum(inGroup) ~= 0
  RecVar.intraRecording(inGroup, recTimeCounter) = ...
    NeuronModel{iGroup}.v(RecVar.intraRecCellIDArr(inGroup, 1), 1);
end
