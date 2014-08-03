function [RS, SS] = setupSamplingConstants(RS, SS)

% Calculate sample rates and sample step times

msPerSecond = 1000;

stepsPerms = 1 / SS.timeStep;
if ~( stepsPerms == round(stepsPerms) )
  disp(['Incompatible timeStep supplied: ' num2str(SS.timeStep)]);
  SS.timeStep = 1 / (2^nextpow2(stepsPerms));
  disp(['Setting timeStep to ' num2str(SS.timeStep) ' ms']);
end

stepsPerSample = (msPerSecond / RS.sampleRate) / SS.timeStep;
maxSampleRate = msPerSecond / SS.timeStep;
fsps = floor(stepsPerSample);
if stepsPerSample < 1
  disp(['Sample rate higher than allowed by simulation timestep.',...
       ' Simulating at ', num2str(maxSampleRate), 'Hz.']);
  RS.sampleRate = maxSampleRate;
  stepsPerSample = 1;
elseif fsps ~= stepsPerSample
  RS.sampleRate = msPerSecond / (fsps * SS.timeStep);
  stepsPerSample = fsps;
  disp('Sample rate incompatible with timeStep')
  disp(['Sampling instead at ' num2str(round(RS.sampleRate)) ' Hz']);
end

simulationSteps = ceil(SS.simulationTime / SS.timeStep);
maxRecSteps = round(RS.maxRecTime / SS.timeStep);

if maxRecSteps > simulationSteps
  disp('maxRecTime set to be longer than the simulation time.')
  disp('Setting maxRecTime to equal the total simulation time.')
  maxRecSteps = simulationSteps;
  RS.maxRecTime = maxRecSteps * SS.timeStep;
end

overlap = mod(simulationSteps, maxRecSteps);
if overlap ~= 0
  disp(' ');
  disp('WARNING: simulationTime is not divisible by maxRecTime.');
  disp(['The last ' num2str(overlap*SS.timeStep) ...
        ' ms of the simulation will not be saved.']);
  disp(' ');
end

RS.simulationSteps = simulationSteps;
RS.samplingSteps= stepsPerSample:stepsPerSample:simulationSteps;
RS.maxRecSteps = maxRecSteps;
RS.maxRecSamples = maxRecSteps / stepsPerSample;
RS.dataWriteSteps = maxRecSteps:maxRecSteps:simulationSteps;