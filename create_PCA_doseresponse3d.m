function [plotHandles, plotHandles_header] = create_PCA_doseresponse3d(varargin)
%create_PCA_doseresponse(conditions,data,dispOption) - this function will create a 2D
%plot showing the two largest principal components. it is meant to take in
%dose-response data and show how dose affects the behavior of the larvae on
%a principal components space. dispOption = 1 if you want the individual
%datapoints plotted, dispOption = 0 otherwise (default 1)

% conditions_unique = unique(conditions);
% [~, score, ~] = pca(data);
% figure();hold on; colors = 'rgbcmyk';
% coloridx = 1;
% for i = 1:numel(conditions_unique);
%     %Find all the indices of the data corresponding to each condition
%     temp_idx = strcmp(conditions_unique{i},conditions);
%     if coloridx > 6
%         coloridx = 1;
%     else
%         coloridx = coloridx + 1;
%     end
%     plot3(score(temp_idx,1),score(temp_idx,2),score(temp_idx,3),[colors(coloridx) '*']);
% end
% conditions_legend = strrep(conditions_unique,'_',' ');
% legend(conditions_legend,'Location','Best');
% title('PCA analysis of varying doses');
% xlabel('Principal component 1'); ylabel('Principal component 2');zlabel('Principal component 3');

key = varargin{1};
headers = varargin{2};
separation = varargin{3}; %The variable by which we wish to separate by (example, compound class, or maybe compound name)
data = varargin{4};
if numel(varargin) == 3
    dispOption = 1;
else
    dispOption = varargin{5};
end

% %Problem here: there exists a two-dimensional map: compound and
% %concentration. We need to first separate the two, group all compounds
% %together, then sort by concentration. Then we can plot the results into a
% %PCA map one compound at a time
% %First let's split the conditions by compounds
% underscores = strfind(conditions_unique,'_');
% cmpds = cell(size(conditions_unique)); conc = cell(size(cmpds));
% for i = 1:numel(conditions_unique)
%     temp = conditions_unique{i};
%     cmpds{i} = temp(1:underscores{i,1}-1);
% end
% 
% %Now let's go compound by compound, sorting by concentration, then adding
% %it to the larger list of all possible compounds and concentrations
% cmpds_unique = unique(cmpds); 
% conditions_unique_sorted = cell(numel(cmpds_unique),2);
% for i = 1:numel(cmpds_unique)
%     unsorted_idx = strcmp(cmpds, cmpds_unique{i});
%     unsorted_data = {conditions_unique{unsorted_idx}}';
%     %Now let's sort by concentration
%     underscores = strfind(unsorted_data,'_');
%     conc = cell(size(unsorted_data));
%     for j = 1:numel(unsorted_data)
%         temp = unsorted_data{j};
%         conc{j} = temp(underscores{j,1}+1:end);
%     end
%     %Now manipulate conc to turn it into actual numbers
%     conc = strrep(conc,'_','.'); conc = str2double(conc);
%     [conc_sorted,conc_idx] = sort(conc);
%     sorted_conditions = {unsorted_data{conc_idx}}';
%     conditions_unique_sorted{i,1} = cmpds_unique{i};
%     conditions_unique_sorted{i,2} = sorted_conditions;
% end


col_cond = strcmp(headers,separation);
col_conc = strcmp(headers,'Concentration');
conditions_unique = unique(key(:,col_cond));
col_cmpd = strcmp(headers,'Cmpd');
col_class = strcmp(headers,'Cmpd_class');

%For each condition (e.g. 'Antipsychotic' or 'Haloeperidol' find all the
%associated concentrations.  The marker size will depend on the
%concentration, with lower concentrations meaning larger circle sizes. Then
%plot all the data and keep track of all the centroids
[~, score, ~] = pca(data);
% for i = 1:size(score,1)
%     score(i,:) = log(score(i,:));
% end
legend_str = {};
colors = colormap(hsv(size(conditions_unique,1)));
centers = cell(numel(conditions_unique),1); %This cell array will keep track of the centroids of each cluster of PCA points
plotHandles = cell(numel(conditions_unique,4));
plotHandles_header = {'MarkerHandles', 'LineHandles','CmpdName','ClassName'};

for i = 1:numel(conditions_unique)
    curr_condition = conditions_unique{i}; %The current condition we are looking at
    curr_idx = strcmp(key(:,col_cond),curr_condition); %All the data indices corresponding to the current condition
    conc_unique = unique(cell2mat(key(curr_idx,col_conc))); %Number of unique concentrations
    key_currCmpd = key(curr_idx,:);
    plotHandles(i,3) = key_currCmpd(1,col_cmpd);
    plotHandles(i,4) = key_currCmpd(1,col_class);
    score_currCmpd = score(curr_idx,:); %We are going to pull out all associated data of the current compound
    if numel(conc_unique) == 1
        mSize = 10;
    else
        mSize = linspace(15,3,numel(conc_unique));
    end
    if dispOption == 0
        legend_str = [legend_str; cellstr(curr_condition)];
    end
    temp_center = zeros(numel(conc_unique),3); %This array will keep track of the centers for this particular compound
    %Now for the next phase we iterate through all the possible
    %concentrations. We plot markers for individual observations (if
    %desired) and record the centroid for each concentration of the given
    %compound.
    temp_plotHandles = cell(numel(conc_unique),1);
    for j = 1:numel(conc_unique)
        curr_conc = conc_unique(j);
        curr_concIdx = find(cell2mat(key_currCmpd(:,col_conc)) == curr_conc); %These are the indices that correspond to the current compound and concentration
        temp_center(j,1) = median(score_currCmpd(curr_concIdx,1));
        temp_center(j,2) = median(score_currCmpd(curr_concIdx,2));
        temp_center(j,3) = median(score_currCmpd(curr_concIdx,3));
        %We always want to plot the centroids, and don't want them labelled
        g = plot3(temp_center(j,1)',temp_center(j,2)',temp_center(j,3)','^','Color',colors(i,:),...
            'MarkerSize',mSize(j),'MarkerEdgeColor','k','MarkerFaceColor',colors(i,:),...
            'LineWidth',2);hold on;
        temp_plotHandles{j} = g;
        hAnnotation = get(g,'Annotation');
        hLegendEntry = get(hAnnotation','LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off')
        %We only sometimes want to plot the raw data
        if dispOption == 1
            legend_str = [legend_str; cellstr([curr_condition ' ' num2str(curr_conc)])];
            plot3(score_currCmpd(curr_concIdx,1),score_currCmpd(curr_concIdx,2),...
                score_currCmpd(curr_concIdx,3),'o','Color',colors(i,:),...
                'MarkerSize',mSize(j));
        end
    end
    centers{i} = temp_center; %Store the information on the centers here
    h = plot3(temp_center(:,1)',temp_center(:,2)',temp_center(:,3)','-',...
        'Color',colors(i,:),'LineWidth',3);
    plotHandles{i,1} = temp_plotHandles;
    plotHandles{i,2} = h;
    if dispOption == 1
        hAnnotation = get(h,'Annotation');
        hLegendEntry = get(hAnnotation','LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off')
    end
end

legend(legend_str,'Location','Best');
title('PCA analysis of varying doses');
xlabel('Principal component 1'); ylabel('Principal component 2');zlabel('Principal component 3');
% grid on; axis vis3d;
        
% for j = 1:size(conditions_unique,1)
%     temp = conditions_unique{j};
%     if dispOption == 1
%         legend_str = [legend_str; temp];
%     else
%         temp_cmpd = temp{1,:};
%         underscore = strfind(temp_cmpd,'_');
%         legend_str = [legend_str; temp_cmpd(1:underscore-1)];
%     end
%     if numel(temp) == 1
%         mSize = 5;
%     else
%         mSize = linspace(15,3,numel(temp));
%     end
%     centers = zeros(numel(temp),3);
%     for i = 1:numel(temp);
%         %Find all the indices of the data corresponding to each condition
%         temp_idx = strcmp(temp,key(:,col_cond));
%         if dispOption == 1
%             plot3(score(temp_idx,1),score(temp_idx,2),score(temp_idx,3),'o','Color',colors(j,:),'MarkerSize',mSize(i));
%         end;
%         %         plot3(score(temp_idx,1),score(temp_idx,2),score(temp_idx,3),'o','Color',colors(j),'MarkerSize',mSize(i));
%         centers(i,1) = median(score(temp_idx,1)); centers(i,2) = median(score(temp_idx,2));
%         centers(i,3) = median(score(temp_idx,3));
%     end
%     conditions_unique_sorted{j,3} = centers;
% end

% %Here we plot the centers of each cluster
% for i = 1:size(conditions_unique_sorted,1)
%     centers = conditions_unique_sorted{i,3};
%     numConc = size(centers,1);
%     if numConc == 1
%         mSize = 15;
%     else
%         mSize = linspace(15,3,numConc);
%     end
%     for j = 1:numConc
%         %         plot3(centers(j,1)',centers(j,2)',centers(j,3)','^','Color',colors(i),...
%         %             'MarkerSize',mSize(j),'MarkerEdgeColor','k','MarkerFaceColor',colors(i),...
%         %             'LineWidth',2);hold on;
%         g = plot3(centers(j,1)',centers(j,2)',centers(j,3)','^','Color',colors(i,:),...
%             'MarkerSize',mSize(j),'MarkerEdgeColor','k','MarkerFaceColor',colors(i,:),...
%             'LineWidth',2);hold on;
%         if j > 1
%             hAnnotation = get(g,'Annotation');
%             hLegendEntry = get(hAnnotation','LegendInformation');
%             set(hLegendEntry,'IconDisplayStyle','off')
%         end
%     end
% %     plot3(centers(:,1)',centers(:,2)',centers(:,3)','-','Color',colors(i),...
% %         'LineWidth',3);
%     h = plot3(centers(:,1)',centers(:,2)',centers(:,3)','-','Color',colors(i,:),...
%         'LineWidth',3);
%     hAnnotation = get(h,'Annotation');
%     hLegendEntry = get(hAnnotation','LegendInformation');
%     set(hLegendEntry,'IconDisplayStyle','off')
% end
