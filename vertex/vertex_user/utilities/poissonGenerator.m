function spikeTimes = poissonGenerator(N, rate, simTime, timeStep)
%POISSONGENERATOR Generate spike trains according to distributed
%generator algorithm (Rudolph & Destexhe, 2006)
%
%   spikeTimes = poissonGenerator(N, rate, simTime, timeStep)
%   generates poisson spike trains with the specified parameters, and
%   returns them in a format suitable for loading in VERTEX simulations (by
%   specifying a neuron population of model type 'loadtpiketimes').
%
%   N spike trains of mean rate RATE (Hz) and length SIMTIME (ms) are
%   created.

if (nargin ~= 4)
  errMsg = ['You must supply five arguments: N, rate, simTime,', ... 
            'timeStep'];
  error('vertex:distributedGenerator:WrongNumberINputArgs', errMsg);
elseif ( ~checkNumericPositive(N) || ...
         ~checkNumericPositive(rate) || ...
         ~checkNumericPositive(simTime) || ...
         ~checkNumericPositive(timeStep))
  errMsg = 'All parameters must be numbers greater than 0';
  error('vertex:distributedGenerator:checkNumericPositive', errMsg);
end


numSteps = round(simTime / timeStep);
spikeOn = rand(N, numSteps) <= (rate/1000)*timeStep;

spikeTimes = cell(N,1);
for iN = 1:N
  spikeTimes{iN} = find(spikeOn(iN,:)) .* timeStep;
end
