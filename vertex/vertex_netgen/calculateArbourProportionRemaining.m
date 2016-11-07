function [p] = calculateArbourProportionRemaining( ...
  somaPosition, X, Y, axonArborRadius, kernel)

if strcmpi(kernel, 'gaussian') || strcmpi(kernel, 'g')
  lx1 = -somaPosition(:, 1);
  lx2 = X - somaPosition(:, 1);
  ly1 = -somaPosition(:, 2);
  ly2 = Y - somaPosition(:, 2);
  p = ( ...
    (erf(bsxfun(@rdivide, lx1, (sqrt(2) .* axonArborRadius))) - ...
    erf(bsxfun(@rdivide, lx2, (sqrt(2) .* axonArborRadius)))) .* ...
    (erf(bsxfun(@rdivide, ly1, (sqrt(2) .* axonArborRadius))) - ...
    erf(bsxfun(@rdivide, ly2, (sqrt(2) .* axonArborRadius)))) ) ./ 4;
elseif strcmpi(kernel, 'uniform') || strcmpi(kernel, 'u')
  memoryCutoff = 2500;
  numPoints = 50000;%X*Y/20; % use Monte Carlo sampling to approximate overlap
  numLayers = length(axonArborRadius);
  p = ones(size(somaPosition,1), numLayers);
  for iLayer = 1:numLayers
    t = 2*pi*rand(1,numPoints);
    r = axonArborRadius(iLayer)*sqrt(rand(1,numPoints));
    x = r.*cos(t);
    y = r.*sin(t);
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
elseif strcmpi(kernel, 'exponential') || strcmpi(kernel, 'e')
  p = 1; % TO DO
else
  p = 1; % TO DO
end