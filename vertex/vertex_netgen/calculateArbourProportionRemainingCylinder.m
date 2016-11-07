function [p] = calculateArbourProportionRemainingCylinder( ...
  somaPosition, R, axonArborRadius, kernel)

memoryCutoff = 2500;

numPoints = 50000;%round((pi()*R*R)/20); % use Monte Carlo sampling to approximate overlap
numLayers = length(axonArborRadius);
p = ones(size(somaPosition,1), numLayers);
for iLayer = 1:numLayers
  if strcmpi(kernel, 'gaussian') || strcmpi(kernel, 'g')
    x = randn(1,numPoints).*axonArborRadius(iLayer);
    y = randn(1,numPoints).*axonArborRadius(iLayer);
  elseif strcmpi(kernl, 'uniform') || strcmpi(kernel, 'u')
    t = 2*pi*rand(1,numPoints);
    r = axonArborRadius(iLayer)*sqrt(rand(1,numPoints));
    x = r.*cos(t);
    y = r.*sin(t);
  end
  if size(somaPosition,1) <= memoryCutoff
    steps = [0, size(somaPosition,1)];
  else
    steps = 0:memoryCutoff:size(somaPosition,1);
    if steps(end) ~= size(somaPosition,1)
      steps = [steps, size(somaPosition,1)];
    end
  end
  for iStep = 1:length(steps)-1
    iX = bsxfun(@plus,somaPosition(steps(iStep)+1:steps(iStep+1), 1), x);
    iY = bsxfun(@plus,somaPosition(steps(iStep)+1:steps(iStep+1), 2), y);
    xin = iX.^2 + iY.^2 <= R*R;
    yin = iX.^2 + iY.^2 <= R*R;
    p(steps(iStep)+1:steps(iStep+1),iLayer) = ...
        sum(xin & yin, 2) ./ numPoints;
  end
end
