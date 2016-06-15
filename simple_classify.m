% data = csvread('/Users/bendichter/Box Sync/MachineLearningProject/Data/Haloperidol_Data/consolidated_data.csv');
% [~,txt] = xlsread('/Users/bendichter/Box Sync/MachineLearningProject/Data/Haloperidol_Data/consolidated_key.xls');
fname_data = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Haloperidol_Data','consolidated_data.csv');
fname_key = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Haloperidol_Data', 'consolidated_key.csv');
data = csvread(fname_data);
data_origbattery = data;
[~,txt,~] = xlsread(fname_key);
DMSO = txt(2:end,3);

rng(1); %For reproducibility (disable to have random selection)

N = size(data,1);
shuffle = randperm(N);
X = data(shuffle,:);
%Here let's resample the data for more numerical stability
X_resample = zeros(size(X,1),size(X,2)/5);
for i = 1:size(X,1)
    X_resample(i,:) = resample(X(i,:),1,5);
end
Y = DMSO(shuffle);
cut = round(N*.8);
Xtrain  = X(1:cut,:);
Xtest = X(cut+1:end,:);
Xtrain_resample  = X_resample(1:cut,:);
Xtest_resample = X_resample(cut+1:end,:);
Ytest = Y(cut+1:end,:);
Ytrain = Y(1:cut,:);

%% Here we plot some of the data
%Showing some graphs of the testing data
halo_idx = strcmp(Ytrain,'Haloperidol'); halo_data = Xtrain(halo_idx,:);
dmso_idx = strcmp(Ytrain,'DMSO'); dmso_data = Xtrain(dmso_idx,:);
dmso_data_resample = Xtrain_resample(dmso_idx,:);halo_data_resample = Xtrain_resample(halo_idx,:);
dmso = mean(dmso_data); halo = mean(halo_data);
figure();plot(1:size(Xtrain,2), dmso, 'b-', 1:size(Xtrain,2), halo,'r-');
title('Averaged data');legend('dmso','halo');
xlabel('Time');ylabel('Motion Index');

%% Just some figures for my presentation ignore
% figure();figure();plot(1:size(Xtrain,2), dmso, 'b-');
% xlabel('Time');ylabel('Motion Index');
% axis([1 10500 min(dmso) 1.05*max(dmso)]);
% figure();figure();plot(1:size(Xtrain,2), halo,'r-');
% xlabel('Time');ylabel('Motion Index');
% axis([1 10500 min(dmso) 1.05*max(dmso)]);

%% Back to classification

%Plots of before/after resampling
figure();plot(1:size(Xtrain,2), dmso, 'b-', 1:5:size(Xtrain,2), mean(dmso_data_resample),'r-');
title('Averaged data');legend('original','5x downsample','Location','best');
xlabel('Time');ylabel('Motion Index');
axis([1 10500 min(dmso) 1.05*max(dmso)]);

%% Now let's test out some classification algorithms

%This is for the raw data
Ypred = classify(Xtest,Xtrain,Ytrain,'diaglinear');
accuracy = mean(strcmp(Ypred,Ytest));
['The accuracy for raw data is: ' num2str(accuracy)]

Yresub = classify(Xtrain,Xtrain,Ytrain,'diaglinear');
resub_accuracy = mean(strcmp(Yresub,Ytrain));
['The resubstitution accuracy for raw data is: ' num2str(resub_accuracy)]

%This is for the resampled data
Ypred = classify(Xtest_resample,Xtrain_resample,Ytrain,'diaglinear');
accuracy = mean(strcmp(Ypred,Ytest));
['The accuracy for resample data is: ' num2str(accuracy)]

Yresub = classify(Xtrain_resample,Xtrain_resample,Ytrain,'diaglinear');
resub_accuracy = mean(strcmp(Yresub,Ytrain));
['The resubstitution accuracy for resample data is: ' num2str(resub_accuracy)]

%% Decision tree using all data as features
t = classregtree(Xtrain_resample, Ytrain);
class = eval(t,Xtest_resample);
acc = mean(strcmp(class,Ytest));
['The accuracy of decision tree is: ' num2str(acc)]
view(t)

%% Random forest (bagged decision trees)
% BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
%     'Method','classification','oobvarimp','on');
BaggedEnsemble = TreeBagger(50,Xtrain_resample,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest_resample);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest is: ' num2str(acc)]

%Here's some code to view the OOB prediction error as the tree number
%increases...
% oobErrorBaggedEnsemble = oobError(BaggedEnsemble);
% plot(oobErrorBaggedEnsemble)
% xlabel 'Number of grown trees';
% ylabel 'Out-of-bag classification error';

% %Now let's take a look at exactly what the first five decision trees look
% %like...
% for i = 1:5
%     view(BaggedEnsemble.Trees{i},'Mode','graph');
% end

%% Just some testing to make sure the new and old data are the same
% baseline = median(median(data));
% data_temp = data - baseline;
% old_data = mean(data_temp(1:12,[1:3750,4501:end]));
% 
% load('haloperidol_doseresponse.mat');
% % data_originalformat = data(:,[1:1500,2251:11250]);
% data_originalformat = data(:,[1:1500,2251:4500,5251:11250]);
% baseline = median(median(data_originalformat));
% data_originalformat = data_originalformat - baseline;
% new_data = mean(data_originalformat(1:12,:));
% 
% %Note: timepoints 1-750 are the baseline readings for the fish so we can
% %normalize for fish activity using these readings
% new_activity = mean(new_data(1:750));
% old_activity = mean(old_data(1:750));
% %Normalize the data by their baseline activity
% new_data = new_data ./ new_activity;
% old_data = old_data ./ old_activity;
% 
% figure();plot(1:5:size(old_data,2),resample(old_data,1,5),'b-',1:5:size(new_data,2),resample(new_data,1,5),'g-');
% title('Comparing old and new data');legend('Old Data','New Data');
% 
% %% Saving some data for future use
% %Saving the raw fish and conditions data
% condition_origbattery = DMSO;
% % save('originaldata.mat','data_origbattery','condition_origbattery','Xtrain','Ytrain');