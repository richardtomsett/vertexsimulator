function [RecordingInfo] = positionMEA(RecordingInfo)

% Generate electrode tip positions
if isfield(RecordingInfo, 'numElectrodesX')
  electrodesX = RecordingInfo.numElectrodesX;
  spacingX = RecordingInfo.electrodeSpacingX;
else
  electrodesX = 1;
  spacingX = 0;
end
if isfield(RecordingInfo, 'numElectrodesY')
  electrodesY = RecordingInfo.numElectrodesY;
  spacingY = RecordingInfo.electrodeSpacingY;
else
  electrodesY = 1;
  spacingY = 0;
end
if isfield(RecordingInfo, 'numElectrodesZ')
  electrodesZ = RecordingInfo.numElectrodesZ;
  spacingZ = RecordingInfo.electrodeSpacingZ;
else
  electrodesZ = 1;
  spacingZ = 0;
end
offsetX = RecordingInfo.electrodeArrOffsetX;
offsetY = RecordingInfo.electrodeArrOffsetY;
offsetZ = RecordingInfo.electrodeArrOffsetZ;
RecordingInfo.electrodePositionArr =  ...
  generateElectrodePositions(electrodesX, electrodesY, electrodesZ, ...
                             spacingX,    spacingY,    spacingZ, ...
                             offsetX,     offsetY,     offsetZ);