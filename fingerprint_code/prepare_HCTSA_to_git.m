clear

WSA='wake';
%WSA='sleep';

directory_to_use='/Users/worg/Documents'; %/identificationPapar'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
AllSubjData=dir([directory_to_use '/identification_paper-code/subj*/' WSA '.mat']);


for i=1:size(AllSubjData,1)
    subjData=AllSubjData(i);
    name=subjData.folder(end-7:end);
 D=load([subjData.folder '/' subjData.name]);
    data=D.fieldValue;
data(:,2)=-data(:,2);

timeSeriesData=sum(data,2);

car=0;
for iii=1:size(timeSeriesData,1)
    car=car+1;
    labels{iii,1}=char([name '_5min_resp_sum_' num2str(car)]);
keywords{iii,1}=name;
end


save([directory_to_use '/Data/INP_' name '_5min_resp_sum.mat'],'timeSeriesData','labels','keywords');
%TS_Init(['INP_' name '5min_magnitude.mat']);
clearvars labels keywords
end




