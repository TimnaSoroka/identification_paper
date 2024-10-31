clear
extrapolation=false;
timings=true;
rand=0;

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

 %  prepare_blocks_per_subject(directory_to_use,AllSubjData,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
 % fprintf('prepared all raw data into blocks\n')
 % 
% create_BM_per_sbj(directory_to_use,AllSubjData,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all data blocks\n')
% 

if timings
prc=0.65;%,0.7,0.8,0.85];
for p=1:size(prc,2)
    prc_train=prc(p);
timings=[60;120;180;360;540];
%timings=[60;120;180;300;100];
timings=100; 

start=1;
overlap=false;
cleaning=true;

if rand
    nn=50;
else
    nn=1;
end

for i=1:nn
run_BM_per_sbj_minimum_sleepwake(AllSubjData,directory_to_use,WSA,normalize,...
    overlap,1,block_length_in_minutes,train_by_hours,prc_train,timings,start,rand)
end
end
end

if extrapolation
n_to_extra=[20,40,60,80];%,0.7,0.8,0.85];
for p=1:size(n_to_extra,2)
    n=n_to_extra(p);
    prc_train=0.65;
    for perm=1:100
            subj_to_use=randperm(size(AllSubjData,2),n);
    AllSubjData_new=AllSubjData(subj_to_use);
timings=100; %
start=1;
overlap=false;
cleaning=true;

acc_id=run_BM_per_sbj_minimum(AllSubjData_new,directory_to_use,WSA,normalize,...
    overlap,cleaning,block_length_in_minutes,train_by_hours,prc_train,timings,start,rand);

subj_list{perm,p}={AllSubjData_new.Name};
acc_id_per_extrapolation(perm,p)=mean(acc_id);
clearvars acc_id
    end
end

save([directory_to_use '/result_BM_same_day/extrapolation_results_' WSA '.mat'],"acc_id_per_extrapolation","subj_list",'WSA');
end