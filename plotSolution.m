function plotSolution(solutionCell, binAdjMat, mainRoadMat, frameNum)
global nodeData

nodeNum = size(nodeData,1); 
Dnodes = 1:2;       % deposite node set
Znodes = 3:8;       % loading node set
Fnodes = 9:68;      % launching node set
Jnodes = 69:130;    % road node set
truckNum = size(solutionCell,1);
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

XPathList = cell(truckNum,1);
YPathList = cell(truckNum,1);
timeList = cell(truckNum,1);

for i = 1:truckNum
    n = length(solutionCell{i});
    XPathList{i}(1) = nodeData(solutionCell{i}(1),1);
    YPathList{i}(1) = nodeData(solutionCell{i}(1),2);
    timeList{i}(1) = solutionCell{i}(2);
    k = 1;
    for j = 3:3:n
        k = k + 1;
        XPathList{i}(k) = nodeData(solutionCell{i}(j),1);
        YPathList{i}(k) = nodeData(solutionCell{i}(j),2);
        timeList{i}(k) = solutionCell{i}(j+1);
        if solutionCell{i}(j+2)-solutionCell{i}(j+1) > 0.000001
            k = k + 1;
            XPathList{i}(k) = nodeData(solutionCell{i}(j),1);
            YPathList{i}(k) = nodeData(solutionCell{i}(j),2);
            timeList{i}(k) = solutionCell{i}(j+2);
        end
    end
end

maxTime = solutionCell{1}(end);

T = linspace(0,maxTime,frameNum);
X = zeros(truckNum,frameNum);
Y = zeros(truckNum,frameNum);
for i = 1:truckNum
    X(i,:) = interp1(timeList{i},XPathList{i},T);
    Y(i,:) = interp1(timeList{i},YPathList{i},T);
end

h = plot(X(:,1),Y(:,1),'ro','MarkerSize',9);
for i = 1:frameNum
    h.XData = X(:,i);
    h.YData = Y(:,i);
    drawnow;
end

end