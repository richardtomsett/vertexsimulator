function [xyzNew] = rotate3DCoordinates(xyz, phi, theta, psi)

sphi = sin(phi);
stheta = sin(theta);
spsi = sin(psi);
cphi = cos(phi);
ctheta = cos(theta);
cpsi = cos(psi);

[xyzNew] = ...
  [ctheta*cpsi, -cphi*spsi+sphi*stheta*cpsi, sphi*spsi+cphi*stheta*cpsi;...
   ctheta*spsi, cphi*cpsi+sphi*stheta*spsi, -sphi*cpsi+cphi*stheta*spsi;...
   -stheta,     sphi*ctheta,                cphi*ctheta] * ...
  [xyz(1); xyz(2); xyz(3)];