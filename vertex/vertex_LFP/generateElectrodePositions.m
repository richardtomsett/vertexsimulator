function [electrodePositionArr] = generateElectrodePositions(meaX, meaY, meaZ)
%GENERATEELECTRODEPOSITIONS Generate x, y and z coordinates of the
%electrode tips.
%
%   ELECTRODEPOSITIONARR = GENERATEELECTRODEPOSITIONS(MEAX, MEAY, MEAZ)
%   generates an n by 3 matrix, where n is the number of electrodes, and
%   the columns store the x, y and z coordinate of each electrode. MEAX,
%   MEAY and MEAZ contain the x, y and z coordinates of the electrode
%   positions in the format returned by the function MESHGRID.

nx = size(meaX,2);
ny = size(meaY,1);
nz = size(meaZ,3);
electrodePositionArr = zeros(nx*ny*nz, 3);

if nx <= 1
  nx = 1;
end
if ny <= 1
  ny = 1;
end
if nz <= 1
  nz = 1;
end

%cx = 1;
%cy = 1;
%cz = 0;
for iy = 1:ny
  %electrodePositionArr(cx:(ny * nz) + cx - 1, 1) = (ix - 1);
  for ix = 1:nx
    %electrodePositionArr(cy:nz + cy - 1, 2) = (iy - 1);
    for iz = 1:nz
      ind = sub2ind([nz ny nx],iz,iy,ix);
      electrodePositionArr(ind, :) = ...
        [meaX(iy,ix,iz), meaY(iy,ix,iz), meaZ(iy,ix,iz)];
    end
    %cy = cy + nz;
    %cz = cz + nz;
  end
  %cx = cx + (ny * nz);
end


% electrodePositionArr = ...
%   bsxfun(@plus, electrodePositionArr, [offsetX, offsetY, offsetZ]);