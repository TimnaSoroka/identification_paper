function [ data, data_replaced_vals ] = replace_nans( data, func_num, silent_mode )
%REPLACENANS This function replace nans in a matrix 
% It removes nan columns and fills in data according to 1 out of 4 functions 
% 1 - median
% 2 - mean
% 3 - zeros
% 4 - min
if nargin < 3
    silent_mode = false;
end
if nargin < 2
    func_num = 1;
end
if func_num == 1    
    data_replaced_vals = nanmedian(data);
elseif func_num == 2
    data_replaced_vals = nanmean(data);
elseif func_num == 3
    data_replaced_vals = zeros(1, size(data, 2));
elseif func_num == 4
    data_replaced_vals = nanmin(data);
end

[data, nans_replaced_mat] = fillmissing(data, 'constant', data_replaced_vals);

if ~silent_mode
    nans_replaced = sum(nans_replaced_mat(:));
    disp(['Total nans replaced: ', num2str(nans_replaced), ' Avg. Per Col: ', ...
        num2str(nans_replaced / size(data, 2))]);
end
end

