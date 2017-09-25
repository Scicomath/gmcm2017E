function [ solutionCell, totalTime, fir ] = pathSolver1( firLaunchNode )
%pathSolver Generate solution for first stage giving first launching node
%   input:
%       firLaunchNode: truckNum*1 matrix, first launching node
%   output:
%       solutionCell: truckNum*1 cell, the first stage solution,
%           every row means a path for a truck, and the format is specified
%           by the problem, i.e. truckID, nodeID, leave time, nodeID, arrive
%           time, leave time, ...

global timeMat nodeData


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
        [shortestPaths, totalT] = kShortestPath(timeMat.A,...
            firLaunchNode(i), initNode(i), k);
    elseif truckType(i) == 2
        [shortestPaths, totalT] = kShortestPath(timeMat.B,...
            firLaunchNode(i), initNode(i), k);
    elseif truckType(i) == 3
        [shortestPaths, totalT] = kShortestPath(timeMat.C,...
            firLaunchNode(i), initNode(i), k);
    end
    fir.Path(:,i) = shortestPaths';
    fir.TotalTime(:,i) = totalT';
end
initT = 0;
for i = 1:k
    for j = 1:truckNum
        if truckType(j) == 1
            [~,~,fir.ArriveTime{i,j}] = pathTimeFun( fir.Path{i,j},...
                timeMat.A,nodeData,initT );
        elseif truckType(j) == 2
            [~,~,fir.ArriveTime{i,j}] = pathTimeFun( fir.Path{i,j},...
                timeMat.B,nodeData,initT );
        elseif truckType(j) == 3
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
        newRoadInfoCell = updateRoadInfo(roadInfoCell,...
            fir.Path{bestI(i),i}, fir.ArriveTime{bestI(i),i},...
            fir.LeaveTime{bestI(i),i});
        
        % update all other path using new road information
        [addedTime, tempBestI] = updateAllPath(newRoadInfoCell, fir,...
            setdiff(undeterminTruck,i));
        
        if addedTime<minAddedTime 
            minAddedTime = addedTime;
            target = i;
            bestI = tempBestI;
        end
    end
    
    
    % fill solutionCell using target path
    solutionCell{target} = generateResult(...
        fir.Path{bestI(target),target},...
        fir.ArriveTime{bestI(target),target},...
        fir.LeaveTime{bestI(target),target}); 

    % update road information by adding targe path
    roadInfoCell = updateRoadInfo(roadInfoCell,...
            fir.Path{bestI(target),target},...
            fir.ArriveTime{bestI(target),target},...
            fir.LeaveTime{bestI(target),target});
    
    % update all path
    [~, ~, fir] = updateAllPath(roadInfoCell, fir,...
        setdiff(undeterminTruck,target));
    
    % update truck priority list and undetermined truck list
    truckPriorityList = [truckPriorityList; target];
    undeterminTruck = setdiff(undeterminTruck, target);
end

totalTime = 0;
maxTime = 0;
for i = 1:truckNum
    temp = fir.TotalTime(bestI(i),i);
    totalTime = totalTime + temp;
    if temp>maxTime
        maxTime = temp;
    end
end

for i = 1:truckNum
    temp = maxTime - fir.TotalTime(bestI(i),i);
    solutionCell{i}(2:3:end) = solutionCell{i}(2:3:end) + temp;
    solutionCell{i}(4:3:end) = solutionCell{i}(4:3:end) + temp;
end

end

