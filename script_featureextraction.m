close all
clear all

filename_data = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\Data','2016-01-27-p0003-S01-01-DHI-1837-MI.csv');
filename_key = fullfile('C:\Users\harri_000\Documents\Zebrafish Project\Zebrafish-behavior\Data','2016-01-27-p0003-S01-01-DHI-1837-key_1.csv');

[NUM,TXT,RAW] = xlsread(filename_data);
[unique_conditions, condition_idx, condition_cell] = parseKey(filename_key);
    
%We have a number of treatment conditions with replicates, we need to
%average the data across replicates. The first step is to mark down the
%conditions and the fish (rows of data) that serve as a replicate for that
%treatment.
range.posctrl = 1:12;
range.DHI200 = 85:96;

%Now let's create a matrix in which we can store all that (averaged) data
% condition_names = fieldnames(range);
% num_conditions = numel(condition_names);
condition_names = unique_conditions;
num_conditions = numel(condition_names);
data_avg = zeros(num_conditions,size(NUM,2));
data_std = data_avg;

% Now for each condition lets average all the data and assign it
for i = 1:num_conditions
    data_raw = NUM(condition_idx{i},:);
    data_avg(i,:) = mean(data_raw);
    data_std(i,:) = std(data_raw);
end

%Now let's normalize all the data
datanorm = zeros(size(data_avg));
for i = 1:num_conditions
    temp = data_avg(i,:);
    data_norm(i,:) = (temp - min(temp)) ./ std(temp);
end

%Now let's plot the data!
timepoints = 1:size(data_norm,2);
colors = 'bgrcmykw'; coloridx = 1;
figure();hold on;
for i = 1:num_conditions
    plot(timepoints,data_norm(i,:),[colors(i) '--']);
end
title('Data Plot'); ylabel('Motion Index (Normalized)');xlabel('Time');legend(condition_names);
axis([1 timepoints(end) min(min(data_norm)) max(max(data_norm))]);

%% Some frequency analysis
%Here let's see the frequency content of our data

%First let's load the signal
signal = data_avg(end,:);
signal_res = resample(signal, 1, 5);
signal_res20 = resample(signal, 1, 50);
figure();hold on; plot(signal,'b-'); plot(1:5:length(signal),signal_res,'r-');
plot(1:50:length(signal),signal_res20,'g-');
legend('orig','resampled','extra resampled');
axis([1 length(signal) min(signal) max(signal)]);

%Now let's establish some sampling guidelines
Fs = 25;                    % Sampling frequency
T = 1/Fs;                   % Sampling period
L = length(signal_res);     % Length of signal
t = (0:L-1)*T;              % Time vector

%Now let's do some Fourier analysis
Y = fft(signal_res);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f,P1,'r-')
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')


%% Filtering the data over different time lengths
windowsize = [10 50 100];
window_data = cell(num_conditions,numel(windowsize));

%This will store the data in an MxN matrix. M is the number of conditions
%(each row is a different condition) and N is the data when averaged over
%different window sizes
for i = 1:num_conditions
    for j = 1:numel(windowsize)
        temp = data_norm(i,:);
        for k = 1:numel(windowsize)
            temp_window = reshape(temp,windowsize(j),numel(temp)/windowsize(j));
            window_data{i,j} = mean(temp_window);
        end
    end
end

%Let's plot all the different data at the different time scales
figure(); hold on; suptitle('Windowing Comparison');
for i = 1:size(window_data,2)
    num_datapt = size(window_data{1,i},2);
    xdata = 1+windowsize(i)/2:windowsize(i):num_datapt*windowsize(i);
    for j = 1:num_conditions
        ydata = window_data{j,i};
        xmin = 1; xmax = xdata(end); ymin = min(ydata); ymax = max(ydata);
        %         plot(xdata,ydata,[colors(i) '-']);
        subplot(3,1,i);plot(xdata,ydata,[colors(j) '-']);hold on;
        legend(condition_names);ylabel('Normalized MI');
    end
    title(['Window size = ' num2str(windowsize(i))]); axis([xmin xmax ymin ymax]);
end

%% Now let's make some combinations of values

%For each condition and each window size, find all possible pairwise
%combinations of datapoints. We will later use this data to find all the
%possible sums, multiplications, ratios etc. between different timepoints
window_data_paired = cell(num_conditions,numel(windowsize));
for i = 1:num_conditions
    for j = 1:numel(windowsize)
        temp = window_data{i,j};
        window_data_paired{i,j} = combntns(temp,2);
    end
end

%% Creation of the feature vector
%To sum up: so far for each condition we have taken the data and averaged
%together every 10, 50, 100 data points (window size) to obtain some
%simplified data. Next we have taken that data and found every possible
%pairwise combination. To construct the final feature vector we will
%concatenate together the raw data points, as well as the absolute difference,
%multiplication, and division of all the possible pairwise combinations.

%First let's start a big vector that captures all the data
featvect = cell(num_conditions,1);
for i = 1:num_conditions
    temp = [];
    for j = 1:numel(windowsize)
        temp = [temp window_data{i,j}];
    end
    featvect{i,1} = temp;
end

%Next, create the pairwise difference, mult, and division
%between the different windowed datapoints
absdif = cell(size(window_data)); mult = absdif; div = absdif;
for i = 1:num_conditions
    for j = 1:numel(windowsize)
        temp_1 = window_data_paired{i,j}(:,1);
        temp_2 = window_data_paired{i,j}(:,2);
        absdif{i,j} = (abs(temp_1 - temp_2))';
        mult{i,j} = (temp_1 .* temp_2)';
        div{i,j} = (temp_1 ./ temp_2)';
    end
    temp_absdif = cell2mat(absdif(i,:));
    temp_mult = cell2mat(mult(i,:));
    temp_div = cell2mat(div(i,:));
    featvect{i,1} = [featvect{i,1} temp_absdif temp_mult temp_div];
end

