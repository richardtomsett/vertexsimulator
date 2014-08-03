function [distancesSquared] = ...
  calculateDistancesSquared(TP, iPre, potentialTargetXYZArr)

distancesSquared = zeros(size(potentialTargetXYZArr, 1), 3);

prePosition = TP.somaPositionMat(iPre, :);

distancesSquared(:,1) = (potentialTargetXYZArr(:,1) - prePosition(1)).^2;
distancesSquared(:,2) = (potentialTargetXYZArr(:,2) - prePosition(2)).^2;
distancesSquared(:,3) = (potentialTargetXYZArr(:,3) - prePosition(3)).^2;