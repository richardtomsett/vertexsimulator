function [RecVar] = ...
  updateLFPRecording(RS,NeuronModel,RecVar,iGroup,recTimeCounter)

if isfield(RS, 'LFPoffline') && RS.LFPoffline
  RecVar.LFPRecording{iGroup}(:,:,p_recTimeCounter) = NeuronModel{iGroup}.I_ax;
else
  for iElectrode = 1:RS.numElectrodes
    RecVar.LFPRecording{iGroup}(iElectrode,recTimeCounter) = ...
      sum(sum( (NeuronModel{iGroup}.I_ax) .* ...
      RecVar.lineSourceModCell{iGroup, iElectrode} ));
  end
end