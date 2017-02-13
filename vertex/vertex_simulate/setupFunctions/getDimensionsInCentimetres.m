function [l, d] = getDimensionsInCentimetres(NP)
% convert user provided lengths and diameters from microns to cm
l = NP.compartmentLengthArr .* 10^-4;
d = NP.compartmentDiameterArr .* 10^-4;
