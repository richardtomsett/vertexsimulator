function axonDelays =...
  calculateAxonDelays(CP, iPreGroup, chosenTargets, distancesSquared)

if ~isfield(CP(iPreGroup), 'delay') || isempty(CP(iPreGroup).delay)
  CP(iPreGroup).delay = 'distance';
end

if strcmp(CP(iPreGroup).delay, 'distance')
  conductionSpeed = CP(iPreGroup).axonConductionSpeed*1000;
  axonDelays = (sqrt(distancesSquared(chosenTargets, 1) + ...
                    distancesSquared(chosenTargets, 2) + ...
                    distancesSquared(chosenTargets, 3)) ./ ...
                    conductionSpeed) + CP(iPreGroup).synapseReleaseDelay;
elseif strcmp(CP(iPreGroup).delay, 'constant')
  axonDelays = zeros(size(chosenTargets)) + CP(iPreGroup).synapseReleaseDelay;
else
  error('vertex:calculateAxonDelays:nonexistentDelayModel', ...
        ['The delay model you defined for group ' num2str(iPreGroup) ...
        ' (' CP(iPreGroup.delay) ' does not exist']);
end