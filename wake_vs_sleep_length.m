% clear
% close all
% rng('default')
% directory_to_use='/Users/worg/Documents/identificationPapar'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% load([directory_to_use '/demographic/QA_updated.mat'])
% QA=AllSubjData(1:97);
% print_results=0;
% start=3;
% 
% values=readDATAsleepwake_timings(QA,start);

load("values_capped.mat")
acc_wake=ac;
load("acc_sleep.mat")
acc_sleep=ac;
b=0;
a=0;

% a = number of samples where model 1 was correct and model 2 was incorrect
% b = number of samples where model 1 was incorrect and model 2 was correct

for i=1:size(ac,1)
    if acc_sleep(i)==1 & acc_wake(i)==0
        b=b+1;
    elseif acc_sleep(i)==0 & acc_wake(i)==1
        a=a+1;
    end
end


% Calculate McNemar's statistic
chi_square_statistic = (b - a)^2 / (b + a);

% Calculate the p-value
p_value = 1 - chi2cdf(chi_square_statistic, 1);

% Display results
fprintf('McNemars Chi-square statistic: %.4f\n', chi_square_statistic);
fprintf('p-value: %.4f\n', p_value);

