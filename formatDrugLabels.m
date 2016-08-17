function [cmpd, conc] = formatDrugLabels(cmpd_labels)
%res = formatDrugLabels(cmpd_labels). This is a simple function to replace
%any underscores ('_') in the label cell array to make the result more
%readable. For example PROGESTERONE_12_5 should be "PROGESTERONE 12.5" and
%this function will do the conversion
cmpd = cell(size(cmpd_labels,1),1); conc = cmpd;
for i = 1:numel(cmpd_labels)
    temp = cmpd_labels{i};
    underscores = findstr(temp,'_');
    cmpd{i} = temp(1:underscores(1)-1);
    temp_conc = temp(underscores(1)+1:end);
    temp_conc = strrep(temp_conc,'_','.');
    conc{i} = num2str(temp_conc);
end