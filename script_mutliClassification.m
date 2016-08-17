close all
clear all
load('drug_classes.mat');

rng(1); %For consistency

%% Here we create the training and testing sets
%The first thing to do is to find all the unique compounds and all the
%relevant indexes that belong to that unique compound
[testTrain, headers] = createTestTrain(key,key_classonly);
trainIdx = cell2mat(testTrain(:,6)); testIdx = cell2mat(testTrain(:,7));
Xtrain = data_norm(trainIdx,:); Xtest = data_norm(testIdx,:);
Ytrain = key_classonly(trainIdx); Ytest = key_classonly(testIdx);

%Resubstitution accuracy
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

% %Here we adjust the number of trees to avoid overfitting
oobErrorBaggedEnsemble = oobError(B);
figure();plot(oobErrorBaggedEnsemble);
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';title('OOB Error with Number of Trees');

%% Classification on only subset of data
%Let's try retraining the classifier, this time only using the moderate
%concentrations (where hopefully the drugs are best separated)
testTrain_moderate = cell(0);concCol = strcmp(headers, 'Concentration');
for i = 1:size(testTrain,1)
    temp_conc = str2num(testTrain{i,concCol});
    if temp_conc < 50 && temp_conc >=6.25
        testTrain_moderate = [testTrain_moderate; testTrain(i,:)];
    elseif temp_conc == 0
        testTrain_moderate = [testTrain_moderate; testTrain(i,:)];
    end
end
[err_matrix, testTrain_moderateRes] = RFclassify(testTrain_moderate, headers, data_norm, key, key_classonly);
err_matrix;

%% Let's try a one vs. all specific drug classification
%For now let's just see what's unique about antipsychotics.
key_antipsychotics = key_classonly;
antipsychotic_idx = strcmp(key_antipsychotics,'Antipsychotic');
antipsychotic_idx = logical(1 - antipsychotic_idx);
key_antipsychotics(antipsychotic_idx) = cellstr('Other');
[err_matrix, testTrain_antiPsy] = RFclassify(testTrain_moderate, headers, data_norm, key, key_antipsychotics);
err_matrix;
