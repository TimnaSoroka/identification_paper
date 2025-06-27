function [ outputMatrix, remaining_indexes] = remove_extreme_norm_rows( inputMatrix, num_of_stds)
%FIND_NON_DISCRETE_DESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    num_of_stds = 4.5;
end

mat = inputMatrix;
mat_norm = nanZscore(log(row_norm(mat)));
max_row_norm_mask = mat_norm < num_of_stds;
min_row_norm_mask = mat_norm > -num_of_stds;

remaining_indexes = max_row_norm_mask & min_row_norm_mask;
mat = mat(remaining_indexes, :);

outputMatrix = inputMatrix(remaining_indexes, :);
end
