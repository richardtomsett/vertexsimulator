function spikeTimes = poissonGenerator(N, rate, simTime, timeStep)
numSteps = round(simTime / timeStep);
spikeOn = rand(N, numSteps) <= (rate/1000)*timeStep;

spikeTimes = cell(N,1);
for iN = 1:N
  spikeTimes{iN} = find(spikeOn(iN,:)) .* timeStep;
end
