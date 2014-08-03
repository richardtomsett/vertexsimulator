function [optOUpars] = precalculateOUpars(NeuronArr, timeStep)

% Random input parameters

membraneAreaRatio = (NeuronArr.compartmentLengthArr .* ...
                     NeuronArr.compartmentDiameterArr) ./ ...
                     sum(NeuronArr.compartmentLengthArr .* ...
                     NeuronArr.compartmentDiameterArr);
                   
meanCurrent = NeuronArr.Input.meanCurrent;
tau_k = NeuronArr.Input.tau_k;
stdCurrent = NeuronArr.Input.stdCurrent;


if length(meanCurrent) == length(membraneAreaRatio)
  optOUpars.meanCurrent = meanCurrent;
else
  optOUpars.meanCurrent = meanCurrent .* membraneAreaRatio;
end
if length(tau_k) == length(membraneAreaRatio)
  optOUpars.expMinusLambdaDelta_t = 1 - exp(-timeStep ./ tau_k);
else
  optOUpars.expMinusLambdaDelta_t = ...
    1 - exp(-timeStep ./ (tau_k .* ones(size(membraneAreaRatio))));
end

if length(stdCurrent) == length(membraneAreaRatio)
  optOUpars.dWtconstTimesStd = ...
    sqrt(1 - exp(-(2*timeStep) ./ tau_k)) .* stdCurrent;
else
  optOUpars.dWtconstTimesStd = ...
    sqrt(1 - exp(-(2*timeStep)./tau_k)) .* (stdCurrent.*membraneAreaRatio);
end
