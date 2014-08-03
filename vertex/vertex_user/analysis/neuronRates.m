function rates = neuronRates(Results, tmin, tmax)
%NEURONRATES calculates the mean firing rate of each neuron.
%   RATES = NEURONRATES(Results) calculates the firing rate of each neuron
%   in the simulation over the whole simulation time (i.e. the total number of
%   spikes fired by each neuron divided by the simulation time). Rates are
%   calculated in Hz.
%
%   RATES = NEURONRATES(Results, tmin) does the same, but calculates the
%   rates ignoring the first tmin milliseconds of the simulation. The time
%   interval for calculating the rate is then the total simulation time
%   minus tmin.
%
%   RATES = NEURONRATES(Results, tmin, tmax) does the same, but calculates the
%   rates ignoring spikes before tmin milliseconds and after tmax
%   milliseconds. The time interval for calculating the rate is then tmax -
%   tmin.

if nargin == 1
  tmin = 0;
  tmax = Results.params.SimulationSettings.simulationTime;
elseif nargin == 2
  tmax = Results.params.SimulationSettings.simulationTime;
end
if tmin >= tmax
  error('vertex:firingRates:timeIntervalError', ...
        'tmin must be less than tmax');
end
spikes = Results.spikes(Results.spikes(:,2)>=tmin & ...
                        Results.spikes(:,2)<=tmax, :);
rates = zeros(Results.params.TissueParams.N, 1);
tinterval = (tmax - tmin)/1000;

for iN = 1:Results.params.TissueParams.N
  disp(iN)
  neuronSpikes = sum(spikes(:,1)==iN);
  rates(iN) = neuronSpikes ./ tinterval;
end
