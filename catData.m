dir_name = 'C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Antipsychotics_data\HALOPERIDOL';
fname1 = fullfile(dir_name,'2016-04-22-2H4-MI.csv');
fname2 = fullfile(dir_name,'2016-04-26-2H4-MI.csv');
fname3 = fullfile(dir_name,'2016-04-27-2H4-MI.csv');
kname1 = fullfile(dir_name,'2016-04-22-2H4-Key.csv');
kname2 = fullfile(dir_name,'2016-04-26-2H4-Key.csv');
kname3 = fullfile(dir_name,'2016-04-27-2H4-Key.csv');

data1 = csvread(fname1); data2 = csvread(fname2); data3 = csvread(fname3);
data_newbattery = [data1;data2;data3];

[~,~, condition_cell1] = parseKey(kname1,'chemID_1','concentration');
[~,~, condition_cell2] = parseKey(kname2,'chemID_1','concentration');
[~,~, condition_cell3] = parseKey(kname3,'chemID_1','concentration');
conditions_newbattery = [condition_cell1; condition_cell2; condition_cell3];

fname_data_old = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Haloperidol_Data','consolidated_data.csv');
fname_key_old = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\MachineLearningProject\Data\Haloperidol_Data', 'consolidated_key.csv');
data_oldbattery = csvread(fname_data_old);
[~,~, conditions_oldbattery] = parseKey(fname_key_old,'DMSO','x0');

save('haloperidol_doseresponse.mat','data_newbattery','conditions_newbattery','data_oldbattery','conditions_oldbattery');