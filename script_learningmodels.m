close all
clear all

%Just testing out some different learning models here
load testing_training.mat

%Plotting some data here
halo = test_raw(1:20,:); dmso = test_raw(21:end,:);
halo = resample(halo,1,5);dmso = resample(dmso,1,5);
avg = mean(halo);std = sqrt(var(halo));
figure(); plot(1:length(halo),avg,'b-',1:length(halo),avg + std,'g-',1:length(halo),avg - std,'g-',1:length(halo),mean(dmso),'r-');
legend('Haloperidol','+std','-std','DMSO'); title('Testing set data');

%Decision tree
t = classregtree(train_set,cellstr(num2str(groups_train)));
class = eval(t,test_set); class = cellfun(@num2str,class);
acc = 1 - ((20-sum(class(1:20)) + sum(class(21:end))) / 40)

%SVM
model = svmtrain(train_set,groups_train);
class = svmclassify(model,test_set);
acc = 1 - ((20-sum(class(1:20)) + sum(class(21:end))) / 40)

