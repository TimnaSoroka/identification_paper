 function [ mat ] = remove_outliers(mat, percentile, num_of_stds )
%REMOVEOUTLIERS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    num_of_stds = 10;
end
if nargin < 2
    percentile = 0.95;
end

minPercentile = (1-percentile) / 2;
maxPercentile = percentile + minPercentile;

minVal = quantile(mat, minPercentile);
maxVal = quantile(mat, maxPercentile);


max_criteria_mask = @(v, ii)(v > maxVal(ii) | nanZscore(v) > num_of_stds);
min_criteria_mask = @(v, ii)(v < minVal(ii) | nanZscore(v) < -num_of_stds);

max_replacements = 0;
min_replacements = 0;
for ii = 1:size(mat, 2)
    v = mat(:, ii);
    mat(max_criteria_mask(v, ii), ii) = maxVal(ii);
    mat(min_criteria_mask(v, ii), ii) = minVal(ii);
    
    max_replacements = max_replacements + sum((max_criteria_mask(v, ii)));
    min_replacements = min_replacements + sum((min_criteria_mask(v, ii)));
end

fprintf('Outliers trimming. replaced %d max, and %d min values.\n', max_replacements, min_replacements);
end

