function solution = generateResult(path,arriveTime,leaveTime,stage)
%generateResult Generate result according to problem's format
%   input:
%       path: node list of the path
%       arriveTime: arrive time list of the path
%       leaveTime: leave time list of the path
%   output:
%       solution: solution in problem's format, i.e. nodeID, leave time,
%           nodeID, arrive time, leave time, ...

if stage == 1
    path = path(end:-1:1);
    maxTime = max(arriveTime);

    tempArriveTime = arriveTime;
    tempLeaveTime = leaveTime;

    % this is not a bug
    arriveTime = maxTime - tempLeaveTime(end:-1:1);
    leaveTime = maxTime - tempArriveTime(end:-1:1);
end

n = length(path);
solution = zeros(1,(n-1)*3+1);
solution(1) = path(1);
solution(3:3:end) = path(2:end);
solution(2:3:end) = leaveTime(1:end-1);
solution(4:3:end) = arriveTime(2:end);

end