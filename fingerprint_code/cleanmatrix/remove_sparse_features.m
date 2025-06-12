function [ outputMatrix, remaining_indexes] = remove_sparse_features(inputMatrix, th)
%FIND_NON_DISCRETE_DESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        th = 0.95;
    end
    if isfloat(th)
        th = th;
    elseif isinteger(th)
        th = th / size(inputMatrix, 1);
    else
        error('th must be float or integer number')
    end
    
    not_nan_columns = mean(isfinite(inputMatrix));
    remaining_indexes = not_nan_columns > th;
    
    outputMatrix = inputMatrix(:, remaining_indexes);
end

