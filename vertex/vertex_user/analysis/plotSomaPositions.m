function figureHandle = plotSomaPositions(TP, pars)
%PLOTSOMAPOSITIONS Plots the positions of the neurons' soma compartments.
%   PLOTSOMAPOSITIONS(TP) creates a 3D plot of the soma positions of all
%   neurons in the simulation. TP is the TissueParams structure in the
%   PARAMS structure returned by INITNETWORK.
%
%   PLOTSOMAPOSITIONS(TP, PARS) adjusts the plot based on settings in the
%   input PARS structure. Fields that can be specified in PARS are: toPlot,
%   markers, colors, figureID, title, xlabel, ylabel and zlabel. All are
%   optional.
%
%   - toPlot is a list of the neuron IDs that you want to plot
%   - markers is a cell array of length TP.numGroups - each cell should
%   contain the character representing the marker you want to use for the 
%   corresponding neuron group (see Matlab plotting documentation for details
%   on the available markers)
%   - colors is a cell array, with each cell containing
%   the colour to use for the marker for that group (either a character or
%   an array of RGB values - see Matlab plotting documentation)
%   - figureID specifies the figure number to use
%   - title, xlabel, ylabel and zlabel are strings used to provide a title,
%   x-axis label, y-axis label and z-axis label for the figure
%
%   FIGUREHANDLE = PLOTSOMAPOSITIONS(TP, PARS) also returns the handle ID of the
%   created figure.

if nargin == 1
  pars = struct();
end

if ~isfield(pars, 'toPlot')
  pars.toPlot = 1:TP.N;
elseif max(pars.toPlot) > TP.N
  errMsg = 'Indeces in toPlot must not exceed number of neurons';
  error('vertex:plotSomaPositions:plotIndexOutOfBounds', ...
        errMsg);
end

if isfield(pars, 'markers')
  if length(pars.markers)~=TP.numGroups
    errMsg = 'List of markers does not match the number of neuron groups';
    error('vertex:plotSomaPositions:incorrectMarkers', ...
          errMsg);
  end
else
  pars.markers = cell(TP.numGroups, 1);
  for iMarker = 1:TP.numGroups
    pars.markers{iMarker} = 'o';
  end
end

if isfield(pars, 'colors')
  if length(pars.colors)~=TP.numGroups
    errMsg = 'List of colours does not match the number of neuron groups';
    error('vertex:plotSomaPositions:incorrectColors', errMsg);
  end
else
  pars.colors = cell(TP.numGroups, 1);
  for iColor = 1:TP.numGroups
    pars.colors{iColor} = 'k';
  end
end

if isfield(pars, 'figureID')
  figureHandle = figure(pars.figureID);
else
  figureHandle = figure();
end
hold on;

neuronInGroup = createGroupsFromBoundaries(TP.groupBoundaryIDArr);

for iGroup=1:TP.numGroups
  inGroup = neuronInGroup == iGroup & ...
            ismember(TP.somaPositionMat(:,4), pars.toPlot);
  plot3(TP.somaPositionMat(inGroup, 1), ...
        TP.somaPositionMat(inGroup, 2), ...
        TP.somaPositionMat(inGroup, 3), ...
        pars.markers{iGroup},'MarkerSize', 8, ...
        'MarkerEdgeColor', pars.colors{iGroup}, ...
        'MarkerFaceColor', pars.colors{iGroup});
end

hold off

set(gcf,'color','w');
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
if isfield(pars, 'zlabel')
  zlabel(pars.zlabel, 'FontSize', fsize);
end

set(gca, 'FontSize', fsize);

view([0, 0]);