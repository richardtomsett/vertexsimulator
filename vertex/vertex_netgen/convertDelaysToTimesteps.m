function [targetDelaySteps,maxSteps,minSteps] = ...
  convertDelaysToTimesteps(SS,targetDelays,maxSteps,minSteps)

% convert delays to timesteps
targetDelaySteps = uint16(ceil(targetDelays ./ SS.timeStep));

if max(double(targetDelaySteps)) > maxSteps
  maxSteps = double(max(targetDelaySteps));
end
if min(double(targetDelaySteps)) < minSteps
  minSteps = min(double(targetDelaySteps));
end