function [SS] = setupEnvironment(SS)

% Todo: get these values directly from installed version info
minPoolSize = 1;
maxPoolSize = 12;

%disp('Initialising simulation environment...');

% Check if Parallel Computing Toolbox is installed
v = ver;
if ~any(strcmp('Parallel Computing Toolbox', {v.Name}))
  disp('Parallel Computing Toolbox not installed, running in serial');
  SS.parallelSim = false;
else
  if ~isfield(SS, 'parallelSim')
    disp('parallelSim not defined, running in serial');
    SS.parallelSim = false;
  end
end

if SS.parallelSim
  if isfield(SS, 'poolSize')
    P.min = minPoolSize;
    P.max = maxPoolSize;
    checkInput(SS.poolSize, 'numerical', P);
    poolSize = SS.poolSize;
    disp(strcat('Starting  ', num2str(poolSize), ' labs...'));
  else
    disp('poolSize not defined, using default pool size');
    poolSize = -1;
  end
  
  if isfield(SS, 'profileName')
    checkInput(SS.profileName, 'char');
    profileName = SS.profileName;
  else
    disp('profileName not defined, using local profile')
    profileName = 'local';
    SS.profileName = profileName;
  end

  if matlabpool('size') == 0
    if poolSize == -1
      matlabpool(profileName);
    else
      matlabpool(profileName, poolSize);
    end
  end
  
  SS.poolSize = matlabpool('size');
end