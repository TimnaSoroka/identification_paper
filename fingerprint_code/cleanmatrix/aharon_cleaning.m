function [mat6,rows_idxs,rows_idxs2] = aharon_cleaning(mat)

SPARSE_ROWS_THRESHOLD = 0.5;
SPARSE_FEATURES_THRESHOLD = 0.9;
EXTREME_MOLECULES_REMOVAL = 5;
NAN_REPLACEMENT_LOGIC = 3; %median replacement, use 3 for zeros
OUTLIERS_PERCENTILE = 0.99;
OUTLIERS_STDS = 10;

mat1 = mat(:, var(mat,'omitnan')>0);
%fprintf('Removing constant columns matrix size: (%d, %d)\n', size(mat1))

[mat2, rows_idxs] = remove_sparse_rows(mat1, SPARSE_ROWS_THRESHOLD);
%fprintf('Removing sparse rows: (%d, %d)\n', size(mat2))

% [mat3, desc_idx] = remove_sparse_features(mat2, SPARSE_FEATURES_THRESHOLD);
% fprintf('Removing sparse features: (%d, %d)\n', size(mat3))

mat4 = replace_nans(mat2, 1); 
%fprintf('After replacing nans: (%d, %d)\n', size(mat4))

[mat5, rows_idxs2] = remove_extreme_norm_rows(mat4, EXTREME_MOLECULES_REMOVAL);
%fprintf('Cleaning rows with extreme norms: (%d, %d)\n', size(mat5))%


mat6 = remove_outliers(mat5, OUTLIERS_PERCENTILE, OUTLIERS_STDS);
%fprintf('Remove outliers: (%d, %d)\n', size(mat6))

end