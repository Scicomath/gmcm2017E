function [ xPathList, yPathList, timeList ] = pathTimeFun( path,timeMat,nodeData,initT )
%pathTimeFun Generate coordinates list and time list
%   input:
%       path: n*1, every element is a node in the path
%       timeMat: nodeNum*nodeNUm, time adjacent matrix
%       nodeDate: node coordinates
%       initT: initial time
%   output:
%       xPathList: x coordinates of the path
%       yPathList: y coordinates of the path
%       timeList: arrive(leave) time of each node

n = length(path);
xPathList = zeros(n,1);
yPathList = zeros(n,1);
timeList = zeros(n,1);

xPathList(1) = nodeData(path(1),1);
yPathList(1) = nodeData(path(1),2);
timeList(1) = initT;
for i = 2:n
    xPathList(i) = nodeData(path(i),1);
    yPathList(i) = nodeData(path(i),2);
    timeList(i) = timeList(i-1)+timeMat(path(i-1),path(i));
end
end

