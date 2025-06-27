clear
close all

addpath '/Users/worg/Documents/identificationPapar/demographic'

directory_to_use='/Users/worg/Documents/identificationPapar/'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
load([directory_to_use 'predict_AQ_BECK_TA/QA_updated5.mat'])
%load([directory_to_use '/demographic/QA_updated.mat'])

QA=AllSubjData(1:97);
clearvars p p_edge
timings=1200;
start=1;

clearvars AllSubjData

    fingerprint1=readDATA48_timings1(QA,'Code',timings,start);
    %fingerprint1=fingerprint1(:,1:24);
 

   zScores = zscore(fingerprint1);  % standardize each column (variable)
outliers = abs(zScores) > 3;  % flag anything >3 SDs from mean

dataWinsorized = fingerprint1;
dataWinsorized(outliers) = sign(zScores(outliers)) * 3;

    TA=[QA.TA];
    AQ=[QA.AQ];
    beck=[QA.beck];


    fingerprint2=[beck;TA;AQ]; %;log(beck+1)
fingerprint2=fingerprint2';
   dataWinsorized(sum(isnan(fingerprint2),2)>0,:)=[];
   fingerprint2(sum(isnan(fingerprint2),2)>0,:)=[];

   % validrows= sum(isnan(fingerprint3),2) & all(~isnan(fingerprint2),2);
   % fin2_clean=fingerprint2(validrows,:);
   % fin1_clean=fingerprint3(validrows,:);

   [A,B,r,U,V,stats]=canoncorr(dataWinsorized,fingerprint2);
disp(stats)
%    % Top breathing features for canonical variate 1
% [~, idx] = sort(abs(A(:,1)), 'descend');
% topBreathingFeatures = idx(1:5);  % Top 5 breathing features
% 
% % Top behavioral traits for canonical variate 1
% [~, idx] = sort(abs(B(:,1)), 'descend');
% topBehaviorTraits = idx(1:2);  % All 3, in your case

figure
scatter(U(:,1), V(:,1),100,'filled');
xlabel('Canonical variate from breathing','FontSize',12);
ylabel('Canonical variate from behavior','FontSize',12);
title(sprintf('Canonical correlation = %.2f', r(1)));
lsline()



%%
for i = 1:size(fingerprint2,2)
    r_trait = corr(U(:,1), fingerprint2(:,i), 'rows','complete','type','Spearman');
    fprintf('Correlation between U1 and Trait %d: r = %.2f\n', i, r_trait);
end


% Example data
U1 = U(:,1);  % First canonical variate
traits = fingerprint2;  % 3 behavioral traits
traitNames = {'beck','TA', 'AQ'};

figure;
for i = 1:3
    subplot(1,3,i);
    scatter(U1, traits(:,i), 'filled');
    [rho(i),prho(i)] = corr(U1, traits(:,i), 'Type', 'Spearman', 'Rows', 'complete');
    
    lsline;  % adds least-squares fit line (optional, for trend visualization)
    xlabel('U_1 (Canonical Score)');
    ylabel(traitNames{i});
    title(sprintf('%s\n\\rho = %.2f p = %.3e', traitNames{i}, rho(i),prho(i)));
    fprintf('%s\n\\rho = %.2f p = %.3e', traitNames{i}, rho(i),prho(i));

        if i == 3 | i == 1
        ylim([0, max(traits(:,i)) * 1.1]);  % Extend a bit above max for spacing
    end
end

sgtitle('Spearman Correlation Between U_1 and Behavioral Traits');

%%
% % z_corrs = atanh(rho); % Fisher's z-transform
% % 
% % % --- Simple one-way ANOVA on the transformed correlations ---
% % 
% % % You have 3 z-values, corresponding to each behavioral parameter.
% % % Since these are within-subject (same U1 compared to each behavior), 
% % % technically a repeated-measures ANOVA would be ideal.
% % 
% % % But for simplicity (and because sample size usually isn't huge), we can 
% % % treat it as a normal one-way ANOVA across the three behaviors.
% % 
% % [p_anova, tbl, stats_anova] = anova1(z_corrs, [], 'off');
% % 
% % fprintf('\nANOVA p-value comparing behavioral contributions: p = %.3f\n', p_anova);
