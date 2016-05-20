function [normalized_data] = normalizeFishData(input,dmso_idx,resample_rate)
%This function expects a MxN array of data. M fish and N raw motion index
%values (e.g. the timecourse of a fish's movement. This function will then
%normalize the timecourse data using the fish treated with DMSO (positive
%controls, these fish are untreated with drugs). It will first find the
%median of the data and subtract it from all the data (this removes any
%offset in the data). It will then find the standard deviation of the first 750
%timepoints (no stimulus is presented during that time, this is the
%baseline activity of the fish), and normalize all the data by the baseline
%activity. This will control for fish spawns that tend to be more/less
%active than others.

ctrl_data = input(dmso_idx,:);
offset = median(median(ctrl_data)); %There are multiple dmso controls, first average them together to get an averaged timecourse, then find the median of that timecourse to find the offset

baseline_data = input(dmso_idx,1:750/resample_rate); %The first 750 timepoints have no stimuli, this represent the baseline activity of the fish
scaling = sqrt(var(mean(baseline_data))); %This will rescale the data to control for fish spawns that are more/less active than normal
% scaling = mean(mean(baseline_data));

normalized_data = (input - offset) ./ scaling;

% normalized_data = (input - offset);% ./ scaling;