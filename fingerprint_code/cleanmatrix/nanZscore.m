function  [data, mean_vals, std_vals] = nanZscore( data, nan_replace )
%NANZSCORE Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    nan_replace = false;
end

if nan_replace
    data_median_vals = nanmedian(data);
    for col = 1:size(data, 2)
        x = isnan(data(:, col));
        data(x, col) = data_median_vals(col);
    end
end

s = size(data, 2);
for ii = 1:s
    mean_vals(ii) = nanmean(data(:, ii));
    std_vals(ii) = nanstd(data(:, ii));
    if nanstd(data(:, ii)) == 0
        data(:, ii) = zeros(size(data, 1), 1);
    else
        data(:, ii) = (data(:, ii)-mean_vals(ii)) / std_vals(ii);
    end
end

end

