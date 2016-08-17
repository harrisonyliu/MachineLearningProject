function createDrugPlot(data, key, headers, cmpd, conc, headers_stim, data_stim)
%createDrugPlot(data, key, headers, cmpd, conc) This will create a graph
%tracking the average motion index of fish given a certain compound and
%concentration.

col_conc = strcmp(headers,'Concentration');
col_cmpd = strcmp(headers,'Cmpd');
col_fullname = strcmp(headers,'Full_cmpd_name');
numObs = size(data,2);

cmpd_names = cell(numel(cmpd),1);
legend_names = cmpd_names;
conc_idx = cmpd_names;
avgdata = zeros(numel(cmpd),numObs);
figure(); h1 = subplot(2,1,1); hold on; colors = 'bgc';
for i = 1:numel(cmpd)
    legend_names{i} = [cmpd{i} ' ' conc{i}];
    temp = [cmpd{i} '_' conc{i}];
    temp = strrep(temp,'.','_');
    cmpd_names{i} = temp;
    conc_idx{i} = strcmp(key(:,col_fullname),cmpd_names{i});
    avgdata(i,:) = mean(data(conc_idx{i},:));
    plot(1:numObs,avgdata(i,:),'-','Color',colors(i));
end
xlim([1 numObs]); legend(legend_names);ylim([0 8]);
titlestr = 'Average MI traces of ';
for i = 1:numel(cmpd)-1
    titlestr = [titlestr cmpd{i} ', '];
end
titlestr = [titlestr 'and ' cmpd{end}]; title(titlestr);
xlabel('Time'); ylabel('Normalized Motion Index');

h2 = subplot(2,1,2); hold on;
for i = 1:size(headers_stim,2)
    plot(1:numObs,data_stim(:,i)*i*0.5,headers_stim{2,i});
end
title('Stimulus Plot');xlabel('Time');ylabel('Stimulus');
legend(headers_stim(1,:));ylim([-.2,3]); linkaxes([h1, h2],'x');
