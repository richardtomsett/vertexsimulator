function [figureHandle] = plotSpikeRaster(Results, pars)
%PLOTSPIKERASTER Creates a spike raster plot.
%   PLOTSPIKERASTER(RESULTS) Creates a spike raster plot given a RESULTS
%   structure loaded using the loadResults() function.
%
%   PLOTSPIKERASTER(RESULTS, PARS) adjusts the plot based on settings in the
%   input PARS structure. Fields that can be specified in PARS are: colors,
%   groupBoundaryLines, figureID, title, xlabel, ylabel and zlabel.
%   All are optional.
%
%   - colors is a cell array, with each cell containing the colour to use
%   for the marker for that group (either a character or  an array of RGB 
%   values - see Matlab plotting documentation)
%   - groupBoundaryLines is either a single character or an array of RGB
%   values to specify the colour of horizontal lines to plot to mark
%   the boundaries of the neuron groups
%   - neuronsToPlot is a list of the neuron IDs you want to plot the spikes
%   - tmin and tmax are used to set the extent of the x- (time) axis, in ms
%   of. Neurons not in this list will not have their spikes plotted.
%   - figureID specifies the figure number to use
%   - title, xlabel, ylabel and zlabel are strings used to provide a title,
%   x-axis label, y-axis label and z-axis label for the figure
%   - markerSize is the size of the markers to mark the spikes (in usual
%   Matlab size units)
%
%   FIGUREHANDLE = PLOTSPIKERASTER(RESULTS, PARS) also returns the handle ID of 
%   created figure.

if nargin == 1
  pars = struct();
end

if ~isfield(pars, 'colors')
  pars.colors = cell(Results.params.TissueParams.numGroups, 1);
  for iGroup = 1:Results.params.TissueParams.numGroups
    pars.colors{iGroup} = 'k';
  end
elseif length(pars.colors) ~= Results.params.TissueParams.numGroups
  errMsg = 'List of colours does not match the number of neuron groups';
  error('vertex:plotSpikeRaster:colourArrayError', errMsg);
end

if ~isfield(pars, 'figureID')
  figureHandle = figure;
  hold on;
else
  figureHandle = figure(pars.figureID);
  hold on;
end

if ~isfield(pars, 'neuronsToPlot')
  pars.neuronsToPlot = 1:Results.params.TissueParams.N;
else
  pars.neuronsToPlot = sort(pars.neuronsToPlot);
end

if ~isfield(pars, 'tmin')
  pars.tmin = 0;
end

if ~isfield(pars, 'tmax')
  pars.tmax = Results.params.SimulationSettings.simulationTime;
end

if ~isfield(pars, 'markerSize')
  pars.markerSize = 8;
end

neuronInGroup = createGroupsFromBoundaries( ...
  Results.params.TissueParams.groupBoundaryIDArr);

for iGroup = 1:Results.params.TissueParams.numGroups
  toPlot = ismember(Results.spikes(:,1), pars.neuronsToPlot) & ...
           neuronInGroup(Results.spikes(:,1))==iGroup;
  plot(Results.spikes(toPlot, 2), Results.spikes(toPlot, 1), ...
       '.', 'Color', pars.colors{iGroup}, 'MarkerSize', ...
         pars.markerSize);
  if isfield(pars, 'groupBoundaryLines') && ...
     iGroup < Results.params.TissueParams.numGroups
    gbid = Results.params.TissueParams.groupBoundaryIDArr(iGroup+1);
    plot([0, round(max(Results.spikes(:,2)))], [gbid, gbid], ...
         'LineWidth', 1, 'Color', pars.groupBoundaryLines);
  end
end
for iGroup = 1:Results.params.TissueParams.numGroups
  if isfield(pars, 'groupBoundaryLines') && ...
     iGroup < Results.params.TissueParams.numGroups
    gbid = Results.params.TissueParams.groupBoundaryIDArr(iGroup+1);
    plot([0, round(max(Results.spikes(:,2)))], [gbid, gbid], ...
         'LineWidth', 1, 'Color', pars.groupBoundaryLines);
  end
end
hold off

axis([pars.tmin pars.tmax ...
      0-(Results.params.TissueParams.N/100) ...
      Results.params.TissueParams.N+(Results.params.TissueParams.N/100)]);

set(gcf,'color','w');
set(gca,'YDir','reverse');
set(gca,'TickDir','out');

if isfield(pars, 'FontSize')
  fsize = pars.FontSize;
else
  fsize = 16;
end

if isfield(pars, 'title')
  title(pars.title, 'FontSize', fsize);
end
if isfield(pars, 'xlabel')
  xlabel(pars.xlabel, 'FontSize', fsize);
end
if isfield(pars, 'ylabel')
  ylabel(pars.ylabel, 'FontSize', fsize);
end

set(gca, 'FontSize', fsize);