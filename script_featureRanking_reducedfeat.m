close all
clear all

mat_path = 'F:\Zebrafish Behavioral Data';
mat_fname = 'data_fullset.mat';
mat_fullname = fullfile(mat_path, mat_fname);
load(mat_fullname);
load stim_window.mat;
clear window
plottingUI(key_sorted, data_norm(:,logical(stimWindow)), headers, headers_stim, data_stim_norm(logical(stimWindow),:));

%First let's create a key that contains only the unique representations of
%each class/concentration

key_unique = cell(0); headers_unique = [headers {'Idx' 'TrainIdx' 'TestIdx'}];
col_cmpd_name = strcmp(headers,'Full_cmpd_name');
col_cmpd = strcmp(headers, 'Cmpd');
col_class = strcmp(headers,'Cmpd_class');
col_conc = strcmp(headers,'Concentration');
col_PlateName = strcmp(headers,'PlateName');
col_idx = strcmp(headers_unique,'Idx');
col_trainIdx = strcmp(headers_unique,'TrainIdx');
col_testIdx = strcmp(headers_unique,'TestIdx');
conditions_unique = unique(key_sorted(:,col_cmpd_name));

for i = 1:numel(conditions_unique)
    temp = conditions_unique{i};
    temp_idx = strcmp(key_sorted(:,col_cmpd_name),temp); %Rows which belong to the compound of interest = 1
    data_idx = find(temp_idx == 1); %This is the actual index of the rows which belong to the compound
    shuffle = randperm(numel(data_idx));
    cutoff = round(numel(shuffle)/4);
    testIdx = data_idx(shuffle(1:cutoff)); trainIdx = data_idx(shuffle(cutoff+1:end));
    curr_key = key_sorted(data_idx(1),:);
    key_unique(i,1:numel(curr_key)) = curr_key;
    key_unique(i,col_idx) = {data_idx};
    key_unique(i,col_trainIdx) = {trainIdx};
    key_unique(i,col_testIdx) = {testIdx};
end

[~,key_uniqueSorted] = sortBehaviorData(data_norm, key_unique, headers_unique);
% [err_matrix, testTrain, headers] = RFclassify(key_unique, headers_unique, data_norm(:,stimWindow), key, key_classonly)
include = {'EPHEDRINE (1R2S)'}; exclude = cell(0); category = 'Cmpd';
[deltaErr] = oneVsAllClassify(data_norm(:,logical(stimWindow)), key_unique, key_sorted, headers_unique, category, include, exclude);

%Here I want to replot the heatmap, but with all the different
%concentration data present as well...
dmso_idx = strcmp(key_sorted(:,col_cmpd),'DMSO');
dmso_data = mean(data_norm(dmso_idx,logical(stimWindow)));
cmpd_idx = strcmp(key_uniqueSorted(:,col_cmpd),include); %Find all the data relating to target compound + concentrations
temp_key = key_uniqueSorted(cmpd_idx,:); %This contains all the information pertaining to the compound of interest
numConc = size(temp_key,1); %This is how many unique concentrations that exist
figure(); g = subplot(3,1,1); hold on; c = colormap(autumn(numConc));
plot(1:numel(dmso_data),dmso_data);
for i = 1:numConc
    temp_data_idx = temp_key{i,col_idx}; %These are the data indices pertaining to the current compound + concentration of interest
    temp_data = data_norm(temp_data_idx,logical(stimWindow));
    temp_mean = mean(temp_data);
    plot(1:numel(temp_mean),temp_mean,'Color', c(i,:));
end

%Let's make the legend
temp_legend = cell(1,size(temp_key,1));
for i = 1:size(temp_key,1)
    temp_legend{i} = [temp_key{i,col_cmpd} ' ' num2str(temp_key{i,col_conc})];
end
legend(['DMSO' temp_legend]);
title('Feature Importance Rankings'); xlabel('Feature (Time)');
colormap(jet);
h = subplot(3,1,2);heatmap(deltaErr,1:length(deltaErr));
f = subplot(3,1,3); hold on;
data_stim = data_stim_norm(logical(stimWindow),:);
for i = 1:size(headers_stim,2)
    plot(1:numel(temp_mean),data_stim(:,i)*i*0.5,headers_stim{2,i});
end
title('Stimulus Plot');xlabel('Time');ylabel('Stimulus');
legend(headers_stim(1,:));ylim([-.2,3]);
linkaxes([g, h, f],'x');xlim([1 numel(temp_mean)]);

    