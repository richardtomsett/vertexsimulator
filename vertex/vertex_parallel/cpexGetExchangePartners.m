function [cpexLoopTotal, partnerLab] = cpexGetExchangePartners()

% Precalculate lab partner order for data exchange

numLabs = getNumOpenLabs();

if mod(numLabs, 2) ~= 0
  cpexLoopTotal = numLabs;
else
  cpexLoopTotal = numLabs - 1;
end

spmd  
  partnerLab = zeros(cpexLoopTotal, 1);
  for iLab = 1:cpexLoopTotal
    partnerLab(iLab) = cpexEdgeColour(iLab, labindex(), numlabs());
  end
  if isempty(find(partnerLab == -1, 1))
    cpexLoopTotal = cpexLoopTotal + 1;
    partnerLab(end + 1) = -1;
  end
end