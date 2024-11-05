close all
% rng('default')
%  directory_to_use='/Users/worg/Documents/identificationPapar'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% % directory_to_use='/Users/worg/Documents/lior_data/Timna'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% % load([directory_to_use '/QA_updated4.mat'])
% load([directory_to_use '/demographic/QA_updated.mat'])
% load([ directory_to_use '/vars.mat']);
% 
% QA=AllSubjData(1:97);

AQ_wake_table=traits_analysis_csv(directory_to_use,QA,'wake',8,0);

[adjusted_p_values,sig_vars]=benjamini_hochberg_correction([AQ_wake_table.p_val]);
disp(var_names(sig_vars))

AQ_sleep_table=traits_analysis_csv(directory_to_use,QA,'sleep',8,0);

[adjusted_p_values,sig_vars]=benjamini_hochberg_correction([AQ_sleep_table.p_val]);
disp(var_names(sig_vars))


 
function [adjusted_p_values,sig_vars]=benjamini_hochberg_correction(p)
[v,idx]=sort(p);
    adjusted_p_values=v*length(p);
    m=length(v);
    % Benjamini-Hochberg critical values (q-values)
    q_values = (1:m) * 0.05 / m;
    for i = 1:m
        adjusted_p_values(i) = min(v(i) * m / i, 1);
    end

    q=adjusted_p_values<0.05;
   sig_vars=idx(q);
end

