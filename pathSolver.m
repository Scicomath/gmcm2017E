function [ solutionCell ] = pathSolver( firLaunchNode, loadNode,...
    secLaunchNode )
%pathSolver Generate a whole solution given first launching node, loading 
%   node, and second launching node
%   input:
%       firLaunchNode: truckNum*1 matrix, first launching node
%       loadNode: truckNum*1 matrix, loading node
%       secLaunchNode: truckNum*1 matrix, second launching node
%   output:
%       solutionCell: truckNum*1 cell, the whole solution,
%           every row means a path for a truck, and the format is specified
%           by the problem, i.e. truckID, nodeID, leave time, nodeID, arrive
%           time, leave time, ...

global timeMat


k = 10;         % number of shortest path 
truckNum = 24;  % number of truck
nodeNum = 130;  % number of node
% truck type, 1 for A, 2 for B, 3 for C
truckType = [ones(6,1);ones(6,1)*2;ones(12,1)*3];
% initial node, given by problem
initNode = [1;1;1;2;2;2;1;1;1;2;2;2;1;1;1;1;1;1;2;2;2;2;2;2];

% initializaiton the whole solution
solutionCell = cell(truckNum,1);

% find k shortest path
fir.Path = cell(k,truckNum);
fir.ArriveTime = cell(k,truckNum);
fir.LeaveTime = cell(k,truckNum);
fir.TotalTime = zeros(k,truckNum);
for i = 1:truckNum
    if truckType(i) == 1
        [shortestPaths, totalTime] = kShortestPath(timeMat.A,...
            firLaunchNode(i), initNode(i), k);
    elseif truckType(i) == 2
        [shortestPaths, totalTime] = kShortestPath(timeMat.B,...
            firLaunchNode(i), initNode(i), k);
    elseif truckType(i) == 3
        [shortestPaths, totalTime] = kShortestPath(timeMat.C,...
            firLaunchNode(i), initNode(i), k);
    end
    fir.Path(:,i) = shortestPaths';
    fir.TotalTime(:,i) = totalTime';
end
initT = 0;
for i = 1:k
    for j = 1:truckNum
        if truckType(i) == 1
            [~,~,fir.ArriveTime{i,j}] = pathTimeFun( fir.Path{i,j},...
                timeMat.A,nodeData,initT );
        elseif truckType(i) == 2
            [~,~,fir.ArriveTime{i,j}] = pathTimeFun( fir.Path{i,j},...
                timeMat.B,nodeData,initT );
        elseif truckType(i) == 3
            [~,~,fir.ArriveTime{i,j}] = pathTimeFun( fir.Path{i,j},...
                timeMat.C,nodeData,initT );
        end
        fir.LeaveTime{i,j} = fir.ArriveTime{i,j};
    end
end


bestI = ones(truckNum, 1);      % best path in k shortest path

truckPriorityList = [];         % list of truck priority, higher priority 
                                % in the beginning
                                
undeterminTruck = 1:truckNum;   % undetermined truck list

roadInfoCell = cell(nodeNum);   % road information cell, each element is a
                                %   n*2 matrix, where the first column
                                %   means the arrive time, and the second
                                %   column means the leave time

while ~isempty(undeterminTruck) 
    target = 0;     % initialize target truck, namely the highest priority 
                    %   truck in the undetermined trucks

    minAddedTime = inf; % initialize minimum added time
    
    for i = undeterminTruck
        % assume i is the target truck, update the road information
        newRoadInfoCell = updateRoadState(roadInfoCell,...
            fir.Path{bestI(i),i}, fir.ArriveTime{bestI(i),i},...
            fir.LeaveTime{bestI(i),i});
        
        % update all other path using new road information
        [addedTime, tempBestI] = updateAllPath(newRoadInfoCell, fir);
        
        if addedTime<minAddedTime 
            minAddedTime = addedTime;
            target = i;
            bestI = tempBestI;
        end
    end
    
    % fill solutionCell using target path
    solutionCell{target} = generateResult(...
        firPathCell{bestI(target),target},...
        firArriveTimeCell{bestI(target),target},...
        firLeaveTimeCell{bestI(target),target}); 
    
    % update road information by adding targe path
    roadInfoCell = updateRoadState(roadInfoCell,...
            fir.Path{bestI(target),target},...
            fir.ArriveTime{bestI(target),target},...
            fir.LeaveTime{bestI(target),target});
    
    % update all path
    [~, ~, fir] = updateAllPath(roadInfoCell, fir);
    
    % update truck priority list and undetermined truck list
    truckPriorityList = [truckPriorityList; target];
    undeterminTruck(id) = [];
end


end

