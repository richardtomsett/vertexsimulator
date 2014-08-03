function [out] = cpexEdgeColour(ii, labID, p)

% See Tam & Wang 2000

labID = labID - 1; % -1 because Matlab indexes from 1
if mod(p, 2) ~= 0
  chi = p;
else
  chi = p - 1;
end

if labID < chi
  v = mod((ii + chi - labID), chi);
else
  if mod(ii, 2) ~= 0
    v = mod((ii + chi) / 2, chi);
  else
    v = ii / 2;
  end
end

if mod(p, 2) ~= 0 && v == labID
  out = -1;
elseif v == labID
  out = chi + 1; % +1 because Matlab indexes from 1
else
  out = v + 1; % +1 because Matlab indexes from 1
end