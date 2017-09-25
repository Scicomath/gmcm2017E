global timeMat mainRoadMat nodeData     % set global variable

%rng(149)

addpath('kshortestPath')

% read node data
[nodeData] = xlsread('fj1_nodeData.xlsx');
nodeNum = size(nodeData,1); 

Dnodes = 1:2;       % deposite node set
Znodes = 3:8;       % loading node set
Fnodes = 9:68;      % launching node set
Jnodes = 69:130;    % road node set

mainRoad = {69:79,80:88};   % main road list
% generate main road matix
mainRoadMat = zeros(nodeNum);
for i = 1:length(mainRoad)
    roadLen = length(mainRoad{i});
    for j = 1:roadLen-1
        inode = mainRoad{i}(j);
        jnode = mainRoad{i}(j+1);
        mainRoadMat(inode,jnode) = 1;
        mainRoadMat(jnode,inode) = 1;
    end
end
mainRoadMat = logical(mainRoadMat);

% read distance adjacent matrix
[disAdjMat] = xlsread('disAdjMat.xlsx');
binAdjMat = disAdjMat~=0;   % ????
disAdjMat(disAdjMat==0) = inf;

% calculate time adjacent matrix
speed.A = [70,45];  % speed limits for A type
speed.B = [60,35];  % speed limits for B type
speed.C = [50,30];  % speed limits for C type
timeMat.A = disAdjMat;
timeMat.B = disAdjMat;
timeMat.C = disAdjMat;
for i = 1:nodeNum
    for j = 1:nodeNum
        if mainRoadMat(i,j)
            timeMat.A(i,j) = disAdjMat(i,j)/speed.A(1);
            timeMat.B(i,j) = disAdjMat(i,j)/speed.B(1);
            timeMat.C(i,j) = disAdjMat(i,j)/speed.C(1);
        else
            timeMat.A(i,j) = disAdjMat(i,j)/speed.A(2);
            timeMat.B(i,j) = disAdjMat(i,j)/speed.B(2);
            timeMat.C(i,j) = disAdjMat(i,j)/speed.C(2);
        end
    end
end

%% plot map
figure
hold on
for i = 1:nodeNum
    if ismember(i,Dnodes)
        plot(nodeData(i,1),nodeData(i,2),'ro','MarkerSize',10)
    elseif ismember(i,Znodes)
        plot(nodeData(i,1),nodeData(i,2),'gs','MarkerSize',8)
    elseif ismember(i,Fnodes)
        plot(nodeData(i,1),nodeData(i,2),'b+')
    elseif ismember(i,Jnodes)
        plot(nodeData(i,1),nodeData(i,2),'ko')
    end
end
for i = 1:nodeNum
    for j = 1:i
        if binAdjMat(i,j)
            if mainRoadMat(i,j)
                plot([nodeData(i,1),nodeData(j,1)],[nodeData(i,2),nodeData(j,2)],'k-','LineWidth',1.5)
            else
                plot([nodeData(i,1),nodeData(j,1)],[nodeData(i,2),nodeData(j,2)],'k-')
            end
        end
    end
end


%% demonstration of a path of one car
source = 3;
destination = 4;
k = 10;

frameNum = 100;
[shortestPaths, totalCosts] = kShortestPath(timeMat.A, source, destination, k);
initT = 0;
[ xPathList, yPathList, timeList ] = pathTimeFun( shortestPaths{4},timeMat.A,nodeData,initT );
T = linspace(initT,timeList(end),frameNum);
XPath = interp1(timeList,xPathList,T);
YPath = interp1(timeList,yPathList,T);


% h = plot(XPath(1),YPath(1),'ro','MarkerSize',9);
% for i = 1:frameNum
%     h.XData = XPath(i);
%     h.YData = YPath(i);
%     drawnow;
% end

%% demonstration of a random whole solution
truckNum = 24;

LaunchNode = Fnodes(randperm(length(Fnodes),truckNum*2));
firLaunchNode = LaunchNode(1:truckNum);
secLaunchNode = LaunchNode(truckNum+1:end);
loadNode = Znodes(randperm(length(Znodes)));
tic
[ solutionCell, totalTime, fir ] = pathSolver( firLaunchNode, loadNode,...
    secLaunchNode );
toc
frameNum = 400;
plotSolution(solutionCell, binAdjMat, mainRoadMat, frameNum)