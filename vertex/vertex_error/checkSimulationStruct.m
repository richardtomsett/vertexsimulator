function [SS] = checkSimulationStruct(SS)

%% Check required fields in Simulation parameters

requiredFields = {'simulationTime','timeStep', 'parallelSim'};
requiredClasses = {'double', 'double', 'logical'};
requiredDimensions = {[1 1], [1 1], [1 1]};

checkStructFields(SS, requiredFields, requiredClasses, requiredDimensions);
