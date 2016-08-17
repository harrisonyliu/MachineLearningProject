%% First we need to deal with reading in all the data

% %First load the clozapine data
% pathname_clo = 'C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Antipsychotics_data\CLOZAPINE';
% filename_clo1 = '2016-04-22-3E5-MI.csv'; clo1_fname = fullfile(pathname_clo,filename_clo1);
% filename_clo2 = '2016-04-26-3E5-MI.csv'; clo2_fname = fullfile(pathname_clo,filename_clo2);
% filename_clo3 = '2016-04-27-3E5-MI.csv'; clo3_fname = fullfile(pathname_clo,filename_clo3);
% filename_clo_conditions = '2016-04-22-3E5-Key.csv'; clo_fname_conditions = fullfile(pathname_clo,filename_clo_conditions);
% NUM1 = csvread(clo1_fname); NUM2 = csvread(clo2_fname); NUM3 = csvread(clo3_fname);
% data_clo = [NUM1;NUM2;NUM3];
% [num,txt,~] = xlsread(clo_fname_conditions);
% conditions_clo = cell(size(num,1),1);
% for i = 1:size(num,1)
%     conditions_clo{i} = [txt{i+1,3} '_' num2str(num(i,4))];
% end
% conditions_clo = repmat(conditions_clo,3,1);
% 
% %Now let's load the thioridazine data
% pathname_thior = 'C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Antipsychotics_data\THIORIDAZINE';
% filename_thior1 = '2016-04-27-3E6-MI.csv'; thior1_fname = fullfile(pathname_thior,filename_thior1);
% filename_thior2 = '2016-04-28-2H8-MI.csv'; thior2_fname = fullfile(pathname_thior,filename_thior2);
% filename_thior3 = '2016-04-29-2H8-MI.csv'; thior3_fname = fullfile(pathname_thior,filename_thior3);
% filename_thior1_conditions = '2016-04-27-3E6-Key.csv'; thior1_fname_conditions = fullfile(pathname_thior,filename_thior1_conditions);
% filename_thior2_conditions = '2016-04-28-2H8-Key.csv'; thior2_fname_conditions = fullfile(pathname_thior,filename_thior2_conditions);
% filename_thior3_conditions = '2016-04-29-2H8-Key.csv'; thior3_fname_conditions = fullfile(pathname_thior,filename_thior3_conditions);
% NUM1 = csvread(thior1_fname); NUM2 = csvread(thior2_fname); NUM3 = csvread(thior3_fname);
% data_thior = [NUM1;NUM2;NUM3];
% concentration = cell(1,3);condition_name = cell(1,3);
% [concentration{1},condition_name{1},~] = xlsread(thior1_fname_conditions);
% [concentration{2},condition_name{2},~] = xlsread(thior2_fname_conditions);
% [concentration{3},condition_name{3},~] = xlsread(thior3_fname_conditions);
% 
% conditions_thior = cell(size(concentration{1},1)*3,1);
% idx = 1;
% for i = 1:3
%     for j = 1:size(concentration{i},1)
%         txt = condition_name{i}; num = concentration{i};
%         conditions_thior{idx} = [txt{j+1,3} '_' num2str(num(j,4))];
%         idx = idx + 1;
%     end
% end
% 
% % Now we can save this data
% save('clo_thior_data.mat','data_clo','conditions_clo','data_thior','conditions_thior');

%% Actual analysis
close all
clear all

%This is the clozapine and thioridazine data
load('clo_thior_data.mat');

%This is the haloperidol dose response data
load('haloperidol_doseresponse.mat');
data_halo = data_newbattery; clear data_newbattery;
conditions_halo = conditions_newbattery; clear conditions_newbattery;
relevantIdx_newbattery = [1:1500,2251:4500,5251:11250]; %These are the chunks of data from the new battery that correspond to the stimuli from the original, old battery
relevantIdx_oldbattery = [1:3750,4501:size(data_oldbattery,2)];

%Resample all the data by 5x to remove high frequency noise
data_halo = resample(data_halo',1,5)';
data_thior = resample(data_thior',1,5)';
data_clo = resample(data_clo',1,5)';

numData = size(data_clo,2);
figure();plot(1:numData,mean(data_halo(1:12,:)),'b-',1:numData,mean(data_clo(1:12,:)),'r-',...
    1:numData,mean(data_thior(1:12,:)),'g-');
title('Positive Control Data, unnormalized but resampled');legend('Halo', 'Clozapine', 'Thioridazine');
xlabel('Time');ylabel('Motion Index');

%Now let's find all the dmso control indices
clo_dmsoIdx = [];
for i = 1:numel(conditions_clo)
    if isempty(strfind(conditions_clo{i},'DMSO')) == 0
        clo_dmsoIdx = [clo_dmsoIdx i];
    end
end

halo_dmsoIdx = [];
for i = 1:numel(conditions_halo)
    if isempty(strfind(conditions_halo{i},'DMSO')) == 0
        halo_dmsoIdx = [halo_dmsoIdx i];
    end
end

thior_dmsoIdx = [];
for i = 1:numel(conditions_thior)
    if isempty(strfind(conditions_thior{i},'DMSO')) == 0
        thior_dmsoIdx = [thior_dmsoIdx i];
    end
end

%Normalize all the data to the positive controls of each condition
data_clo = normalizeFishData(data_clo,clo_dmsoIdx,5);
data_thior = normalizeFishData(data_thior,thior_dmsoIdx,5);
data_halo = normalizeFishData(data_halo,halo_dmsoIdx,5);

figure();plot(1:numData, mean(data_halo(1:12,:)), 'r-', 1:numData, mean(data_clo(1:12,:)), 'b-',...
    1:numData, mean(data_thior(1:12,:)), 'g-'); title('Normalized Fish Data');
xlabel('Time');ylabel('Motion Index (Normalized and resampled)');
legend('Haloperidol', 'Clozapine', 'Thioridazine');
axis([1 numData min(mean(data_halo(1:12,:))) max(mean(data_halo(1:12,:)))]);

% %First let's do a little bit of data sorting
% temp = conditions_halo;
% temp = strrep(conditions_halo_sort,'Haloperidol_','');
% temp = strrep(conditions_halo_sort,'DMSO_','');
% temp = strrep(conditions_halo_sort,'_','.');
% [conc_sorted, conc_idx] = sort(str2double(temp));
% conditions_halo_sorted = conditions_halo(conc_idx);
% data_halo_sorted = data_halo(conc_idx,:); 


%Great! We don't have a lot of data to train with, so why don't we start
%off by just seeing if we can track how a drug changes as its concentration
%decreases. Let's start off by investigating haloperidol...
create_PCA_doseresponse(conditions_halo,data_halo);
title('PCA analysis of varying dose, haloperidol');
create_PCA_doseresponse(conditions_clo,data_clo);
title('PCA analysis of varying dose, clozapine');
create_PCA_doseresponse(conditions_thior,data_thior);
title('PCA analysis of varying dose, thioridazine');

create_PCA_doseresponse([conditions_halo; conditions_clo; conditions_thior],...
    [data_halo; data_clo; data_thior]);
title('PCA analysis of varying dose, Aggregated');

%% For this section let's apply the clustering to different drugs!
%Let's use 25uM as the standard concentration each of haloperidol,
%clozapine and thioridazine. We shall also compare them against DMSO as the
%control.

%First let's grab all the data, going from DMSO, to halo, to thior
idx_dmso_halo = strcmp(conditions_halo,'DMSO_0');
idx_dmso_clo = strcmp(conditions_clo,'DMSO_0');
idx_dmso_thior = strcmp(conditions_thior,'DMSO_0');
pcaData_dmso = [data_halo(idx_dmso_halo,:); data_clo(idx_dmso_clo,:); data_thior(idx_dmso_thior,:)];
pcaCondition_dmso = repmat(cellstr('DMSO_0'),size(pcaData_dmso,1),1);

%25uM halo data
idx_halo_25 = strcmp(conditions_halo,'Haloperidol_25');
pcaData_halo_25 = data_halo(idx_halo_25,:);
pcaCondition_halo = repmat(cellstr('Haloperidol_25'),size(pcaData_halo_25,1),1);

%25uM clozapine data
idx_clo_25 = strcmp(conditions_clo,'Clozapine_25');
pcaData_clo_25 = data_clo(idx_clo_25,:);
pcaCondition_clo = repmat(cellstr('Clozapine_25'),size(pcaData_clo_25,1),1);

%25uM thioridazine data
idx_thior_25 = strcmp(conditions_thior,'Thioridazine_25');
idx_thior_21 = strcmp(conditions_thior,'Thioridazine_21.5');
pcaData_thior_25 = data_thior(logical(idx_thior_25 + idx_thior_21),:);
pcaCondition_thior = repmat(cellstr('Thioridazine_25'),size(pcaData_thior_25,1),1);

%Now aggregate everything together and plot the results!
pcaData = [pcaData_dmso; pcaData_halo_25; pcaData_clo_25; pcaData_thior_25];
pcaCondition = [pcaCondition_dmso; pcaCondition_halo; pcaCondition_clo; pcaCondition_thior];
% create_PCA_doseresponse(pcaCondition, pcaData);
create_PCA_doseresponse3d([conditions_halo; conditions_clo; conditions_thior],...
    [data_halo; data_clo; data_thior]); axis vis3d; grid on;
OptionZ.FrameRate = 30;OptionZ.Duration = 10;
CaptureFigVid([0 15; 360 15], '3D_PCA_movie_antipsychotics',OptionZ); 

%% Here we create some random forest classifiers to see how well we can classify pairs of drugs
%Based upon the previous PCA results we would expect that halo would be the
%   hardest to distinguish from the other antipsychotics

%First let's see if we can classify each of the drugs from dmso
rng = 1;
shuffle_drug = randperm(numel(pcaCondition_halo));
shuffle_dmso = randperm(numel(pcaCondition_dmso));

Xtrain_halo = pcaData_halo_25(shuffle_drug(1:26),:);
Xtrain_clo = pcaData_clo_25(shuffle_drug(1:26),:);
Xtrain_thior = pcaData_thior_25(shuffle_drug(1:26),:);
Xtrain_dmso = pcaData_dmso(shuffle_dmso(1:81),:);

Ytrain_halo = pcaCondition_halo(shuffle_drug(1:26));
Ytrain_clo = pcaCondition_clo(shuffle_drug(1:26));
Ytrain_thior = pcaCondition_thior(shuffle_drug(1:26));
Ytrain_dmso = pcaCondition_dmso(shuffle_dmso(1:81));

Xtest_halo = pcaData_halo_25(shuffle_drug(27:end),:);
Xtest_clo = pcaData_clo_25(shuffle_drug(27:end),:);
Xtest_thior = pcaData_thior_25(shuffle_drug(27:end),:);
Xtest_dmso = pcaData_dmso(shuffle_dmso(82:end),:);

Ytest_halo = pcaCondition_halo(shuffle_drug(27:end));
Ytest_clo = pcaCondition_clo(shuffle_drug(27:end));
Ytest_thior = pcaCondition_thior(shuffle_drug(27:end));
Ytest_dmso = pcaCondition_dmso(shuffle_dmso(82:end));

%Now let's do some classification!
%Testing halo and dmso
Xtrain = [Xtrain_halo; Xtrain_dmso]; %First test halo and dmso
Ytrain = [Ytrain_halo; Ytrain_dmso];
Xtest = [Xtest_halo; Xtest_dmso]; Ytest = [Ytest_halo; Ytest_dmso];
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for haloperidol is: ' num2str(acc)]

%Testing thior and dmso
Xtrain = [Xtrain_thior; Xtrain_dmso]; %First test halo and dmso
Ytrain = [Ytrain_thior; Ytrain_dmso];
Xtest = [Xtest_thior; Xtest_dmso]; Ytest = [Ytest_thior; Ytest_dmso];
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for thioridazine is: ' num2str(acc)]

%Testing clo and dmso
Xtrain = [Xtrain_clo; Xtrain_dmso]; %First test halo and dmso
Ytrain = [Ytrain_clo; Ytrain_dmso];
Xtest = [Xtest_clo; Xtest_dmso]; Ytest = [Ytest_clo; Ytest_dmso];
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for clopazine is: ' num2str(acc)]

%% Now let's try classifying the drugs against each other!

%Testing clo and thior
Xtrain = [Xtrain_clo; Xtrain_thior]; %First test halo and dmso
Ytrain = [Ytrain_clo; Ytrain_thior];
Xtest = [Xtest_clo; Xtest_thior]; Ytest = [Ytest_clo; Ytest_thior];
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for clopazine vs. thoridazine is: ' num2str(acc)]

%Testing clo and halo
Xtrain = [Xtrain_clo; Xtrain_halo]; %First test halo and dmso
Ytrain = [Ytrain_clo; Ytrain_halo];
Xtest = [Xtest_clo; Xtest_halo]; Ytest = [Ytest_clo; Ytest_halo];
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for clopazine vs. haloperidol is: ' num2str(acc)]

%Lastly, thior and halo
Xtrain = [Xtrain_thior; Xtrain_halo]; %First test halo and dmso
Ytrain = [Ytrain_thior; Ytrain_halo];
Xtest = [Xtest_thior; Xtest_halo]; Ytest = [Ytest_thior; Ytest_halo];
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for thioridazine vs. haloperidol is: ' num2str(acc)]

%% Let's plot some of the drug data vs. each other as well as vs. DMSO
temp1 = mean(pcaData_dmso); temp2 = mean(pcaData_halo_25);
temp3 = mean(pcaData_clo_25); temp4 = mean(pcaData_thior_25); 
figure();plot(1:numData,temp1,'k-',1:numData,temp2,'g-',1:numData,temp3,'m-',1:numData,temp4,'c-');
title('Averaged, normalized data');xlabel('Time');
ylabel('Normalized motion index');legend('DMSO','Halo','Clo','Thior');
axis([1 numData min([temp1 temp2 temp3 temp4]) max([temp1 temp2 temp3 temp4])]);
