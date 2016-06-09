close all
clear all

load('features_and_groups.mat');
load('feature_names.mat');

%First split into training and testing sets
idx = randperm(numel(conditions));
train_idx = idx(1:end-40); test_idx = idx(end-39:end);
train_data = fish_features(train_idx,:); train_group = conditions(train_idx);
test_data = fish_features(test_idx,:); test_group = conditions(test_idx);

%Normalizing the training data
train_set_old = train_data; test_set_old = test_data;
train_avg = median(train_data); train_std = sqrt(var(train_data));
offset = repmat(train_avg, size(train_data,1),1); %The mean of the training data
scale = repmat(train_std, size(train_data,1),1); %The standard deviation of the training data
train_normalized = (train_data - offset) ./ scale; %Here we normalize the training data
test_normalized = (test_data - offset(1:size(test_data,1),:)) ./ scale(1:size(test_data,1),:); %And now we normalize the testing data based on the training data avg & std
% figure();plot(1:780,train_set(4,:),'b-',1:780,train_set(5,:),'g-',1:780,train_set(end-1,:),'r-');

%Showing some graphs of the testing data
halo_idx = strcmp(train_group,'Haloperidol'); halo_data = train_normalized(halo_idx,:);
dmso_idx = strcmp(train_group,'DMSO'); dmso_data = train_normalized(dmso_idx,:);
dmso = mean(dmso_data); halo = mean(halo_data);
figure();plot(1:780, dmso, 'b-', 1:780, halo,'r-');
title('Averaged normalized features');legend('dmso','halo');
figure();plot(1:780, abs(dmso-halo));
title('Absolute Feature Difference Between DMSO and Halo');
ylabel('Abs(difference)');xlabel('Feature Index');

%Decision tree
t = classregtree(train_normalized, train_group);
class = eval(t,test_normalized); %class = cellfun(@num2str,class);
acc = mean(strcmp(class,test_group));
['The accuracy of decision tree is: ' num2str(acc)]
view(t)

%SVM
model = svmtrain(train_normalized,train_group);
class = svmclassify(model,test_normalized);
acc = mean(strcmp(class,test_group));
['The accuracy of SVM is: ' num2str(acc)]

%Linear discriminant
class = classify(test_normalized,train_normalized,train_group,'diaglinear');
acc = mean(strcmp(class,test_group));
['The accuracy of linear discriminant is: ' num2str(acc)]

%Random forest
BaggedEnsemble = TreeBagger(50,train_normalized,train_group,'oobpred','On',...
    'Method','classification','oobvarimp','on');
class = predict(BaggedEnsemble,test_normalized);
acc = mean(strcmp(class,test_group));
['The accuracy of random forest is: ' num2str(acc)]
%Here's some code to view the OOB prediction error as the tree number
%increases...
% oobErrorBaggedEnsemble = oobError(BaggedEnsemble);
% plot(oobErrorBaggedEnsemble)
% xlabel 'Number of grown trees';
% ylabel 'Out-of-bag classification error';
deltaErr = BaggedEnsemble.OOBPermutedVarDeltaError; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
[sortedErr,sortingIdx] = sort(deltaErr,'descend');
important_err = sortedErr(1:5)
important_idx = sortingIdx(1:5)
%Now for margins (more raised margins = better predictor)
deltaErr_margin = BaggedEnsemble.OOBPermutedVarCountRaiseMargin; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
[sortedErr,sortingIdx] = sort(deltaErr,'descend');
important_err_margin = sortedErr(1:5)
important_idx_margin = sortingIdx(1:5)