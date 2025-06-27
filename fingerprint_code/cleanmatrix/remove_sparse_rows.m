function [ outputMatrix, remaining_indexes] = remove_sparse_rows( inputMatrix, th, must_have)
%FIND_NON_DISCRETE_DESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 1
        error('matrix is required.');
    end
    if nargin < 2
        th = 0.9;
    end
    if nargin < 3
        must_have = false(size(inputMatrix, 1), 1);
    end
    
    if isfloat(th)
        th = th;
    elseif isinteger(th)
        th = th / size(inputMatrix, 1);
    else
        error('th must be float or integer number')
    end
    
    not_nan_rows = mean(isfinite(inputMatrix), 2);
    remaining_indexes = not_nan_rows > th | must_have;
    
    outputMatrix = inputMatrix(remaining_indexes, :);
end
