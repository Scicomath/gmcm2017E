function solution = generateResult(path,arriveTime,leaveTime)
%generateResult Generate result according to problem's format
%   input:
%       path: node list of the path
%       arriveTime: arrive time list of the path
%       leaveTime: leave time list of the path
%   output:
%       solution: solution in problem's format, i.e. nodeID, leave time,
%           nodeID, arrive time, leave time, ...

path = path(end:-1:1);
maxTime = max(arriveTime);

tempArriveTime = arriveTime;
tempLeaveTime = leaveTime;

% this is not a bug
arriveTime = maxTime - tempLeaveTime(end:-1:1);
leaveTime = maxTime - tempArriveTime(end:-1:1);

n = length(path);
solution = zeros(1,(n-1)*3+2);
solution(1) = path(1);
solution(3:3:end) = path(2:end);
solution(2:3:end) = leaveTime;
solution(4:3:end) = arriveTime(2:end);

end