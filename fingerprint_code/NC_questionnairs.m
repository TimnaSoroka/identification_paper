clear
%close all
rng('default')
directory_to_use='/Volumes/Mac/Restored MacBook Pro/identification_paper/'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% directory_to_use='/Users/worg/Documents/lior_data/Timna'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% load([directory_to_use '/QA_updated4.mat'])
load([directory_to_use '/demographic/QA_updated.mat'])
%load('/Users/worg/Documents/fingerprint/not_relevant/NC_97.mat')

load([ directory_to_use '/vars.mat']);
zscored=0;
WSA='wake';
%WSA='sleep';

QA=AllSubjData(1:97);
print_results=0;

for f=[4:8,13]%[3,13,6:8]
    ff=fieldnames(QA);
    fieldname=ff{f};

    labels=[QA.(fieldname)];
    names={QA.Code};

    % labels(isnan(labels))=[];
   % [labels_sorted,idx_sorted]=sort(labels);
    % q1=idx_sorted(1:10);
    % q3=idx_sorted(end-9:end);
    %
    q1=labels<=prctile(labels,15);
    q3=labels>=prctile(labels,85);


    [NC_wake,NC_sleep]=val_to_use(NC_results);

     values1=NC_wake;
     values2=NC_sleep;


    values1_L=values1(q1,:);
    values1_H=values1(q3,:);


    values2_L=values2(q1,:);
    values2_H=values2(q3,:);

    % ttest2(values1_L,values1_H)
    [~,p] = ttest2(values2_L,values2_H)
    for i=1:size(values2_H,2)
        p(i)= ranksum(values2_L(:,i),values2_H(:,i));
    end
    disp(p)
    disp('night')
    disp(fieldname)

    [~,p] = ttest2(values1_L,values1_H)
    for i=1:size(values1_H,2)
        p(i)= ranksum(values1_L(:,i),values1_H(:,i));
    end
    disp(p)
    disp('wake')
    disp(fieldname)

   NC= [NC_wake,NC_sleep];

    for rr=1:8
[Corr(rr),CorrP(rr)]=corr(NC(:,rr),labels',"rows","complete","type","Spearman");
disp(find(CorrP<0.05));
    end
% [adjusted_p,sig_vars]=benjamini_hochberg_correction(CorrP);
% disp(adjusted_p)
end

function [NC_wake,NC_sleep]=val_to_use(trainingmat)
a=[trainingmat.Mean_amplitude_LI_sleep]';
b=[trainingmat.Mean_amplitude_LI_wake]';
c=[trainingmat.MeanAmplitudeLI]';
d=[trainingmat.Mean_LI_sleep]';
e=[trainingmat.Mean_LI_wake]';
f=[trainingmat.MeanLateralityIndex]';
g=[trainingmat.Nostril_corr_Sleep]';
h=[trainingmat.Nostril_corr_Wake]';
i=[trainingmat.Nostril_Corr_RValue]';
j=[trainingmat.Average_Interval_length_during_sleep]';
k=[trainingmat.Average_Interval_length_during_wake]';
l=[trainingmat.Average_Interval_length]';

NC_wake=[b,e,h,k];
NC_sleep=[a,d,g,j];
end