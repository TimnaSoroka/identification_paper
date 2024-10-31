%% calculate mean BM values

clear

%% this code should run after

% parameters:
WSA='wake';
block_length=5;
cleaning=false;
overlap=false;
normalize=false;
directory_to_use='/Users/worg/Documents/identificationPapar';
timings=100;
start=1;

%% choose subjects:
load([ directory_to_use '/AllSubjData.mat']);

subject_to_use=importdata([ directory_to_use '/SubjectsToUse.xlsx']);
subject_to_use=subject_to_use.all_subj;

subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);

% %%
% prepare_blocks_per_subject(directory_to_use,AllSubjData,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
% fprintf('prepared all raw data into blocks\n')
%
% create_BM_per_sbj(directory_to_use,AllSubjData,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all data blocks\n')
%

%%
mean_values=calculate_mean_BM_values(AllSubjData,directory_to_use,block_length,WSA,timings,start,normalize,overlap,cleaning);

  if cleaning
            mean_values_array=table2array(mean_values);
            m=mean(mean_values_array,'omitmissing');
            s=std(mean_values_array,'omitmissing');
 mean_values_array(mean_values_array>2.5*s+m | mean_values_array<m-2.5*s)=nan;
m_mean_values=array2table(mean(mean_values_array,'omitmissing'),'VariableNames',var_names);
  else
m_mean_values=mean(mean_values);
  end

%   for i=1:size(m_mean_values,2)
%     x=m_mean_values.(i);
%    y1(i)=-8.261e-08*x^2+0.001446*x+0.01459;
%    y2(i)=0.001449*x+0.01147;
%    y3(i)=-1.251e-09*x^3 + -1.528e-07*x^2 + 0.00158*x + 0.01677;
% end

    x=m_mean_values.Tidal_volume; i=1;
   y1(i)=-8.261e-08*x^2+0.001446*x+0.01459;
   y2(i)=0.001449*x+0.01147;
   y3(i)=-1.251e-09*x^3 + -1.528e-07*x^2 + 0.00158*x + 0.01677;

     % Coefficients (with 95% confidence bounds):
     %   p1 =  -1.251e-09  (-1.327e-09, -1.174e-09)
     %   p2 =  -1.528e-07  (-1.744e-07, -1.312e-07)
     %   p3 =     0.00158  (0.00157, 0.00159)
     %   p4 =     0.01677  (0.0154, 0.01813)