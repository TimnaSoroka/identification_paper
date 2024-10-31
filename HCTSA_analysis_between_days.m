clear
extrapolation=true;
timings=true;

directory_to_use='/Users/worg/Documents/identificationPapar'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/

load([directory_to_use '/AllSubjData.mat'])

% choose subjects:
% '/Users/timnas/Documents/projects/ADHD/SubjectsToUse.xlsx'
subject_to_use=importdata([directory_to_use '/SubjectsToUse.xlsx']);
subject_to_use=subject_to_use.controls1st;

subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);
AllSubjData_day1=AllSubjData;

load([directory_to_use '/AllSubjData.mat'])

% choose subjects:
% '/Users/timnas/Documents/projects/ADHD/SubjectsToUse.xlsx'
subject_to_use=importdata([directory_to_use '/SubjectsToUse.xlsx']);
subject_to_use=subject_to_use.controls2nd;

subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);
AllSubjData_day2=AllSubjData;

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


% prepare_blocks_per_subject(directory_to_use,AllSubjData_day1,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
% fprintf('prepared raw data of day1 into blocks\n')
% 
% prepare_blocks_per_subject(directory_to_use,AllSubjData_day2,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
% fprintf('prepared raw data of day2 into blocks\n')
% 
% create_BM_per_sbj(directory_to_use,AllSubjData_day1,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all day1 data blocks\n')
% 
% create_BM_per_sbj(directory_to_use,AllSubjData_day2,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all day2 data blocks\n')
% 
% 
if timings
prc=1; 

for p=1:size(prc,2)
    prc_train=prc(p);

    load('/Users/worg/Documents/identificationPapar/HCTSA/MRMR_Gender.mat')
x=sqrt(prc_train*15.3*12*size(AllSubjData,2));
%x=119;
parameters=score(1:round(x));


timings=100; %[60,120,180,360,540,100]; %
start=1;
overlap=false;
cleaning=false;

run_HCTSA_between_days(parameters,AllSubjData_day1,AllSubjData_day2,directory_to_use,WSA,normalize,...
    overlap,cleaning,block_length_in_minutes,train_by_hours,prc_train,timings,start)

end
end

if extrapolation
n_to_extra=[5,15,25,35];%,0.7,0.8,0.85];
for p=1:size(n_to_extra,2)
    n=n_to_extra(p);
    prc_train=1;
    for perm=1:100
    subj_to_use=randperm(size(AllSubjData_day1,2),n);
    AllSubjData_new=AllSubjData_day1(subj_to_use);
        
    load('/Users/worg/Documents/identificationPapar/HCTSA/MRMR_Gender.mat')
x=sqrt(prc_train*15.3*12*97);
x=119;
parameters=score(1:round(x));

timings=100; %
start=1;
overlap=false;
cleaning=false;

acc_id=run_HCTSA_between_days(parameters,AllSubjData_new,AllSubjData_day2,directory_to_use,WSA,normalize,...
    overlap,cleaning,block_length_in_minutes,train_by_hours,prc_train,timings,start);

subj_list{perm,p}={AllSubjData_new.Name};
acc_id_per_extrapolation(perm,p)=mean(acc_id);
clearvars acc_id
    end
end

save([directory_to_use '/result_HCTSA_between_days/extrapolation_results.mat'],"acc_id_per_extrapolation","subj_list");
end