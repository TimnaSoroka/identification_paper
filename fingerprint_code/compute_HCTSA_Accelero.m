clear
list=dir('/Users/timnas/Documents/projects/fingerprint/Accelerometer/INP*');

for i= 1:size(list,1)    
load([list(i).folder '/' list(i).name]);
disp(labels{1})
% if isfile(['HCTSA_' labels{1} '_5min_magnitude.mat'])
%     continue
% end
labels_new=keywords;
keywords_new=labels;
clearvars labels keywords
labels=labels_new;
keywords=keywords_new;
save('INP_test.mat','timeSeriesData','labels','keywords');
e=size(keywords,1);
TS_Init('INP_test.mat');
 %TS_Compute(true,1:e,1:100);
 TS_Compute(true);
 load('HCTSA.mat')
save(['HCTSA_' list(i).name(5:end)],'TS_Quality','TS_DataMat','TS_CalcTime',"TimeSeries",'Operations','MasterOperations','gitInfo','fromDatabase');
delete('HCTSA.mat')
delete('INP_test.mat')
end

%62 problem
%it will be better to prepare one converged file to all subjects (unless you need manualy press each file...)
