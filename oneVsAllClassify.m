function [deltaErr] = oneVsAllClassify(data, key_unique, key_sorted, headers, category, include, exclude)
%UNTITLED2 Summary of this function goes here
%   This function will automatically classify the data using a 75 tree
%   random forest model. This is one vs. all classification (e.g.
%   haloperidol vs. all other drugs, or antipsychotics vs. all other
%   classes). The category should be either 'Class' or 'Compound'. Include
%   are the literal strings under the correct category that is to be
%   classified against everything else. Exclude can optionally be left
%   blank. Otherwise these are examples to be excluded (e.g. too low or too
%   high of a concentration)

% [testTrain] = sortCmpdConc(testTrain); %Group like compounds together, then sort by concentration
trainCol = strcmp(headers,'TrainIdx'); testCol = strcmp(headers,'TestIdx');

%The first step is to figure out what we are classifying against. For
%example, we need to know if we are going to classify "Haloperidol" vs
%everything else or "Antipsychotics" vs. everything else. First we need to
%find out what we are comparing to, "Class" or "Compound"
if strcmp(category, 'Class') == 1
    col_category = strcmp(headers,'Cmpd_class');
else
    col_category = strcmp(headers,'Cmpd');
end
%Next should create a new key that puts each datapoint as either a "one" or
%"all else" class
newClass = cell(1,size(key_sorted,1)); marked = zeros(1,size(key_sorted,1));
newClass(:) = {'Other'};
for i = 1:numel(include)
    temp = include{i};
    temp_idx = strcmp(temp, key_sorted(:,col_category));
    marked = marked + temp_idx'; %Keep a running score of all the selected categories
end
marked = logical(marked); %So we can use this as an index
newClass(marked) = include;

% Need more editing from here on out

trainIdx = cell2mat(key_unique(:,trainCol)); testIdx = cell2mat(key_unique(:,testCol));
Xtrain = data(trainIdx,:); Xtest = data(testIdx,:);
Ytrain = newClass(trainIdx)'; Ytest = newClass(testIdx)';

%Resubstitution accuracy
% B = TreeBagger(75,Xtrain,Ytrain,'oobpred','On','Method','classification','oobvarimp','on');
B = TreeBagger(15,Xtrain,Ytrain,'oobpred','On','oobvarimp','on');
% B = TreeBagger(10,Xtrain,Ytrain,'oobpred','On');
class = predict(B,Xtrain);
acc_matrix = strcmp(class,Ytrain);
acc = mean(acc_matrix);
['The resubstitution error of random forest is: ' num2str(acc)]

%Here we test the accuracy
class = predict(B,Xtest);
acc_matrix = strcmp(class,Ytest);
acc = mean(acc_matrix);
['The accuracy of random forest is: ' num2str(acc)]

%Now let's test in and out of class accuracy
cmpd_idx = strcmp(Ytest,include);
acc_matrix = strcmp(class(cmpd_idx),Ytest(cmpd_idx));
acc = mean(acc_matrix);
['The accuracy of classifying ' cell2mat(include) ' is: ' num2str(acc)]

Ytest_trunc = Ytest; Ytest_trunc(cmpd_idx) = [];
class_trunc = class; class_trunc(cmpd_idx) = [];
acc_matrix = strcmp(class_trunc,Ytest_trunc);
acc = mean(acc_matrix);
['The accuracy of classifying all Others is: ' num2str(acc)]

%% Feature Importance
deltaErr = B.OOBPermutedVarDeltaError; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
[sortedErr,sortingIdx] = sort(deltaErr,'descend');
important_err = sortedErr(1:5)
important_idx = sortingIdx(1:5)
% %Now for margins (more raised margins = better predictor)
% deltaErr_margin = B.OOBPermutedVarCountRaiseMargin; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
% [sortedErr,sortingIdx] = sort(deltaErr_margin,'descend');
% important_err_margin = sortedErr(1:5)
% important_idx_margin = sortingIdx(1:5)

%% Feature importance analysis
%Let's create a 1D heatmap showing which features are the most important
% kernel = gausswin(5)';
% err_data = zeros(size(deltaErr));
% numUseful = sum(deltaErr>0); %This is the number of features which were useful
% % for i = 1:numUseful
% %     idx = sortingIdx(i); %This is the index of a useful feature
% %     err_data(idx-2:idx+2) = err_data(idx-2:idx+2) + kernel.*sortedErr(i);
% % end

%Now let's see which features are important. To do this let's plot the
%average traces of the compound of interest vs. the average trace of ALL
%other compounds. First find the indices of each class of compounds, then
%find the average trace of each condition.
other_idx = strcmp(newClass,'Other'); one_idx = logical(1-other_idx);
other_data = mean(data(other_idx,:));one_data = mean(data(one_idx,:));
numData = length(other_data);
figure();h = subplot(2,1,2);heatmap(deltaErr,1:length(deltaErr));
g = subplot(2,1,1);plot(1:numData,other_data,'b-');
hold on; plot(1:numData,one_data,'g-');
legend('All other conditions',include{1});
title('Feature Importance Rankings'); xlabel('Feature (Time)');
linkaxes([g, h],'x');xlim([1 numData]);


end

