function [addedTime, bestI, fir] = updateAllPath(roadInfoCell, fir, unsetTruck)
%updateAllPath Update all unset truck's all paths
%   input: 
%       roadInfoCell: nodeNum*nodeNum cell, every element contain the road
%           occupy information. For example, [1,3;5,7] means there is
%           truck enter the road at 1 and leave at 3, then enter at 5 and
%           leave at 7
%       fir: contain all path information, namely, fir.Path, fir.ArriveTime,
%           fir.LeaveTime, fir.TotalTime
%       unsetTruck: unset truck list
%   output:
%       addedTime: total added time
%       bestI: the index of best path after the update
%       fir: same as input

k = size(fir.Path,1);
n = length(unsetTruck);

singleAddedT = zeros(k,n);

for i = 1:k
    for j = 1:n
        id = unsetTruck(j);
        [singleAddedT(i,j), fir.ArriveTime{i,id}, fir.LeaveTime{i,id},...
            fir.TotalTime(i,id)] = updatePath(roadInfoCell, fir.Path{i,id}, ...
            fir.ArriveTime{i,id}, fir.LeaveTime{i,id}, fir.TotalTime(i,id));
    end
end

[~, bestI] = min(fir.TotalTime);
addedTime = 0;
for i = 1:n
    addedTime = addedTime + singleAddedT(bestI(unsetTruck(i)),i);
end

end

function [addedT,arriveTime,leaveTime,totalTime] = updatePath(roadInfoCell,...
    path,arriveTime,leaveTime,totalTime)
%updatePath Update single path
%   input:
%       roadInfoCell: nodeNum*nodeNum cell, every element contain the road
%           occupy information. For example, [1,3;5,7] means there is
%           truck enter the road at 1 and leave at 3, then enter at 5 and
%           leave at 7
%       path: node list in path
%       arriveTime: time list of arrive
%       leaveTime: time list of leave
%       totalTime: total time of the path
global mainRoadMat

n = length(path);
addedT = 0;
for k = 1:n-1
    i = path(k);
    j = path(k+1);

    if isempty(roadInfoCell{i,j})&&isempty(roadInfoCell{j,i})
        continue
    end
    if mainRoadMat(i,j)
        continue
    end
    if ~isempty(roadInfoCell{i,j})
        for l = 1:size(roadInfoCell{i,j},1)
            if leaveTime(k)<roadInfoCell{i,j}(l,1)&&arriveTime(k+1)>roadInfoCell{i,j}(l,2)
                waitTime = roadInfoCell{i,j}(l,1) - leaveTime(k);
                addedT = addedT + waitTime;
                totalTime = totalTime + waitTime;
                leaveTime(k:end) = leaveTime(k:end) + waitTime;
                arriveTime(k+1:end) = arriveTime(k+1:end) + waitTime;
            elseif leaveTime(k)>roadInfoCell{i,j}(l,1)&&arriveTime(k+1)<roadInfoCell{i,j}(l,2)
                waitTime = roadInfoCell{i,j}(l,2) - arriveTime(k+1);
                addedT = addedT + waitTime;
                totalTime = totalTime + waitTime;
                leaveTime(k:end) = leaveTime(k:end) + waitTime;
                arriveTime(k+1:end) = arriveTime(k+1:end) + waitTime;
            end
        end
    end
    
    if ~isempty(roadInfoCell{j,i})
        for l = 1:size(roadInfoCell{j,i},1)
            if leaveTime(k)<roadInfoCell{j,i}(l,2)&&arriveTime(k+1)>roadInfoCell{j,i}(l,1)
                waitTime = roadInfoCell{j,i}(l,2) - leaveTime(k);
                addedT = addedT + waitTime;
                totalTime = totalTime + waitTime;
                leaveTime(k:end) = leaveTime(k:end) + waitTime;
                arriveTime(k+1:end) = arriveTime(k+1:end) + waitTime;
            end
        end
    end
end

end