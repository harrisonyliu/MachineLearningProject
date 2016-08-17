function [key,key_cmpd,key_conc,key_class,key_classonly,data,plateNames] = extractBehaviorData(data_fname, cond_fname, class_fname)
%[key,key_cmpd,key_conc,key_class,data] = extractBehaviorData(data_fname, cond_fname, class_fname)
%This function will take in the filenames of different files and extract
%out the relevant information for future use.

data = csvread(data_fname);
[cond_num,cond_txt,~] = xlsread(cond_fname);
[~,class_txt,~] = xlsread(class_fname);

%Here we find the compound name and concentrations
col_cmpd = strcmp(cond_txt(1,:),'chemID_1');
col_conc = strcmp(cond_txt(1,:),'concentration_1');
key_cmpd = cond_txt(2:end,col_cmpd);
key_cmpd = strrep(key_cmpd,'MAPROTALINE','MAPROTILINE');
key_conc = cond_num(:,col_conc);
key_conc_str = cellstr(num2str(key_conc)); 
key_conc_str = strrep(key_conc_str',' ','')'; key_conc_str = strrep(key_conc_str','.','_')';

%Concatenate the compound name and the concentration together
key = cell(numel(key_cmpd),1);
for i = 1:numel(key_cmpd)
    key{i} = [key_cmpd{i} '_' key_conc_str{i}];
end

%Now let's assign each compound a class. Starting from a class of
%compounds, find all wells that are treated with that compound, and then
%assign them the class name
key_class = cell(size(key_cmpd));key_classonly = key_class;
for i = 2:numel(class_txt(:,2))
    drug_name = class_txt{i,2};
    class_name = class_txt{i,1};
    temp_idx = strcmp(key_cmpd,drug_name); drug_idx = find(temp_idx);
    for j = 1:sum(temp_idx)
        key_classonly{drug_idx(j)} = class_name;
        key_class{drug_idx(j)} = [class_name '_' key_conc_str{drug_idx(j)}];
    end
end

%Now let's find out what plates there are in the dataset
col_plate = strcmp(cond_txt(1,:),'plateName');
plateNames = cond_txt(2:end,col_plate);