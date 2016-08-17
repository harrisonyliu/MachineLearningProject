function res = splitAssays(data, disp_option)
%This function will take in a 1x10500 time series data set from a single
%well of behavioral data. It will split this data into twelve separate
%assays and return a Mx1 cell where M is the assay

%First let's establish the bounds of each individual assay
idx1 = 1:750; idx2 = 751:1500; idx3 = 2251:3000;
idx4 = 3001:3600; idx5 = 3751:4500; idx6 = 4501:5250; idx7 = 5251:6000;
idx8 = 6001:6750; idx9 = 7501:8500; idx10 = 8601:9600; idx11 = 9751:10450;

%Now let's chop up the data in the appropriate assays!
res = cell(11,1);
for i = 1:numel(res)
    temp = eval(['data(idx' num2str(i) ');']);
    res{i} = temp;
    
    if disp_option == 1
        subplot(4,3,i);plot(temp);title(['Assay ' num2str(i)]);
        axis([1 length(temp) min(temp) max(temp)]);
    end
end