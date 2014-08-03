function [S] = addGroupSpikesToSpikeList(NeuronModel,IDMap,S,iGroup,comCount)

groupSpikes = NeuronModel{iGroup}.spikes();
numSpikes = sum(groupSpikes);
if numSpikes ~= 0
  S.spikes(S.spikeCount+1:S.spikeCount+numSpikes) = ...
    IDMap.cellIDToModelIDMap{iGroup}(groupSpikes);
  S.spikeStep(S.spikeCount+1:S.spikeCount+numSpikes) = comCount;
  S.spikeCount = S.spikeCount + numSpikes;
end
