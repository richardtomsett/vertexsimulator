function [] = resetRandomSeed(s)
%RESETRANDOMSEED Resets the random number generator seed.
%   RESETRANDOMSEED() resets the random number generator seed to the
%   default value, 123. If running in parallel mode, the random number
%   generator seed will be 123 + numlabs()
%
%   RESETRANDOMSEED(s) resets the random number generator seed to the value
%   specified by s. s should be a positive integer. If running in parallel
%   mode, the random generator seed will be s + numlabs()

if nargin == 1
  if isnumeric(s)
    SS.randomSeed = round(abs(s));
  else
    error('vertex:resetRandomSeed:nonNumericInput', ...
          'Input to resetRandomSeed() must be numeric');
  end
else
  SS.randomSeed = 123;
end

v = ver;
if ~any(strcmp('Parallel Computing Toolbox', {v.Name}))
  SS.parallelSim = false;
else
  if getNumOpenLabs() == 0
    SS.parallelSim = false;
  else
    SS.parallelSim = true;
  end
end

setRandomSeed(SS);