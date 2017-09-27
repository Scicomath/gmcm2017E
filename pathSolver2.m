function [ solutionCell ] = pathSolver2(firLaunchNode, loadNode, secLaunchNode, launchTime)
%pathSolver2 Generate solution for second stage (including loading and 
%   second launching)
%   input:
%       firLaunchNode: truckNum*1 matrix, first launching node
%       loadNode: truckNum*1 matrix, loading node
%       secLaunchNode: truckNum*1 matrix, second launching node
%   output:
%       solutionCell: truckNum*1 cell, the second stage solution,
%           every row means a path for a truck, and the format is specified
%           by the problem, i.e. nodeID, leave time, nodeID, arrive
%           time, leave time, ...
global timeMat nodeData

GtimeMat.A = digraph(timeMat.A);
GtimeMat.B = digraph(timeMat.B);
GtimeMat.C = digraph(timeMat.C);

truckNum = 24;  % number of truck
nodeNum = 130;  % number of node
% truck type, 1 for A, 2 for B, 3 for C
truckType = [ones(6,1);ones(6,1)*2;ones(12,1)*3];


% initializaiton the whole solution
solutionCell = cell(truckNum,1);

% find shortest path
sec.Path = cell(1,truckNum);
sec.ArriveTime = cell(1,truckNum);
sec.LeaveTime = cell(1,truckNum);
sec.TotalTime = zeros(1,truckNum);
sec.loadID = zeros(1,truckNum);

for i = 1:truckNum
    if truckType(i) == 1
        [shortestPaths1, totalT1] = shortestpath(GtimeMat.A,...
            firLaunchNode(i), loadNode(i));
        [shortestPaths2, totalT2] = shortestpath(GtimeMat.A,...
            loadNode(i), secLaunchNode(i));
    elseif truckType(i) == 2
        [shortestPaths1, totalT1] = shortestpath(GtimeMat.B,...
            firLaunchNode(i), loadNode(i));
        [shortestPaths2, totalT2] = shortestpath(GtimeMat.B,...
            loadNode(i), secLaunchNode(i));
    elseif truckType(i) == 3
        [shortestPaths1, totalT1] = shortestpath(GtimeMat.C,...
            firLaunchNode(i), loadNode(i));
        [shortestPaths2, totalT2] = shortestpath(GtimeMat.C,...
            loadNode(i), secLaunchNode(i));
    end
    sec.Path{i} = [shortestPaths1,shortestPaths2(2:end)];
    sec.loadID(i) = length(shortestPaths1);
    sec.TotalTime(i) = totalT1 + totalT2;
end

initT = launchTime;
for i = 1:truckNum
    if truckType(i) == 1
        [~,~,sec.ArriveTime{i}] = pathTimeFun( sec.Path{i},...
            timeMat.A,nodeData,initT );
    elseif truckType(i) == 2
        [~,~,sec.ArriveTime{i}] = pathTimeFun( sec.Path{i},...
            timeMat.B,nodeData,initT );
    elseif truckType(i) == 3
        [~,~,sec.ArriveTime{i}] = pathTimeFun( sec.Path{i},...
            timeMat.C,nodeData,initT );
    end
    sec.LeaveTime{i} = sec.ArriveTime{i};
    k = sec.loadID(i);
    loadingTime = 10/60;
    sec.ArriveTime{i}(k+1:end) = sec.ArriveTime{i}(k+1:end) + loadingTime;
    sec.LeaveTime{i}(k:end) = sec.LeaveTime{i}(k:end) + loadingTime;
    sec.TotalTime(i) = sec.TotalTime(i) + loadingTime;
end


% to be continue

solutionCell = cell(truckNum,1);
for i = 1:truckNum
    solutionCell{i} = generateResult(sec.Path{i}, ...
        sec.ArriveTime{i}, sec.LeaveTime{i},2);
end


end