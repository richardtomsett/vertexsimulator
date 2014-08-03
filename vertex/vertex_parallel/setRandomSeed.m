function [] = setRandomSeed(SS)

if isfield(SS, 'randomSeed')
  rs = SS.randomSeed;
else
  rs = 123;
end

if SS.parallelSim
  rng(rs);
  spmd
    s = RandStream.create('mrg32k3a',...
    'NumStreams',numlabs(),'StreamIndices',labindex(),'Seed',rs);
    RandStream.setGlobalStream(s);
  end
else
  rng(rs);
end