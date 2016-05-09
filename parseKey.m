function [unique_conditions, condition_idx, condition_cell] = parseKey(filename)
%This function will take in a .csv file that contains the identity of each
%well and the chemical/concentration that was placed in that well. It will
%return two cells. unique_conditions contains all the unique conditions
%that were in the experiment. condition_idx will return the row/wellIDs
%that are associated with that particular condition. condition_cell
%contains the raw chemical + concentration data for double checking
%purposes

[NUM_key,TXT_key,RAW_key] = xlsread(filename);

%Let's find out the different treatment conditions first
chem_cell = strfind(TXT_key(1,:),'chemID');
chem_idx = find(~cellfun(@isempty,chem_cell));
chem = TXT_key(2:end,chem_idx);
conc_cell = strfind(TXT_key(1,:),'concentration');
conc_idx = find(~cellfun(@isempty,conc_cell));
conc = NUM_key(:,conc_idx);

%Now that we know the chemicals and concentrations, let's concatenate them
%together to form a final treatment condition matrix
condition_cell = cell(1,length(conc));
for i = 1:length(conc)
    condition_cell{i} = [chem{i} num2str(conc(i))];
end

%Now let's find out the unique conditions (since there will be many
%replicates of each condition
unique_conditions = unique(condition_cell)';

%Now that we know the unique conditions let's create a vector that contains
%all the indices that match each condition
condition_idx = cell(length(unique_conditions),1);
for i = 1:numel(unique_conditions)
    temp = strfind(condition_cell,unique_conditions{i});
    condition_idx{i} = find(~cellfun(@isempty,temp));
end