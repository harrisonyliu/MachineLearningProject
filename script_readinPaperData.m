close all
clear all

data_path = 'F:\20160701_Kokel_dataset';
data_file = '2016-06-30-Reference-outputCSVs-MI.csv';
cond_file = '2016-06-30-Reference-outputCSVs-key.csv';
class_file = '2016-06-15-referenceSet-classes.csv';
stim_file = '2015-05-06-Retesting-11H3-stimFrames.csv';

data_fname = fullfile(data_path,data_file);
cond_fname = fullfile(data_path,cond_file);
class_fname = fullfile(data_path,class_file);
stim_fname = fullfile(data_path,stim_file);

[num,txt,~] = xlsread(stim_fname);
data_stim = num(1:10500,:);
%The only stimuli that matter are blue, purple, red LEDs, softSolenoid and
%the regular solenoid (hard taps)
desired_col = logical([1 1 1 0 1 1 0 0]);
headers_stim = txt(1,desired_col);
data_stim = data_stim(:,desired_col); 
plot_symbols = {'b-' 'm-' 'r-' 'k:' 'k'};
headers_stim(2,:) = plot_symbols;
figure(); hold on;
for i = 1:size(headers_stim,2)
    plot(1:10500,data_stim(:,i)*i*0.5,headers_stim{2,i});
end
title('Stimulus Plot');xlabel('Time');ylabel('Stimulus');
legend(headers_stim(1,:));ylim([0,3]);

%Now let's start assembling where the different stimuli appear. We want to
%track when the taps were performed and when the lights turned on/off.
lights = sum(data_stim(:,1:3)');
taps = sum(data_stim(:,4:5)');
lights_pulse = abs(diff(lights));
taps_pulse = max(0,diff(taps));
full_pulse = lights_pulse + taps_pulse;
plot(2:10500,full_pulse,'g-');

%Now let's resample this by 5x to fit the normalized data structure
new_pulse = [0 full_pulse];
temp = reshape(new_pulse, 5, 2100);
full_resample = sum(temp);
dmso_idx = strcmp(key_sorted(:,2),'DMSO'); dmso_data = mean(data_norm(dmso_idx,:));
figure();plot(1:2100, dmso_data, 'b-', 1:2100, full_resample, 'g-');
legend('DMSO', 'Pulse');

%Finally we create "windows" where we keep the data (=1), 0 everywhere else
%since we do not care about that data (2 points before stim, 8 pt after)
pulseIdx = find(full_resample == 1);
stimWindow = zeros(1,2100);
for i = 1:numel(pulseIdx)
    idx = pulseIdx(i);
    stimWindow(idx-2:idx + 7) = 1;
end
hold on; plot(1:2100,stimWindow*2,'r:');legend('DMSO','Pulse','Window');
title('Stimulus Linked Windowing'); xlabel('Time');

%Cropping out unnecessary data
test = dmso_data(logical(stimWindow));
figure();subplot(2,1,2);plot(1:length(test),test,'g-');title('Truncated Data');
xlim([1,length(test)]);
subplot(2,1,1);plot(1:2100,dmso_data,'b-');title('Original Data');
xlim([1,2100]);

halo_idx = strcmp(key_sorted(:,1),'HALOPERIDOL_25');
halo_data = mean(data_norm(halo_idx,:));
figure();subplot(2,1,1);plot(1:2100, dmso_data,'b-', 1:2100, halo_data,'g-');
title('Original Data');legend('DMSO','Haloperidol 25');xlim([1 2100]);ylim([min(dmso_data) max(dmso_data)]);
subplot(2,1,2);plot(1:length(test),test,'b-',1:length(test),halo_data(logical(stimWindow)),'g-');
title('Truncated Data');legend('DMSO','Haloperidol 25');xlim([1 length(test)]);ylim([min(test) max(test)]);

%Resampling data_stim by a factor of five
data_stim_norm = zeros(size(data_stim,1)/5,size(data_stim,2));
for i = 1:size(data_stim,2)
    temp =data_stim(:,i);
    temp_stim = reshape(temp,5,numel(temp)/5);
    data_stim_norm(:,i) = sum(temp_stim);
end
    
% [key,key_cmpd,key_conc,key_class,key_classonly,data,plateNames] = extractBehaviorData(data_fname, cond_fname, class_fname);
[headers_orig, res_orig] = createDrugIdxArray(cond_fname, class_fname, 'chemID_1'...
    , 'concentration_1', 'plateName', 'chemNames', 'chemClass');

%This section is for the new data from dave
data_path2 = 'F:\20160701_Kokel_dataset';
data_file2 = '2016-06-referenceSet-MI.csv';
cond_file2 = '2016-06-referenceSet-key2.csv';
class_file2 = '2016-06-referenceSet-classes_complete.csv';

data_fname2 = fullfile(data_path2, data_file2);
cond_fname2 = fullfile(data_path2,cond_file2);
class_fname2 = fullfile(data_path2,class_file2);
[headers, res] = createDrugIdxArray(cond_fname2, class_fname2, 'chemName_1'...
    , 'concentration_1', 'plateName', 'chemName_1', 'class');

data_key = [res_orig;res];
data_orig = csvread(data_fname);data_new = csvread(data_fname2,1,0,[1 0 5280 10499]);
data = [data_orig;data_new]; clear data_orig; clear data_new;
%Let's sort the data
[data_sorted,key_sorted] = sortBehaviorData(data, data_key, headers);
clear data; clear data_key;

%Plotting some data to ensure everything is fine
col_cmpd = strcmp(headers,'Cmpd');
col_fullname = strcmp(headers,'Full_cmpd_name');
dmso_idx = strcmp('DMSO',key_sorted(:,col_cmpd));
halo_idx = strcmp('HALOPERIDOL_50',key_sorted(:,col_fullname));
dmso_data = mean(data_sorted(dmso_idx,:));
halo_data = mean(data_sorted(halo_idx,:));
numData = length(dmso_data);
figure();plot(1:numData, dmso_data,'b-', 1:numData, halo_data,'g-');
title('Error Checking');xlabel('Time');ylabel('Motion Index');
legend('DMSO','Haloperidol');xlim([1 numData]);

%% Now let's normalize and filter the data

%Okay, let's now do some basic data normalization. For each plate: 1. find
%the DMSO treated fish in the plate 2. Subtract off the median of the data
%and divide all activity by the baseline (to normalize for more active
%spawns (use the normalizeFishData function).
col_plate = strcmp(headers,'PlateName');
unique_plates = unique(key_sorted(:,col_plate));
data_norm = zeros(size(data_sorted,1),size(data_sorted,2)/5);
% data_norm = zeros(size(data,1),size(data,2));
for i = 1:numel(unique_plates)
    curr_plateName = unique_plates{i};
    plateIdx = strcmp(key_sorted(:,col_plate),curr_plateName); %This is to find which rows belong to the current plate
    temp_data = data_sorted(plateIdx,:);
    temp_key = key_sorted(plateIdx,col_cmpd);
    dmso_idx = strcmp(temp_key,'DMSO');
    temp_norm = normalizeFishData(temp_data,dmso_idx,1);
    data_norm(plateIdx,:) = resample(temp_norm',1,5)';
%     data_norm(plateIdx,:) = temp_norm;
end
dmso_idx = strcmp('DMSO',key_sorted(:,col_cmpd));
halo_idx = strcmp('HALOPERIDOL_50',key_sorted(:,col_fullname));
dmso_data = mean(data_norm(dmso_idx,:));
halo_data = mean(data_norm(halo_idx,:));
numData = length(dmso_data);
figure();plot(1:numData, dmso_data,'b-', 1:numData, halo_data,'g-');
title('Error Checking, Normalized');xlabel('Time');ylabel('Motion Index');
legend('DMSO','Haloperidol');xlim([1 numData]);
save('data_fullset','key_sorted','data_norm','headers', 'headers_stim', 'data_stim_norm', 'stimWindow');

%% You can start running from here
mat_path = 'F:\Zebrafish Behavioral Data';
mat_fname = 'data_fullset.mat';
mat_fullname = fullfile(mat_path, mat_fname);
load(mat_fullname);
col_cmpd = strcmp(headers,'Cmpd');
col_class = strcmp(headers,'Cmpd_class');

col_class = strcmp(headers,'Cmpd_class');
key_truncIdx1 = strcmp(key_sorted(:,col_class),'Antipsychotic');
key_truncIdx2 = strcmp(key_sorted(:,col_cmpd),'DMSO');
key_truncIdx = logical(key_truncIdx1 + key_truncIdx2);
% key_sorted(key_truncIdx,col_cmpd)
figure();hold on; plotHandles = create_PCA_doseresponse3d(...
    key_sorted(key_truncIdx,:),headers,'Cmpd',data_norm(key_truncIdx,:),0);
grid on; axis vis3d;
% figure();hold on;create_PCA_doseresponse3d(key_sorted,headers,'Cmpd',data_norm,0)
% OptionZ.FrameRate = 30;OptionZ.Duration = 10; 
% CaptureFigVid([0 15; 360 15], '3D_PCA_movie_antidepressant_fulldata',OptionZ); 

plottingUI(key_sorted, data_norm(:,logical(stimWindow)), headers, headers_stim, data_stim_norm(logical(stimWindow),:));

%% Prototyping for the final UI over here
col_class = strcmp(headers,'Cmpd_class');
key_truncIdx1 = strcmp(key_sorted(:,col_class),'Antipsychotic');
key_truncIdx2 = strcmp(key_sorted(:,col_cmpd),'DMSO');
key_truncIdx = logical(key_truncIdx1 + key_truncIdx2);
% key_sorted(key_truncIdx,col_cmpd)
figure();hold on; [plotHandles, plotHandles_header] = create_PCA_doseresponse3d(...
    key_sorted(key_truncIdx,:),headers,'Cmpd',data_norm(key_truncIdx,:),0);

for i = 1:size(plotHandles,1)
    set(plotHandles{i,2},'Color',[.5 .5 .5],'LineWidth',2);
    for j = 1:size(plotHandles{i,1})
        temp = plotHandles{i,1};
        set(temp{j},'MarkerFaceColor',[.5 .5 .5]);
    end
end

col_class = strcmp(headers,'Cmpd_class');
key_truncIdx1 = strcmp(key_sorted(:,col_class),'Antidepressant');
key_truncIdx2 = strcmp(key_sorted(:,col_cmpd),'DMSO');
key_truncIdx = logical(key_truncIdx1 + key_truncIdx2);
% key_sorted(key_truncIdx,col_cmpd)
[plotHandles, plotHandles_header] = create_PCA_doseresponse3d(...
    key_sorted(key_truncIdx,:),headers,'Cmpd',data_norm(key_truncIdx,:),0);
grid on; axis vis3d;

figure();hold on; [plotHandles, plotHandles_header] = create_PCA_doseresponse3d(...
    key_sorted,headers,'Cmpd',data_norm,0);
grid on; axis vis3d;

col_handle_class = strcmp(plotHandles_header,'ClassName');
col_handle_marker = strcmp(plotHandles_header,'MarkerHandles');
col_handle_line = strcmp(plotHandles_header,'LineHandles');

setPCAcolor([0.5 0.5 0.5],plotHandles,col_handle_marker, col_handle_line,2);

%Now let's recolor the markers belonging to the class of interest
COI = 'Beta blocker';
dmso_idx = strcmp(plotHandles(:,col_handle_class),'Control');
COI_idx = strcmp(plotHandles(:,col_handle_class),COI);

%First set DMSO to black (just because)
setPCAcolor([0 0 0],plotHandles(dmso_idx,:),col_handle_marker,col_handle_line,3);

%Now set colors for the compound of interest
colors = hsv(sum(COI_idx));
setPCAcolor(colors,plotHandles(COI_idx,:),col_handle_marker,col_handle_line,3);
    

% %This is for different classes, but all at same concentration
% %Let's run some PCA!
% halo_idx = strcmp(key,'HALOPERIDOL_25');
% dmso_idx = strcmp(key,'DMSO_0');
% clo_idx = strcmp(key,'CLOZAPINE_50');
% thior_idx = strcmp(key,'THIORIDAZINE_50');
% eto_idx = strcmp(key,'ETOMIDATE_50');
% AG_idx = strcmp(key,'AG 825_50');
% clom_idx = strcmp(key,'CLOMIPRAMINE_50');
% ola_idx = strcmp(key,'OLANZEPINE_25');
% trac_idx = strcmp(key,'TRACAZOLATE_50');
% trac125_idx = strcmp(key,'TRACAZOLATE_12_5');
% prop_idx = strcmp(key,'PROPOFO_46_5');
% map_idx = strcmp(key,'MAPROTILINE_25');
% traz_idx = strcmp(key,'TRAZADONE_25');
% prog_idx = strcmp(key,'PROGESTERONE_50');
% desip_idx = strcmp(key,'DESIPRAMINE_50');
% relevant_idx = logical(dmso_idx + halo_idx + clo_idx + thior_idx +eto_idx...
%     + AG_idx + clom_idx + ola_idx + trac_idx + prop_idx + map_idx + ...
%     traz_idx + prog_idx);
% 
% %This will loop through all the classes of compounds separately and plot
% %individual drugs - looking for drugs that are "outliers" with respect to
% %their overall class
% unique_classes = unique(key_classonly);
% unique_classes(strcmp(unique_classes,'Control')) = [];
% for i = 1:numel(unique_classes)
%     temp_class = unique_classes{i};
%     relevant_idx = strcmp(key_classonly,temp_class);
%     relevant_idx = logical(relevant_idx + strcmp(key_classonly,'Control'));
%     create_PCA_doseresponse3d(key(relevant_idx),data_norm(relevant_idx,:),0)
%     axis vis3d; grid on;title([temp_class ' Only']);
% end
% 
% % %This is for one example drug of each class at multiple concentrations.
% % control_idx = strcmp(key_cmpd,'DMSO');
% % AG_idx = strcmp(key_cmpd,'AG 825');
% % halo_idx = strcmp(key_cmpd,'CLOZAPINE');
% % clom_idx = strcmp(key_cmpd,'CLOMIPRAMINE');
% % prop_idx = strcmp(key_cmpd,'PROGESTERONE');
% % trac_idx = strcmp(key_cmpd,'TRACAZOLATE');
% % relevant_idx = logical(control_idx + AG_idx + halo_idx + clom_idx + prop_idx...
% %     +trac_idx);
% 
% % create_PCA_doseresponse3d(key_class(relevant_idx),data_norm(relevant_idx,:))
% % create_PCA_doseresponse3d(key_class,data_norm,0)
% create_PCA_doseresponse3d(key,data_norm,0)
% axis vis3d; grid on;
% title('Only AG825, Clozapine, Clomipramine, Progesterone, Tracazolate; All concentrations')
% OptionZ.FrameRate = 30;OptionZ.Duration = 10;
% CaptureFigVid([0 15; 360 15], '3D_PCA_movie_selectedDrugs',OptionZ); 
% 
% dmso = mean(data_norm(dmso_idx,:));
% halo = mean(data_norm(halo_idx,:));
% clo = mean(data_norm(clo_idx,:));
% ola = mean(data_norm(ola_idx,:));
% prog = mean(data_norm(prog_idx,:));
% trac = mean(data_norm(trac_idx,:));
% trac125 = mean(data_norm(trac125_idx,:));
% map = mean(data_norm(map_idx,:));
% desip = mean(data_norm(desip_idx,:));
% traz = mean(data_norm(traz_idx,:));
% clom = mean(data_norm(clom_idx,:));
% numData = numel(dmso);
% figure();plot(1:numData, dmso, 'g-',1:numData,ola,'b-',1:numData,halo,'c-');
% legend('DMSO','Olanzipine','Haloperidol');xlim([1 numData]);