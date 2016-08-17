function [data_feat_norm, feat_names] = compareDrugs(drugA, drugB, drugA_name, drugB_name)
%compareDrugs(drugA, drugB, drugA_name, drugB_name).
%This function will take in two cells, one containing the NORMALIZED data
%for drug A, and the other the NORMALIZED data for drug B. It will then
%create a number of decision trees using the raw data to see if any of the
%raw data points stand out. Next it will use embedded feature selection and
%random forest in order to create a heatmap showing the most important
%features. Finally it will plot the averages of the two drugs against each
%other so the results from above can be compared.

%% Section 1: Plotting the data
numData = size(drugA,2);
figure(); plot(1:numData, mean(drugA), 'b-', 1:numData, mean(drugB), 'g-');
title(['Comparison between ' drugA_name ' and ' drugB_name]);
xlabel('Time');ylabel('Motion Index (a.u.)');
legend(drugA_name, drugB_name, 'Location','Best');
xlim([1,numData]);

%% Section 2: Creating decision trees on the raw data
drugA_short = resample(drugA',1,5)'; drugB_short = resample(drugB',1,5)';
data = [drugA_short; drugB_short];
groups = [cellstr(repmat(drugA_name,size(drugA,1),1));...
    cellstr(repmat(drugB_name,size(drugB,1),1))];

% Randomly create decision trees using a different 25/75 split each time
for i = 1:10
    shuffle = randperm(size(data,1)); cut = floor(numel(shuffle)/4); %75/25 training/testing split
    Xtest = data(shuffle(1:cut),:); Ytest = groups(shuffle(1:cut));
    Xtrain = data(shuffle(cut+1:end),:); Ytrain = groups(shuffle(cut+1:end));
    t = classregtree(Xtrain, Ytrain);
    class = eval(t,Xtest);
    acc = mean(strcmp(class,Ytest));
    ['The accuracy of decision tree is: ' num2str(acc)]
    view(t)
end
    
%% Section 3: Using embedded feature selection

%First step here is to extract features from the data to reduce the number
%of features to something more manageable

relevantIdx = [1:4500,5251:11250]; %These are the chunks of data from the new battery that correspond to the stimuli from the original, old battery
temp = [drugA; drugB]; data_short = temp(:,relevantIdx);
data_feat = zeros(size(data_short,1),660);
for i = 1:size(data_short,1)
    temp_split = splitAssays(data_short(i,:), 0);
    [data_feat(i,:), feat_names] = behaviorFeatures(temp_split);
end

feat_mean = mean(data_feat); feat_std = sqrt(var(data_feat));
feat_mean = repmat(feat_mean,size(data_feat,1),1);
feat_std = repmat(feat_std,size(data_feat,1),1);
data_feat_norm = (data_feat - feat_mean) ./ feat_std;
idx_clo = strcmp(groups,'Clozapine'); idx_thior = strcmp(groups, 'Thioridazine');
numX = size(data_feat_norm,2);
figure();plot(1:numX, mean(data_feat_norm(idx_clo,:)), 'b-', ...
    1:numX, mean(data_feat_norm(idx_thior,:)), 'g-');
title('Extracted Features'); xlabel('Feature Number');ylabel('Normalized score');
legend('Clozapine','Thioridazine');

%% Now let's do some embedded feature selection!
Xtrain = data_feat_norm(shuffle(1:cut),:); Ytrain = groups(shuffle(1:cut));
Xtest = data_feat_norm(shuffle(cut+1:end),:); Ytest = groups(shuffle(cut+1:end));
BaggedEnsemble = TreeBagger(50,Xtrain,Ytrain,'oobpred','On',...
    'Method','classification','oobvarimp','on');
class = predict(BaggedEnsemble,Xtest);
acc = mean(strcmp(class,Ytest));
['The accuracy of random forest for clozapine vs. thioridazine is: ' num2str(acc)]

%Features in order of descending importance from deltaError
deltaErr = BaggedEnsemble.OOBPermutedVarDeltaError; %This will return the increase in error when a given feature is permuted (the larger the value, the more important the predictor.
[sortedErr,sortingIdx] = sort(deltaErr,'descend');
important_err = sortedErr(1:5)
important_idx = sortingIdx(1:5)

%% Feature importance analysis, creation of heatmap
%Let's create a 1D heatmap showing which features are the most important
kernel = gausswin(5)';
err_data = zeros(size(deltaErr));
numUseful = sum(deltaErr>0); %This is the number of features which were useful
for i = 1:numUseful
    idx = sortingIdx(i); %This is the index of a useful feature
    if idx < 1 || idx > numel(err_data)
    else
        err_data(idx-2:idx+2) = err_data(idx-2:idx+2) + kernel.*sortedErr(i);
    end
end
figure();h = heatmap(err_data,1:size(deltaErr,2));

