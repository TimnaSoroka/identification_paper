
n = 15;
% Number of successes
k = 2;
%99.76
disp(k/n*100)
% Success probability
p = 1/n;

% Calculate the binomial probability
prob = nchoosek(n, k) * p^k * (1 - p)^(n - k);

% Convert the result to 100 decimal places of precision
prob_with_precision = vpa(prob,100);

scientific_format = sprintf('%.1e', prob_with_precision);

% Display the result
disp(scientific_format);