%This script will take the data given to it and for each fish extract 780
%features that best describe the data. It will then find all the unique
%experimental treatment groups (compound and concentration) and group fish
%that were treated the same together and average their features. It will
%then compute the 780 features associated with the fish by finding all
%possible pairings and taking ratios.

%To use this script run it. A dialogue box will pop up: select the data
%file, then the key file and it should run fine after that.

close all
clear all

% filename_data = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\Data','2016-01-27-p0003-S01-01-DHI-1837-MI.csv');
% filename_key = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\Data','2016-01-27-p0003-S01-01-DHI-1837-key_1.csv');

[FileName_data,PathName_data] = uigetfile('.csv');
[FileName_key,PathName_key] = uigetfile('.csv');

filename_data = fullfile(PathName_data, FileName_data);
filename_key = fullfile(PathName_key, FileName_key);

[NUM,TXT,RAW] = xlsread(filename_data);
[unique_conditions, condition_idx, condition_cell] = parseKey(filename_key);

% %We need to do some basic pre-processing: let's baseline the fish by taking
% %the initial assay 1 (no stimulus) and subtracting that from all the data
% %such that the baseline activity of the fish is removed
% fishdata = zeros(size(NUM));
% for i = 1:size(NUM,1)
%     temp = NUM(i,:); 
%     baseline = mean(temp(1:750)); %This is the baseline activity of fish i
%     fishdata(i,:) = temp - baseline;
% end

%Now let's create a matrix in which we can store all that (averaged) data
condition_names = unique_conditions;
num_conditions = numel(condition_names);

%Now let's extract features for each fish
numfeat = 780;
fish_features = zeros(size(NUM,1),numfeat);
for i = 1:size(NUM,1)
    temp = NUM(i,:); %This is the data for an individual fish
    temp_assay = splitAssays(temp,0); %Split the data into corresponding assays
    fish_features(i,:) = behaviorFeatures(temp_assay);
end
    
%Let's quickly rectify and rescale all the features to help display
% rectify = repmat(min(fish_features),size(fish_features,1),1);
% fish_rectify = fish_features + abs(rectify);
scaling = repmat(max(fish_features),size(fish_features,1),1);
fish_rescaled = fish_features ./ scaling;

%Now finally let's assign everything to the correct groups and average it
data_avg = zeros(num_conditions,size(fish_rescaled,2));
data_std = data_avg;
for i = 1:num_conditions
    data_raw = fish_rescaled(condition_idx{i},:);
    data_avg(i,:) = mean(data_raw);
    data_std(i,:) = std(data_raw);
end

%Quick comparison test of the + and DHI200 controls:
figure();plot(1:780,data_avg(1,:),'b-',1:780,data_avg(end,:),'r-');
legend('DMSO','200uM DMSO'); title('Actual Feature Difference Plot');

figure();plot(1:780, data_avg(1,:) - data_avg(end,:),'bo');
title('Feature Difference');
