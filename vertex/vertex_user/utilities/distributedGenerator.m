function [spikeTimes, pairwise_corrcoeff] = ...
  distributedGenerator(N_0, N, rate, simTime, timeStep)
%DISTRIBUTEDGENERATOR Generate spike trains according to distributed
%generator algorithm (Rudolph & Destexhe, 2006)
%
%   [spikeTimes, pairwise_corrcoeff] = distributedGenerator(N_0, N, rate, simTime, timeStep)
%   generates spike trains according to the distributed generator algorithm
%   with the specified parameters, and returns them in a format suitable
%   for loading in VERTEX simulations (by specifying a neuron population of
%   model type 'loadtpiketimes').
%
%   N spike trains of mean rate RATE (Hz) and length SIMTIME (ms) are 
%   created.
%   
%   The algorithm first generates N_0 poisson spike trains (N_0 <= N). Then
%   for each time step, a random sample (with replacement) of size N is
%   taken from the N_0 spike trains at that time step. This creates a final
%   set of N spike trains that are correlated with instantaneous pairwise
%   correlation coefficient, PAIRWISE_CORRCOEFF = 1 / N_0.

if (nargin ~= 5)
  errMsg = ['You must supply five arguments: N_0, N, rate, simTime,', ... 
            'timeStep'];
  error('vertex:distributedGenerator:WrongNumberINputArgs', errMsg);
elseif ( ~checkNumericPositive(N_0) || ...
         ~checkNumericPositive(N) || ...
         ~checkNumericPositive(rate) || ...
         ~checkNumericPositive(simTime) || ...
         ~checkNumericPositive(timeStep))
  errMsg = 'All parameters must be numbers greater than 0';
  error('vertex:distributedGenerator:checkNumericPositive', errMsg);
end

numSteps = round(simTime / timeStep);
pool = rand(N_0, numSteps) <= (rate/1000)*timeStep;

spikeOn = zeros(N, numSteps);
for iStep = 1:numSteps
  chosen = randi(N_0,N,1);
  spikeOn(:,iStep) = pool(chosen,iStep);
end

spikeTimes = cell(N,1);
for iN = 1:N
  spikeTimes{iN} = find(spikeOn(iN,:)) .* timeStep;
end

pairwise_corrcoeff = 1 / N_0;
