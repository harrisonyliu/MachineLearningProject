function create_PCA_doseresponse(conditions,data)
%create_PCA_doseresponse(conditions,data) - this function will create a 2D
%plot showing the two largest principal components. it is meant to take in
%dose-response data and show how dose affects the behavior of the larvae on
%a principal components space

conditions_unique = unique(conditions);

%Problem here: there exists a two-dimensional map: compound and
%concentration. We need to first separate the two, group all compounds
%together, then sort by concentration. Then we can plot the results into a
%PCA map one compound at a time
%First let's split the conditions by compounds
underscores = strfind(conditions_unique,'_');
cmpds = cell(size(conditions_unique)); conc = cell(size(cmpds));
for i = 1:numel(conditions_unique)
    temp = conditions_unique{i};
    cmpds{i} = temp(1:underscores{i,1}-1);
end

%Now let's go compound by compound, sorting by concentration, then adding
%it to the larger list of all possible compounds and concentrations
cmpds_unique = unique(cmpds); 
conditions_unique_sorted = cell(numel(cmpds_unique),2);
for i = 1:numel(cmpds_unique)
    unsorted_idx = strcmp(cmpds, cmpds_unique{i});
    unsorted_data = {conditions_unique{unsorted_idx}}';
    %Now let's sort by concentration
    underscores = strfind(unsorted_data,'_');
    conc = cell(size(unsorted_data));
    for j = 1:numel(unsorted_data)
        temp = unsorted_data{j};
        conc{j} = temp(underscores{j,1}+1:end);
    end
    %Now manipulate conc to turn it into actual numbers
    conc = strrep(conc,'_','.'); conc = str2double(conc);
    [conc_sorted,conc_idx] = sort(conc);
    sorted_conditions = {unsorted_data{conc_idx}}';
    conditions_unique_sorted{i,1} = cmpds_unique{i};
    conditions_unique_sorted{i,2} = sorted_conditions;
end

[~, score, ~] = pca(data);
figure();hold on; legend_str = {};
colors = colormap(hsv(size(conditions_unique_sorted,1)));
for j = 1:size(conditions_unique_sorted,1)
    temp = conditions_unique_sorted{j,2};
    legend_str = [legend_str; temp];
    %     colors = colormap(cSpace);
    %     coloridx = 1;
    if numel(temp) == 1
        mSize = 15;
    else
        mSize = linspace(15,3,numel(temp));
    end
    centers = zeros(numel(temp,2));
    for i = 1:numel(temp);
        %Find all the indices of the data corresponding to each condition
        temp_idx = strcmp(temp{i},conditions);
        plot(score(temp_idx,1),score(temp_idx,2),'o','Color',colors(j,:),'MarkerSize',mSize(i));
        centers(i,1) = median(score(temp_idx,1)); centers(i,2) = median(score(temp_idx,2));
    end
    conditions_unique_sorted{j,3} = centers;
end

%Here we plot the centers of each cluster
for i = 1:size(conditions_unique_sorted,1)
    centers = conditions_unique_sorted{i,3};
    plot(centers(:,1)',centers(:,2)','s-','Color',colors(i,:),...
        'MarkerSize',10,'LineWidth',3,'MarkerFaceColor',colors(i,:));
end

conditions_legend = strrep(legend_str,'_',' ');
legend(conditions_legend,'Location','Best');
title('PCA analysis of varying doses');
xlabel('Principal component 1'); ylabel('Principal component 2');