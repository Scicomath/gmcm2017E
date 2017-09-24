function [ roadInfoCell ] = updateRoadInfo(roadInfoCell, path, arriveTime, leaveTime)
%updateRoadInfo Update roadInfoCell according to new added path
%   input:
%       roadInfoCell: nodeNum*nodeNum cell, every element contain the road
%           occupy information. For example, [1,3;5,7] means there is
%           truck enter the road at 1 and leave at 3, then enter at 5 and
%           leave at 7
%       path: path list
%       arriveTime: arrive time list
%       leaveTime: leave time list
%   output:
%       roadInfoCell: same as input

n = length(path);

for i = 1:n-1
    roadInfoCell{path(i), path(i+1)} = [roadInfoCell{path(i), path(i+1)};...
        leaveTime(i),arriveTime(i+1)];
end

end