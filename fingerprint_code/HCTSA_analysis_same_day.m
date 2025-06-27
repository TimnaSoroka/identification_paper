clear
extrapolation=false;
timings=true;


directory_to_use='/Users/worg/Documents/identificationPapar'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/

load([directory_to_use '/AllSubjData.mat'])

% choose subjects:
% '/Users/timnas/Documents/projects/ADHD/SubjectsToUse.xlsx'
subject_to_use=importdata([directory_to_use '/SubjectsToUse.xlsx']);
subject_to_use=subject_to_use.all_subj;

subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);

%% choose parameters
WSA='wake';
%WSA='sleep';
normalize=false;
SeparateNost=false;
block_length_in_minutes=5;
sliding_window_in_minutes=1;
train_by_hours=false;
prc_train=1;
UseSelfReportedTimings=false;

 % prepare_blocks_per_subject(directory_to_use,AllSubjData,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
% fprintf('prepared all raw data into blocks\n')

% create_BM_per_sbj(directory_to_use,AllSubjData,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all data blocks\n')
% 

if timings
prc=0.85;
for p=1:size(prc,2)
    prc_train=prc(p);
%timings=[60,120,180,360,100]; %
timings=[60,120,180,300,100];%540,100]; %
timings=100;
start=1;
overlap=false;
cleaning=false;

list=dir('/Users/worg/Documents/github_repo/HCTSA/HCTSA_NDFS_.mat');
load([list(1).folder '/' list(1).name]);

% load('/Users/worg/Documents/identificationPapar/code/SPEC_2h.mat')
% load('/Users/worg/Documents/identificationPapar/HCTSA/idle_active_mrmr2.mat')
idx=Result.Ranking;
%YY=ans;
param=YY(idx);
 % if strcmpi('sleep',WSA)
%         x=sqrt(prc_train*7.84*12*97);
% else
%     x=sqrt(prc_train*15.3*12*97);
% end

x=119;
parameters=param(1:round(x));
%parameters=Result(1:round(x));


run_HCTSA_per_sbj_minimum(parameters,AllSubjData,directory_to_use,WSA,normalize,...
    overlap,cleaning,block_length_in_minutes,train_by_hours,prc_train,timings,start)
end
end

if extrapolation
n_to_extra=[40,60,80];%,0.7,0.8,0.85];
prc_train=0.8;
timings=100; %
start=1;
overlap=false;
cleaning=false;

%load('/Users/worg/Documents/github_repo/Results_CFS_.mat')
 load('/Users/worg/Documents/identificationPapar/HCTSA/MRMR_Gender.mat')
x=sqrt(prc_train*15.3*12*97);
x=119;
parameters=score(1:round(x));
%parameters=Result(1:round(x));


for p=1:size(n_to_extra,2)
    n=n_to_extra(p);
    subj_to_use=[];
    for perm=1:100
    subj_to_use(perm,:)=randperm(size(AllSubjData,2),n);
    end

        for perm=1:100
    AllSubjData_new=AllSubjData(subj_to_use(perm,:));

acc_id=run_HCTSA_per_sbj_minimum(parameters,AllSubjData_new,directory_to_use,WSA,normalize,...
    overlap,cleaning,block_length_in_minutes,train_by_hours,prc_train,timings,start);

subj_list{perm,p}={AllSubjData_new.Name};
acc_id_per_extrapolation(perm,p)=mean(acc_id);
clearvars acc_id 
    end
end

if cleaning
        t.clean='clean';
else
    t.clean='no_clean';
end

if overlap
        t.overlap='overlap';
else
    t.overlap='no_overlap';
end


save([directory_to_use '/result_HCTSA_same_day/extrapolation_results_' t.clean '_' t.overlap '_' num2str(round(x)) 'parameters.mat'],"acc_id_per_extrapolation","subj_list");
end