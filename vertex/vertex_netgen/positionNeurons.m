function [TissueProperties] = positionNeurons(NeuronArr, TissueProperties)

layerBoundaryArr  = TissueProperties.layerBoundaryArr;
layerThicknessArr = abs(diff(layerBoundaryArr));
groupBoundaryIDArr = TissueProperties.groupBoundaryIDArr;
stripBoundaryIDArr = TissueProperties.stripBoundaryIDArr;
numGroups = TissueProperties.numGroups;
numStrips = TissueProperties.numStrips;
sliceShape = TissueProperties.sliceShape;
groupSizeArr = TissueProperties.groupSizeArr;
N = TissueProperties.N;
if strcmp(sliceShape, 'cylinder')
  R = TissueProperties.R;
elseif strcmp(sliceShape, 'cuboid')
  X = TissueProperties.X;
  Y = TissueProperties.Y;
end
Z = TissueProperties.Z;

% Generate neuron positions
somaPositionMat = zeros(N, 4);
somaPositionMat(:,4) = 1:N;

for iGroup = 1:numGroups;
maxZOverlap = TissueProperties.maxZOverlap;
  % List of all neuron IDs in this group
  groupInd = ...
    (groupBoundaryIDArr(iGroup) + 1):groupBoundaryIDArr(iGroup + 1);
  iGroupLayer = NeuronArr(iGroup).somaLayer;
  
  if strcmp(sliceShape, 'cuboid')
    for iStrip = 1:numStrips
      % List of all neuron IDs in this group in this strip
      iStripAdjust = iStrip + ((iGroup - 1) * numStrips);
      stripInd = (stripBoundaryIDArr(iStripAdjust) + 1): ...
        stripBoundaryIDArr(iStripAdjust + 1);
      % Set x-positions randomly within strip boundaries
      somaPositionMat(stripInd, 1) = rand(length(stripInd), 1) * ...
        (X / numStrips) + ((iStrip - 1) * (X / numStrips));
    end
    % Set y-positions randomly within slice boundaries
    somaPositionMat(groupInd, 2) = rand(groupSizeArr(iGroup), 1) * Y;

  % position in cylinder. This is "inelegant" mathematically, but actually
  % performs better time-wise than doing it the "elegant" way...
  elseif strcmp(sliceShape, 'cylinder')
%     numInStrip = zeros(numStrips,1);
%     for iStrip = 1:numStrips
%       numInStrip = Rstrip(iStrip)^2 * pi * numInGroup(iGroup);
%       if iStrip > 1
%         numInStrip = numInStrip - Rstrip(iStrip-1) * pi * numInGroup(iGroup);
%       end
%     end
    spm = somaPositionMat(groupInd,1:2);
    spm(:, 1) = (rand(length(groupInd), 1) * R*2) - R;
    spm(:, 2) = (rand(length(groupInd), 1) * R*2) - R;
    toMove = spm(:, 1).^2 + spm(:, 2).^2 > R^2;
    while sum(toMove) > 0
      spm(toMove, 1) = (rand(sum(toMove), 1) * R*2) - R;
      spm(toMove, 2) = (rand(sum(toMove), 1) * R*2) - R;
      toMove = spm(:, 1).^2 + spm(:, 2).^2 > R^2;
    end
    if numStrips > 1
      count=groupBoundaryIDArr(iGroup);
      Rstrip = R/numStrips:R/numStrips:R;
      stripInd = cell(numStrips,1);
      stripInd{1} = spm(:, 1).^2 + spm(:, 2).^2 <= Rstrip(1)^2;
      somaPositionMat(count+1:count+sum(stripInd{1},1),1:2) = ...
        spm(stripInd{1},1:2);
      count = count+sum(stripInd{1},1);
      iStripAdjust = 2 + ((iGroup - 1) * numStrips);
      TissueProperties.stripBoundaryIDArr(iStripAdjust) = count;
      for iStrip = 2:numStrips
        stripInd{iStrip} = spm(:,1).^2 + spm(:,2).^2<=Rstrip(iStrip)^2 &...
                           spm(:,1).^2 + spm(:,2).^2> Rstrip(iStrip-1)^2;
        somaPositionMat(count+1:count+sum(stripInd{iStrip}),1:2) = ...
          spm(stripInd{iStrip},1:2);
        count = count + sum(stripInd{iStrip});
        iStripAdjust = iStrip+1 + ((iGroup - 1) * numStrips);
        TissueProperties.stripBoundaryIDArr(iStripAdjust) = count;
      end
    end
    
  end
  
  % Set z-positions randomly within layer boudaries AND so that neuron
  % compartments do not go further than maxZOverlap outside the slice Z
  % boundaries
  if maxZOverlap(1) < 0
    maxZOverlap(1) = 100000;
  end
  if maxZOverlap(2) < 0
    maxZOverlap(2) = 100000;
  end
  if NeuronArr(iGroup).numCompartments == 1
    maxZ = Z;
    maxZOverlap = [0 0];
  else
    maxZ = Z + maxZOverlap(1) - ...
      max(NeuronArr(iGroup).compartmentZPositionMat(:));
  end
  if maxZ < layerBoundaryArr(iGroupLayer)
    layerBoundaryArr(iGroupLayer) = maxZ;
    layerThicknessArr = abs(diff(layerBoundaryArr));
    %TissueProperties.layerBoundaryArr = layerBoundaryArr;
  end
  if -maxZOverlap(2) > layerBoundaryArr(iGroupLayer + 1)
    layerBoundaryArr(end) = maxZOverlap(2);
    layerThicknessArr = abs(diff(layerBoundaryArr));
    %TissueProperties.layerBoundaryArr = layerBoundaryArr;
  end
  somaPositionMat(groupInd,3) = layerBoundaryArr(iGroupLayer) - ...
    rand(groupSizeArr(iGroup), 1) * layerThicknessArr(iGroupLayer);
end

TissueProperties.somaPositionMat = somaPositionMat;
TissueProperties.rotationAngleMat = 2 * pi * rand(N, 3);