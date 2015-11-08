function [RS, SS] = setupSamplingConstants(RS, SS)

% Calculate sample rates and sample step times

msPerSecond = 1000;
warnings = {};
warn = 1;
stepsPerms = 1 / SS.timeStep;
if ~( stepsPerms == round(stepsPerms) )
  SS.timeStep = 1 / (2^nextpow2(stepsPerms));
  warnings{warn} = ['Incompatible timeStep supplied: ' num2str(SS.timeStep) ...
                    '. Setting timeStep to ' num2str(SS.timeStep) ' ms'];
  warn = warn + 1;
end

stepsPerSample = (msPerSecond / RS.sampleRate) / SS.timeStep;
maxSampleRate = msPerSecond / SS.timeStep;
floorSPS = floor(stepsPerSample);
if stepsPerSample < 1
  warnings{warn} = ['Sample rate higher than allowed by simulation timestep. ',...
                    'Sampling instead at ', num2str(maxSampleRate), 'Hz.'];
  warn = warn + 1;
  RS.sampleRate = maxSampleRate;
  stepsPerSample = 1;
elseif floorSPS ~= stepsPerSample
  RS.sampleRate = msPerSecond / (floorSPS * SS.timeStep);
  
  stepsPerSample = floorSPS;
  warnings{warn} = ['Sample rate incompatible with timeStep. ' ...
                    'Sampling instead at ' num2str(round(RS.sampleRate)) ' Hz'];
  warn = warn + 1;
end

samplesPerRecording = (RS.maxRecTime / msPerSecond) / (1/RS.sampleRate);
floorSPR = floor(samplesPerRecording);
disp(samplesPerRecording)
disp(floorSPR)
disp(floorSPR/RS.sampleRate * msPerSecond)
if floorSPR ~= samplesPerRecording
  RS.maxRecTime = floorSPR/RS.sampleRate * msPerSecond;
  warnings{warn} = ['Sample rate incompatible with maxRecTime. ' ...
                    'Setting maxRecTime instead to ' num2str(RS.maxRecTime) ' ms'];
  warn = warn + 1;
end

simulationSteps = ceil(SS.simulationTime / SS.timeStep);
maxRecSteps = round(RS.maxRecTime / SS.timeStep);

if maxRecSteps > simulationSteps
  warnings{warn} = ['maxRecTime set to be longer than the simulation time. ' ...
                    'Setting maxRecTime to equal the total simulation time.'];
  warn = warn + 1;
  maxRecSteps = simulationSteps;
  RS.maxRecTime = maxRecSteps * SS.timeStep;
end

overlap = mod(simulationSteps, maxRecSteps);
if overlap ~= 0
  warnings{warn} = ['WARNING: simulationTime is not divisible by maxRecTime. ' ...
                    'The last ' num2str(overlap*SS.timeStep) ...
                    ' ms of the simulation will not be saved.'];
  warn = warn+1;
end

RS.simulationSteps = simulationSteps;
RS.samplingSteps= stepsPerSample:stepsPerSample:simulationSteps;
RS.maxRecSteps = maxRecSteps;
RS.maxRecSamples = maxRecSteps / stepsPerSample;
RS.dataWriteSteps = maxRecSteps:maxRecSteps:simulationSteps;

for w=1:warn-1
  disp(warnings{w});
end