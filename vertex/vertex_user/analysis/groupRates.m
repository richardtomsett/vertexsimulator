function rates = groupRates(Results, tmin, tmax)
%GROUPRATES Calculate the average firing rate of the neurons in each group.
%   RATES = GROUPRATES(Results) calculates the mean firing rate of the neurons
%   in each group in the simulation over the whole simulation time (i.e.
%   the total number of spikes fired by neurons in the group divided by the
%   number of neurons in the group and by the simulation time). Rates are
%   calculated in Hz.
%
%   RATES = GROUPRATES(Results, tmin) does the same, but calculates the
%   rates ignoring the first tmin milliseconds of the simulation. The time
%   interval for calculating the rate is then the total simulation time
%   minus tmin.
%
%   RATES = GROUPRATES(Results, tmin, tmax) does the same, but calculates the
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

neuronInGroup = createGroupsFromBoundaries( ...
  Results.params.TissueParams.groupBoundaryIDArr);

spikes = Results.spikes(Results.spikes(:,2)>=tmin & ...
                        Results.spikes(:,2)<=tmax, :);
rates = zeros(Results.params.TissueParams.numGroups, 1);
tinterval = (tmax - tmin)/1000;

disp(['Mean firing rate for each group over the interval ' num2str(tmin) '-' ...
     num2str(tmax) 'ms: ']);
for iGroup = 1:Results.params.TissueParams.numGroups
  groupSpikes = sum(neuronInGroup(spikes(:,1))==iGroup);
  groupSize = Results.params.TissueParams.groupBoundaryIDArr(iGroup+1) - ...
              Results.params.TissueParams.groupBoundaryIDArr(iGroup);
  rates(iGroup) = groupSpikes ./ (groupSize * tinterval);
  disp(['Group ' num2str(iGroup) ': ' num2str(rates(iGroup)) ' Hz']);
end
