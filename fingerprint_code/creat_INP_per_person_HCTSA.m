clear

list=dir('/Users/worg/Documents/Data/sum_5min_blocks_per_subj/*/*raw_*');

for i=1:size(list,1)
load([list(i).folder '/' list(i).name]);


timeSeriesData=raw_in_block_sum;
name=labels{1};

car=0;
for iii=1:size(timeSeriesData,2)
    car=car+1;
    keywords{iii,1}=char([name '_5min_resp_sum_' num2str(car)]);
end

labels=labels';

save(['/Users/worg/Documents/Data/INP_' name '_5min_resp_sum.mat'],'timeSeriesData','labels','keywords');
%TS_Init(['INP_' name '5min_magnitude.mat']);
clearvars labels keywords
end
