data = csvread('/Users/bendichter/Box Sync/MachineLearningProject/Data/Haloperidol_Data/consolidated_data.csv');
[~,txt] = xlsread('/Users/bendichter/Box Sync/MachineLearningProject/Data/Haloperidol_Data/consolidated_key.xls');
DMSO = txt(2:end,3);


N = size(consolidateddata,1);
shuffle = randperm(N);
X = data(shuffle,:);
Y = DMSO(shuffle);
cut = round(N*.8);
Xtrain  = X(1:cut,:);
Xtest = X(cut+1:end,:);
Ytest = Y(cut+1:end,:);
Ytrain = Y(1:cut,:);
Ypred = classify(Xtest,Xtrain,Ytrain,'diaglinear');
accuracy = mean(strcmp(Ypred,Ytest))

Yresub = classify(Xtrain,Xtrain,Ytrain,'diaglinear');
resub_accuracy = mean(strcmp(Yresub,Ytrain))