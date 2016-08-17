function [headers, res] = createDrugIdxArray(cond_fname, class_fname, chemName, concName, plateName, chemNameInClassFile, className)
%createDrugIdxArray(data_fname, cond_fname, class_fname, chemName, concName, chemNameInClassFile, className)
%This function extract the movement data, drug names, concentrations, and
%drug class names from the listed files. The list of indices that correspond to rows in data that
%belong to each drug group will also be listed in the appropriate row in
%res. "chemName" refers to the drug in question (located in the key file).
%concName refers to the name of the column containing concentration
%information (located in the key file). chemNameInClassFile refers to the
%chemical name in the class file. className refers to the column
%corresponding to the drug class in the class file.

[cond_num,cond_txt,~] = xlsread(cond_fname);
[~,class_txt,~] = xlsread(class_fname);

headers = {'Full_cmpd_name' 'Cmpd' 'Cmpd_class' 'Concentration'...
    'PlateName'};
numObs = size(cond_txt,1)-1;
res = cell(numObs,5);

col_cmpd = strcmp(cond_txt(1,:),chemName);
col_conc = strcmp(cond_txt(1,:),concName);
col_plate = strcmp(cond_txt(1,:),plateName);
res(:,2) = cond_txt(2:end,col_cmpd);
res(:,4) = num2cell(cond_num(:,col_conc));
res(:,5) = cond_txt(2:end,col_plate);
key_conc_str = cellstr(num2str(cell2mat(res(:,4)))); 
key_conc_str = strrep(key_conc_str',' ','')'; key_conc_str = strrep(key_conc_str','.','_')';

for i = 1:numObs
    res{i,1} = [res{i,2} '_' key_conc_str{i}];
end

%Here we assign classes (or at least attempt to)
[~,class_txt,~] = xlsread(class_fname);
col_cmpd_class = strcmp(class_txt(1,:),chemNameInClassFile);
col_class = strcmp(class_txt(1,:),className);
classNames = class_txt(2:end,col_class);
cmpdNames = class_txt(2:end,col_cmpd_class);
for i = 1:numObs
    classIdx = strcmp(res(i,2),cmpdNames);
    res{i,3} = classNames{classIdx};
end