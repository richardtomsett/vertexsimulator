function [] = vertexFunctions()
%VERTEXFUNCTIONS Displays a list of functions available to the user.

allNames = {};
folders = {};
p = strsplit(path(),':');
for i=1:length(p)
  if ~isempty(strfind(p{i},'vertex_user'))
    folders{1} = p{i};
    break;
  end
end
folders = [folders, {[folders{1} '/analysis']}];

for iFolder = 1:length(folders)
  files = dir( fullfile(folders{iFolder}, '*.m'));
  allNames = [allNames, {files.name} ];
end

for iName = 1:length(allNames)
  fName = allNames{iName};
  f = fopen(fName);
  l = fgetl(f);
  while l(1)~='%'
    l=fgetl(f);
  end
  disp(['  ' fName(1:end-2) ': ' l((length(fName)):end)]);
end