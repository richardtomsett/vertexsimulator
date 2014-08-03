function [compartmentPositions, LineSourceModifierArr] = ...
  calculateLineSourceModifiers(storeCompartmentPositions, ...
  NeuronArr, ...
  RecordingInfo, ...
  SimulationSettings, ...
  TissueProperties)
%CALCULATELINESOURCEMODIFIERS Calculate the constants required by the
%line-source method (assume point source soma compartments). Method adapted
%from LFPy (Linden et al 2014).

neuronInGroup = ...
  createGroupsFromBoundaries(TissueProperties.groupBoundaryIDArr);
N = TissueProperties.N;
sigma = TissueProperties.tissueConductivity * 1000;
electrodePositionArr = RecordingInfo.electrodePositionArr;
rLimit = RecordingInfo.minDistToElectrodeTip;
compartmentPositions = cell(N, 3);
LineSourceModifierArr  = cell(N, size(electrodePositionArr, 1));
somaPositionMat = TissueProperties.somaPositionMat(:, 1:3);
rotationAngleMat = TissueProperties.rotationAngleMat;

% If running in parallel, if this is lab 1, then display progress
if SimulationSettings.parallelSim
  printProg = labindex() == 1;
  neuronInThisLab = find(SimulationSettings.neuronInLab == labindex);
else
  printProg = true;
  neuronInThisLab = 1:N;
end

%Line Source: phi = (I/4*pi*sigma*delta_s)*log( abs(( sqrt(h^2+rho^2)-h )/(
%sqrt(l^2+rho^2)-l )) )
if printProg
  PR = ProgressReporter(length(neuronInThisLab), 5, ...
         ' line source constants calculated ...');
end
for ii = 1:length(neuronInThisLab)
  iNeuron = neuronInThisLab(ii);
  iGroup = neuronInGroup(iNeuron);
  numCompartments = NeuronArr(iGroup).numCompartments;
  if numCompartments > 1
    somaPosition = somaPositionMat(iNeuron, :);
    if ~isfield(NeuronArr(iGroup), 'axisAligned')
      rot = rotationAngleMat(iNeuron, :);
    elseif strcmpi(NeuronArr(iGroup).axisAligned, 'x')
      rot = [rotationAngleMat(iNeuron, 1) 0 0];
    elseif strcmpi(NeuronArr(iGroup).axisAligned, 'y')
      rot = [0 rotationAngleMat(iNeuron, 2) 0];
    elseif strcmpi(NeuronArr(iGroup).axisAligned, 'z')
      rot = [0 0 rotationAngleMat(iNeuron, 3)];
    else
      rot = rotationAngleMat(iNeuron, :);
    end
    xPos = NeuronArr(iGroup).compartmentXPositionMat(:, :);
    yPos = NeuronArr(iGroup).compartmentYPositionMat(:, :);
    zPos = NeuronArr(iGroup).compartmentZPositionMat(:, :);
    deltaS = NeuronArr(iGroup).compartmentLengthArr(:);
    
    for iCompartment = 1:numCompartments
      xyzNewBottom = rotate3DCoordinates( [xPos(iCompartment, 1) ...
        yPos(iCompartment, 1) zPos(iCompartment, 1)], ...
        rot(1), rot(2), rot(3)) + somaPosition(:);
      xyzNewTop = rotate3DCoordinates( [xPos(iCompartment, 2) ...
        yPos(iCompartment, 2) zPos(iCompartment, 2)], ...
        rot(1), rot(2), rot(3)) + somaPosition(:);
      xPos(iCompartment, :) = [xyzNewBottom(1) xyzNewTop(1)];
      yPos(iCompartment, :) = [xyzNewBottom(2) xyzNewTop(2)];
      zPos(iCompartment, :) = [xyzNewBottom(3) xyzNewTop(3)];
    end
    xMid = xPos(:, 1) + (xPos(:, 2) - xPos(:, 1)) ./ 2;
    yMid = yPos(:, 1) + (yPos(:, 2) - yPos(:, 1)) ./ 2;
    zMid = zPos(:, 1) + (zPos(:, 2) - zPos(:, 1)) ./ 2;
    
    if storeCompartmentPositions
      compartmentPositions{iNeuron, 1} = xPos;
      compartmentPositions{iNeuron, 2} = yPos;
      compartmentPositions{iNeuron, 3} = zPos;
    end
  end
  for iElectrode = 1:size(electrodePositionArr, 1)
    if numCompartments > 1
      h = dot([electrodePositionArr(iElectrode, 1) - xPos(:, 2), ...
        electrodePositionArr(iElectrode, 2) - yPos(:, 2), ...
        electrodePositionArr(iElectrode, 3) - zPos(:, 2)], ...
        [xPos(:, 2) - xPos(:, 1), ...
        yPos(:, 2) - yPos(:, 1), ...
        zPos(:, 2) - zPos(:, 1)], 2) ./ deltaS;
      r2 = abs( (electrodePositionArr(iElectrode, 1) - xPos(:, 2)).^2 + ...
        (electrodePositionArr(iElectrode, 2) - yPos(:, 2)).^2 + ...
        (electrodePositionArr(iElectrode, 3) - zPos(:, 2)).^2 - ...
        h.^2);
      
      % Soma is point source: calculate distance to point
      r2(1) = (electrodePositionArr(iElectrode, 1) - xMid(1, 1)).^2 + ...
        (electrodePositionArr(iElectrode, 2) - yMid(1, 1)).^2 + ...
        (electrodePositionArr(iElectrode, 3) - zMid(1, 1)).^2;
      
      l = h + deltaS;
      lmMat = zeros(numCompartments, 4);
      
      r2_reposition = ...
        r2 < rLimit*rLimit & h < rLimit & (deltaS+h) > -rLimit;
      r2(r2_reposition) = rLimit * rLimit;
      
      hnegative = h < 0;
      hpositive = h >= 0;
      lnegative = l < 0;
      lpositive = l >= 0;
      
      hnegative(1) = false;
      hpositive(1) = false;
      lnegative(1) = false;
      lpositive(1) = false;
      
      case1 = hnegative & lnegative;
      case2 = hnegative & lpositive;
      case3 = hpositive & lpositive;
      case4 = ~(case1 | case2 | case3);

      lmMat(case1, 1) = ...
        log(abs( (sqrt(h(case1).^2 + r2(case1)) - h(case1)) ./ ...
        (sqrt(l(case1).^2 + r2(case1)) - l(case1)) ));

      lmMat(case2, 2) = ...
        log(abs( ((sqrt(h(case2).^2 + r2(case2)) - h(case2)) .* ...
        (sqrt(l(case2).^2 + r2(case2)) + l(case2))) ./ ...
        r2(case2) ));

      lmMat(case3, 3) = ...
        log(abs( (sqrt(l(case3).^2 + r2(case3)) + l(case3)) ./ ...
        (sqrt(h(case3).^2 + r2(case3)) + h(case3)) ));
      
      lmMat(case4, 4) = ...
        log(abs( (sqrt(h(case4).^2 + r2(case4)) - h(case4)) ./ ...
        (sqrt(l(case4).^2 + r2(case4)) - l(case4)) ));
      
      lm = lmMat(:, 1) + lmMat(:, 2) + lmMat(:, 3) + lmMat(:, 4);
      lm(1) = 1 / (4 * pi * sigma * sqrt(r2(1)));
      lm(2:end) = lm(2:end) ./ (4 .* pi .* sigma .* deltaS(2:end));
      
      LineSourceModifierArr{iNeuron, iElectrode} = lm;
    else
      LineSourceModifierArr{iNeuron, iElectrode} = 0;
    end
  end
  if printProg
    printProgress(PR, ii);
  end
end