close all
clear all

%% Data manipulation
%The problem with this dataset is that new assays were added to the old
%batter which was what the classifier was originally trained on. To get
%around this problem we will create a synthetic dataset by cutting and
%pasting together the original battery of assays together from the new
%data. Note: we also remove the VSR2 assay from the data since the old and
%new batteries have different stimuli for that assay

%Terminology: battery = total collection of all assays
%Assay = a sequence of stimuli, multiple assays are chained together to
%form a battery

%Approach: 1. load the data from the old and new batteries. data contains
%the fish data. Conditions contains the condition corresponding to each row
%of data. "Halo_12_5" means haloperidol @ 12.5uM
load('haloperidol_doseresponse.mat');
relevantIdx_newbattery = [1:1500,2251:4500,5251:11250]; %These are the chunks of data from the new battery that correspond to the stimuli from the original, old battery
relevantIdx_oldbattery = [1:3750,4501:size(data_oldbattery,2)];

%Now we need to normalize the data to remove any instrumentation / batch to
%batch fish variation. We do this by using the positive control (DMSO) fish
%to perform the normalization
data_newbattery = data_newbattery(:,relevantIdx_newbattery); %Only use the relevant data
% data_newbattery = resample(data_newbattery',1,5)'; %Doing some lowpass filtering
control_idx_new = strcmp(conditions_newbattery,'DMSO_0');
data_newbattery_normalized = normalizeFishData(data_newbattery,control_idx_new,1); %Note: the "1" at the end is the resampling rate, 1 for no resample (e.g. no lowpass filtering, just use the raw data)

%Now let's normalize the old data as well
data_oldbattery = data_oldbattery(:,relevantIdx_oldbattery);
% data_oldbattery = resample(data_oldbattery',1,5)'; %More lowpass filtering
control_idx_old = strcmp(conditions_oldbattery,'DMSO_0');
data_oldbattery_normalized = normalizeFishData(data_oldbattery,control_idx_old,1);

%Plot the old and new data against each other to ensure the normalization
%looks good.
numData = size(data_newbattery_normalized,2);
figure();plot(1:numData,mean(data_newbattery_normalized(control_idx_new,:)),'g-');
hold on; plot(1:numData,mean(data_oldbattery_normalized(control_idx_old,:)),'b-');
legend('New data','Old data');

%% Now let's do some classification!

%Experimental set-up: the new battery data contains data from fish exposed
%to various concentrations of Haloperidol ranging from 100uM to 1uM. Our
%classifier is trained on 25uM Haloperidol data so here we are just trying
%to see how well our classifier performs on data that it wasn't trained it.
%This isn't meant to be anything groundbreaking, I was just curious if the
%classifier would still be able to be able to classify lower/higher
%concentrations of Haloperidol.

class = classify(data_newbattery_normalized,data_oldbattery_normalized,conditions_oldbattery,'diaglinear');

%To compare this: see if class and conditions_newbattery are similar. I
%plotted the results in Excel, it appears as soon as we hit the Halo 12.5uM
%data, the classifier no longer performs well, which is to be expected

%% Other random code that may be useful later (not used right now)

%First let's load the data and find all the unique conditions we have to
%work with
% load('haloperidol_doseresponse.mat');
% [unique_conditions, ia, ic] = unique(conditions); %Note: ic contains line-by-line information as to which of the unique_conditions group the data belongs to

% %Now let's create a cell structure in which each element corresponds to a
% %listing of all the fish data that belongs to a particular unique_condition
% numConditions = numel(unique_conditions);
% fish_data = cell(numConditions,1);
% for i = 1:numel(ic)
%     conditionIdx = ic(i); %This is the unique_condition that this row belongs to
%     temp = fish_data{conditionIdx}; %Find the current list of indices that belongs to this condition
%     temp = [temp i]; %Here we save the index of the fish that belongs to this condition
%     fish_data{conditionIdx} = temp; %And finally overwrite/save the new index
% end

%% Testing of the above
%The following should return all the Haloperidol25 fish (the fifth
%unique_conditon
% unique_conditions(5)
% conditions(fish_data{5})