%This simple script first requires script_fullanalysis_text.m to be run in
%order to first generate the condition_idx and fish_features vector. This
%will then randomly partition out 20 of the haloperidol and 20 of the dmso
%treated fish to be used in the testing set. The rest of the data will be
%used as training data. Finally all the relevant information will be saved
%under 'testing_training.mat'

numPerCondition = 96;
testSetSize = 20; trainSetSize = numPerCondition - testSetSize;

%These are the indices in the data file that contain data on their
%respective treatments.
halo_fish_idx = condition_idx{2}; dmso_fish_idx = condition_idx{1};

test_idx_halo = randperm(numPerCondition,testSetSize); 
test_idx_dmso = randperm(numPerCondition,testSetSize); %Randomly choose 20 from each treatment as the test set
test_fish_halo = halo_fish_idx(test_idx_halo); %This is the actual rows of data that need to be partitioned out
test_fish_dmso = dmso_fish_idx(test_idx_dmso);

test_set = [fish_features(test_fish_halo,:); fish_features(test_fish_dmso,:)];
%Now let's remove the test set from the data to end with the training set
temp_train = fish_features;
temp_train([test_fish_halo test_fish_dmso],:) = [];
train_set = temp_train;

%Now let's identify the groups
groups_train = [ones(trainSetSize,1); zeros(trainSetSize,1)];
groups_test = [ones(testSetSize,1); zeros(testSetSize,1);];

%For posterity, let's also save the raw data that belongs to each set
test_raw = [NUM(test_fish_halo,:); NUM(test_fish_dmso,:)];
temp_raw = NUM;
temp_raw([test_fish_halo test_fish_dmso],:) = [];
train_raw = temp_raw;

% save('testing_training.mat','groups_test','groups_train','test_set','train_set', 'test_raw','train_raw');