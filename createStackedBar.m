function createStackedBar(conditions,trainIdx,testIdx)
%createStackedBar(conditions,trainIdx,testIdx,labels)
%Here we do some error checking - how was each class split amongst the
%testing and training sets and what was the accuracy of prediction for each
%class? Was there a class was especially hard to classify?
conditions_unique = unique(conditions);
testTrain = cell(numel(conditions_unique,2));
trainConditions = conditions(trainIdx); testConditions = conditions(testIdx);
for i = 1:numel(conditions_unique)
    testTrain{i,1} = sum(strcmp(conditions_unique{i},trainConditions));%This is the number of observations of this condition that are in the training set
    testTrain{i,2} = sum(strcmp(conditions_unique{i},testConditions));%This is how many in the test set
end
testTrain(:,3) = conditions_unique;
barData = cell2mat(testTrain(:,1:2));

%Here we plot the data and do some basic formatting
figure();b = bar(barData,'g','stacked');P=findobj(gca,'type','patch');
C=['g','y','m','c'];
for i = 1:2
    set(b(i),'facecolor',C(i));
    set(b(i),'EdgeColor','k','LineWidth',1);
end
legend('Training','Testing');
[cmpd conc] = formatDrugLabels(testTrain(:,3));
cmpd_labels = cell(numel(cmpd),1);
for i = 1:numel(cmpd)
    cmpd_labels{i} = strjoin([cmpd(i) conc(i)]);
end
xticklabel_rotate(1:numel(cmpd_labels),90,cmpd_labels,'Fontsize',7);