function [res_data, res_key] = sortBehaviorData(data, key, headers)
%res = sortBehaviorData(key, headers)
%This function will take in a cell array called "key" and a second cell
%array "headers" that describes the columns of key (for example, class,
%compound, concentration etc. It will also take in a data file that
%corresponds to the key (row for row). This function will start by grouping
%compounds together, then within the compound, sorting by concentration
%(lowest to highest). It will then return the resultant array with all the
%data.
col_cmpds = strcmp(headers,'Cmpd');
col_class = strcmp(headers, 'Cmpd_class');
col_conc = strcmp(headers, 'Concentration');

%Initial sorting of compounds by alphabetical order
[~,idx] = sort(key(:,col_cmpds));
key = key(idx,:); data = data(idx,:);
compounds_unique = unique(key(:,col_cmpds));

sortedIdx = []; %This will hold all our indices in sorted order for the very end
for i = 1:numel(compounds_unique)
    curr_cmpd = compounds_unique{i}; %The current compound we are looking at
    idx = strcmp(curr_cmpd,key(:,col_cmpds)); %These are the indices in the original index that belong to all examples of this compound
    idx_cmpd = find(idx == 1);
    temp = key(idx,col_conc); %These are all the concentrations that belong to our current compound
    [~,idx_sort] = sort(cell2mat(temp));
    sortedIdx = [sortedIdx; idx_cmpd(idx_sort)];
end
res_data = data(sortedIdx,:);
res_key = key(sortedIdx,:);