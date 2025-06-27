clear

directory_to_use= '/Users/worg/Documents/fingerprint_code/Accelerometer';
list=dir([directory_to_use '/magnitude_*']);

block_length_in_minutes=5;

for i=1:size(list,1)
load([list(i).folder '/' list(i).name]);
k=list(i).name(11:18);

timeSeriesData=acc_magnitude;
name=k;

car=0;
for iii=1:size(timeSeriesData,1)
    car=car+1;
    keywords{iii,1}=char([k '_5min_magnitude_' num2str(car)]);
labels{iii,1}=k;
end


save([directory_to_use '/INP_' name '_5min_magnitude.mat'],'timeSeriesData','labels','keywords');
%TS_Init(['INP_' name '5min_magnitude.mat']);
clearvars labels keywords
end
