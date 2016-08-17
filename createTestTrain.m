function [testTrain, headers] = createTestTrain(key,key_classonly)
%[testTrain, headers] = createTestTrain(key,key_classes,data_norm)
%This function will create a cell array that stores all the relevant detail
%needed to run successful classification experiments. The data contained
%within each column of testTrain is detailed under the "headers" cell
%array.

headers = {'Full_cmpd_name' 'Cmpd' 'Cmpd_class' 'Concentration'...
    'DataIdx' 'TrainIdx' 'TestIdx'};

conditions_unique = unique(key);
[cmpd conc] = formatDrugLabels(conditions_unique);
testTrain = cell(numel(conditions_unique),7); %Column 1 = name of compound, 2 = data indices belonging to compound, 3 = training, 4 = testing
testTrain(:,1) = conditions_unique;
testTrain(:,2) = cmpd; testTrain(:,4) = conc;
for i = 1:numel(conditions_unique)
    currCondition = conditions_unique{i};
    relevantIdx = strcmp(key,currCondition);relevantIdx = find(relevantIdx == 1); 
    testTrain{i,5} = relevantIdx; %The second column contains all the data that belongs to this condition
    testTrain{i,3} = key_classonly{relevantIdx(1)};
    critSplit = round(numel(relevantIdx)*3/4);
    shuffle = randperm(numel(relevantIdx));
    trainSet = relevantIdx(shuffle(1:critSplit)); 
    testSet = relevantIdx(shuffle(critSplit+1:end));
    testTrain{i,6} = trainSet; testTrain{i,7} = testSet; %Place the testing and training indices into the cell array
end

testTrain = sortCmpdConc(testTrain);

function newArray = sortCmpdConc(array)
cmpd_list = array(:,2); conc_list = str2double(array(:,4));
unique_cmpds = unique(cmpd_list);
newArray = cell(size(array));
for i = 1:numel(unique_cmpds)
    curr_cmpd = unique_cmpds{i};
    temp_idx = strcmp(cmpd_list,curr_cmpd);
    temp = array(temp_idx,:);temp_conc = conc_list(temp_idx);
    [~,sortIdx] = sort(temp_conc);
    newArray(temp_idx,:) = temp(sortIdx,:);
end