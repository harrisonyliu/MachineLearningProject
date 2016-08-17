function [res, feat_names] = behaviorFeatures(data)
%This will take in a Mx1 cell where each row represents data from a
%different assay from a zebrafish. This function will then take the data,
%resample by 1/5 and 1/25 then extract: 1. Avg (1/5 resample) 2. variance (1/5
%resample) 3. AUC (1/5 resample) 4. AUC (1/25 resample). It will then find
%all the pairwise relationships (mult, abs diff, divide) between the
%features within the same assay. Then it will find all the pairwise
%relationships between all corresponding features *between* assays. The
%resulting full feature array will then be returned in res.

feat_names = [];

%Here are some parameters that we will use to name the feature
assay_str = {'1','2','3','4','5','6','7','8','9','10','11','12'};
feat_str = {'Avg','Var','AUC5','AUC25'};
op_str = {'*','-','/'};
% test = [feat_str{1} '_' assay_str{3} op_str{3} feat_str{3} '_' assay_str{11}] %An example: Average of assay 3 divided by AUC (1/5 resample) of assay 11

feat_orig = zeros(numel(data),4);
names_orig = cell(size(feat_orig));
for i = 1:numel(data)
    temp = data{i,:};
    temp_resample5 = resample(temp,1,5);
    temp_resample25 = resample(temp,1,25);
%     figure();hold on; plot(temp,'b-');
%     plot(6:5:length(temp),temp_resample5(2:end),'r-');
%     plot(26:25:length(temp),temp_resample25(2:end),'g-');
%     legend('orig','resample5','resample25'); title(['Assay ' num2str(i)]);
    avg = mean(temp_resample5); variance = var(temp_resample5);
    AUC5 = trapz(temp_resample5); AUC25 = trapz(temp_resample25);
    feat_orig(i,:) = [avg variance AUC5 AUC25];
    assay = num2str(i);
    names_orig(i,:) = {['Avg_' assay],['Var_' assay],['AUC5_' assay],['AUC25_' assay]};
end

%First pass combinations (within feature combinations)
feat_expand = feat_orig; names_expand = names_orig;
combos_first = combntns(1:4,2);
for i = 1:size(combos_first,1)
    idx1 = combos_first(i,1); idx2 = combos_first(i,2);
    temp_divide = feat_orig(:,idx1) ./ feat_orig(:,idx2);
    %Here we continue building names
    names_divide = cell(size(temp_divide));
    for j = 1:size(feat_orig,1)
        names_divide{j} = [names_orig{j,idx1} '/' names_orig{j,idx2}];
    end
    %And now we append to keep adding to our features
    feat_expand = [feat_expand temp_divide];
    names_expand = [names_expand names_divide];
end

%Now let's find all the possible interactions between different assays
feat_final = reshape(feat_expand',1,numel(feat_expand));
names_final = reshape(names_expand',1,numel(names_expand));
%Second combos as interassay combinations
combos_second = combntns(1:11,2);
for i = 1:size(combos_second,1)
    idx1 = combos_second(i,1); idx2 = combos_second(i,2);
    temp_divide = feat_expand(idx1,:) ./ feat_expand(idx2,:);
    names_divide = cell(size(temp_divide));
    for j = 1:size(names_expand,2)
        names_divide{j} = ['(' names_expand{idx1,j} ')/(' names_expand{idx2,j} ')'];
    end
    feat_final = [feat_final temp_divide];
    names_final = [names_final names_divide];
end

res = feat_final;feat_names = names_final;