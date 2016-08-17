function [err_matrix, testTrain, headers] = RFclassify(testTrain, headers, data_norm, key, key_classonly)
%RFclassify(trainIdx, testIdx, testTrain, key)
%This function will run a random forest classifier and return the
%resubstitution error and the accuracy using a hold out set. testTrain is a
%cell array that contains the raw data. The third and fourth column are
%expected to hold the data indices that contain the training and testing
%data respectively. data_norm contains the actual data to be analyzed. key
%contains the class labels

% [testTrain] = sortCmpdConc(testTrain); %Group like compounds together, then sort by concentration
trainCol = strcmp(headers,'TrainIdx'); testCol = strcmp(headers,'TestIdx');
trainIdx = cell2mat(testTrain(:,trainCol)); testIdx = cell2mat(testTrain(:,testCol));
Xtrain = data_norm(trainIdx,:); Xtest = data_norm(testIdx,:);
Ytrain = key_classonly(trainIdx); Ytest = key_classonly(testIdx);

%Resubstitution accuracy
% B = TreeBagger(75,Xtrain,Ytrain,'oobpred','On','Method','classification','oobvarimp','on');
B = TreeBagger(75,Xtrain,Ytrain,'oobpred','On');
class = predict(B,Xtrain);
acc_matrix = strcmp(class,Ytrain);
acc = mean(acc_matrix);
['The resubstitution error of random forest is: ' num2str(acc)]

%Here we test the accuracy
class = predict(B,Xtest);
acc_matrix = strcmp(class,Ytest);
acc = mean(acc_matrix);
['The accuracy of random forest is: ' num2str(acc)]

%% Feature Importance
deltaErr = BaggedEnsemble.OOBPermutedVarDeltaError; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
[sortedErr,sortingIdx] = sort(deltaErr,'descend');
important_err = sortedErr(1:5)
important_idx = sortingIdx(1:5)
%Now for margins (more raised margins = better predictor)
deltaErr_margin = BaggedEnsemble.OOBPermutedVarCountRaiseMargin; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
[sortedErr,sortingIdx] = sort(deltaErr_margin,'descend');
important_err_margin = sortedErr(1:5)
important_idx_margin = sortingIdx(1:5)

% %% Feature importance analysis
% %Let's create a 1D heatmap showing which features are the most important
% kernel = gausswin(5)';
% err_data = zeros(size(deltaErr));
% numUseful = sum(deltaErr>0); %This is the number of features which were useful
% for i = 1:numUseful
%     idx = sortingIdx(i); %This is the index of a useful feature
%     err_data(idx-2:idx+2) = err_data(idx-2:idx+2) + kernel.*sortedErr(i);
% end
% h = heatmap(err_data,1:size(data_norm,2));

%% Back to errors

err_matrix = [{'Drug Name' 'Actual Class' 'Predicted Class'}; key(testIdx) ...
    Ytest class];
temp_idx = logical(1 - strcmp(err_matrix(:,2),err_matrix(:,3)));
err_matrix = err_matrix(temp_idx,:);

%Here we do some error checking - how was each class split amongst the
%testing and training sets and what was the accuracy of prediction for each
%class? Was there a class was especially hard to classify?
createStackedBar(key,trainIdx,testIdx);title('Training and Test set breakdown');

%% Error Checking    
%Now that we know the general breakdown of testing/training sets let's
%start to look at where mistakes occurred
temp_wrongIdx = find(acc_matrix == 0);
wrongIdx = testIdx(temp_wrongIdx);%These are the indexes of datapoints that were incorrect in the ORIGINAL dataset (data
% [key(wrongIdx) Ytest(temp_wrongIdx) class(temp_wrongIdx)] %This shows the compound in the first column, the correct class, and the assigned class for all INCORRECT classifications
wrongCmpd = key(wrongIdx); %These are the identities of all misclassified compounds
unique_wrong = unique(wrongCmpd);
headers = [headers cellstr('NumWrong')];
testTrain(:,8) = num2cell(zeros(size(testTrain,1),1));
for i = 1:numel(wrongCmpd)
    temp = wrongCmpd{i};
    tempIdx = strcmp(temp, testTrain(:,1)); tempIdx = find(tempIdx == 1);
    testTrain{tempIdx,8} = testTrain{tempIdx,8} + 1;
end

%Now let's find the accuracy for each possible condition
totalNum = zeros(size(testTrain,1),1);
for i = 1:size(testTrain,1)
    totalNum(i,1) = numel(testTrain{i,testCol});
end
perClassAccuracy = 1 - cell2mat(testTrain(:,8)) ./ totalNum;

figure();bar(perClassAccuracy,'g');
% cmpd_labels = formatDrugLabels(testTrain(:,1));
cmpdCol = strcmp(headers,'Cmpd'); concCol = strcmp(headers,'Concentration');
cmpd = testTrain(:,cmpdCol); conc = testTrain(:,concCol);
cmpd_labels = cell(numel(cmpd),1);
for i = 1:numel(cmpd)
    cmpd_labels{i} = strjoin([cmpd(i) conc(i)]);
end
xticklabel_rotate(1:numel(cmpd_labels),90,cmpd_labels,'Fontsize',7);
ylabel('% Correctly Classified'); title('Classification Accuracy by Compound + Concentration');

% %Let's see if we can find compounds that were very difficult to classify
% badCmpdList = cell(0);
% for i = 1:size(testTrain,1)
%     if testTrain{i,end} < 0.5;
%         badCmpdList = [badCmpdList; testTrain(i,[1,6])];
%     end
% end