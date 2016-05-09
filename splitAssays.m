function res = splitAssays(data, disp_option)
%This function will take in a 1x10500 time series data set from a single
%well of behavioral data. It will split this data into twelve separate
%assays and return a Mx1 cell where M is the assay

%First let's establish the bounds of each individual assay
idx1 = 1:750; idx2 = 751:1500; idx3 = 1501:2250; idx4 = 2251:3000;
idx5 = 3001:3600; idx6 = 3751:4500; idx7 = 4501:5250; idx8 = 5251:6000;
idx9 = 6001:6750; idx10 = 7501:8500; idx11 = 8601:9600; idx12 = 9751:10450;

%Now let's chop up the data in the appropriate assays!
res = cell(12,1);
for i = 1:numel(res)
    temp = eval(['data(idx' num2str(i) ');']);
    res{i} = temp;
    
    if disp_option == 1
        subplot(4,3,i);plot(temp);title(['Assay ' num2str(i)]);
        axis([1 length(temp) min(temp) max(temp)]);
    end
end