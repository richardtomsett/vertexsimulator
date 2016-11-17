function [spikeTimes, c] = distributedGenerator(N_0, N, rate, simTime, timeStep)
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

c = ((N_0 - N) / (1 - N))^2;

%0.5*N*rate*weight^2*tau*(1 + ( (N-1)/(N+sqrt(c)*(1-N)) ))
