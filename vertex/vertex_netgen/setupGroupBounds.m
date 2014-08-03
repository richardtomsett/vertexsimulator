function [SS, TP, NP] = setupGroupBounds(NP, SS, TP)
%%

% Get required values from TP
density = TP.neuronDensity;
npp = [NP.modelProportion];

% Scale to make sure model proportions sum to 1
if sum(npp) ~= 1
  disp('WARNING: group model proportions do not sum to 1.')
  disp('Continuing by scaling all proportions to sum to 1.')
  npp = npp./sum(npp);
end

for iGroup = 1:length(NP)
  NP(iGroup).modelProportion = npp(iGroup);
end

if isfield(TP, 'X') && ...
   isfield(TP, 'Y') && ...
   isfield(TP, 'Z')
  X = TP.X;
  Y = TP.Y;
  Z = TP.Z;
  N = round(density*X*Y*Z / 10^9);
  TP.sliceShape = 'cuboid';
elseif isfield(TP, 'R') && ...
       isfield(TP, 'Z')
  R = TP.R;
  Z = TP.Z;
  N = round(density*pi*R^2*Z / 10^9);
  TP.sliceShape = 'cylinder';
else
  error('vertex:setupGroupBounds:modelShapeUndefined', ...
        'You must specify X, Y and Z, or R and Z, in the tissue parameters');
end
TP.N = N;

% integer sizes
if N <= intmax('uint16')
  SS.nIDintSize = 'uint16';
else
  SS.nIDintSize = 'uint32';
end

% Create N Neurons (IDs are the array indices) according to the
% distribution in npp
numGroups = length(NP);
TP.numGroups = numGroups;
groupSizeArr = zeros(numGroups, 1);
groupBoundaryIDArr = zeros(numGroups+1, 1);
for iGroup = 1:numGroups
  groupSizeArr(iGroup) = round(npp(iGroup) * N);
end

%take care of rounding issues
while sum(groupSizeArr) > N
  groupSizeArr(numGroups) = groupSizeArr(numGroups) - 1;
end
while sum(groupSizeArr) < N
  groupSizeArr(numGroups) = groupSizeArr(numGroups) + 1;
end
for iGroup = 1:numGroups
  groupBoundaryIDArr(iGroup+1) = sum(groupSizeArr(1:iGroup));
end

% Store calculated info
TP.groupBoundaryIDArr = groupBoundaryIDArr;
TP.groupSizeArr = groupSizeArr;