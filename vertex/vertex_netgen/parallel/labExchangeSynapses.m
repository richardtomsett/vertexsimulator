function [p_synapsesArr] = ...
  labExchangeSynapses(TP, SS, cpexLoopTotal, partnerLab, p_postLabConnectionCell)

% Do a complete pairwise exchange, to store connection information on the
% postsynaptic lab (see Tam & Wang, 2000)
if labindex == 1
  disp('Exchanging synapse information between labs...');
end
p_postsynapticConnections = cell(numlabs(), 1);
p_postsynapticConnections{labindex()} = p_postLabConnectionCell{labindex()};

for iLab = 1:cpexLoopTotal
  partner = partnerLab(iLab);
  if partner == -1
    % idle
  else
    p_postsynapticConnections{partner} = ...
      labSendReceive(partner, partner, ...
                     p_postLabConnectionCell{partner});
  end

  if labindex() == 1
    disp([num2str(iLab) ' of ' num2str(cpexLoopTotal) ' exchanges ...']);
  end
end
labBarrier();

p_synapsesArr = cell(TP.N, 3);
for iLab = 1:numlabs()
  preFromiLab = ~cellfun(@isempty, p_postsynapticConnections{iLab}(:, 1));
  p_synapsesArr(preFromiLab,:) = p_postsynapticConnections{iLab}(preFromiLab,:);
  p_postsynapticConnections{iLab} = [];
end
if labindex() == 1
  disp('Synapse information exchange complete!');
end

% make sure empty synapse lists are of correct type
for iN = 1:TP.N
  if isempty(p_synapsesArr{iN,1})
    p_synapsesArr(iN, :) = {zeros(0,SS.nIDintSize), ...
                            zeros(0,'uint8'), ...
                            zeros(0,'uint16')};
  end
end