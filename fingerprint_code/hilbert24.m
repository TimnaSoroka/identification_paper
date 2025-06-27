function [Resp,noise_vec] = hilbert24(Data, Fs, noiseThreshold)

% this function takes the raw-data and returns it with
% one-sample-per-minute. The raw data should be sampled in given Fs.

% Updated by Maya - 15/11
% Updated by Lavi & Roni - 12/8
% Updated by Roni 10/3/14
% Updated by Lior - 17/01/17


bandPassFreqs = [0.5 5];
Fs = round(Fs, 6); % round for the 6-digits
% 
% 
% 
% %% Initial filter
inputDataLength = size(Data,1);
myWindow = zeros(inputDataLength,1);
max_freq = Fs/2;
df = Fs/inputDataLength;
center_freq = mean(bandPassFreqs);
filter_width = diff(bandPassFreqs);
x = 0:df:max_freq;
gauss = exp(-0.5*(x-center_freq).^2);
cnt_gauss = round(center_freq/df);
flat_padd = round(filter_width/df);  % flat padding at the max value of the gaussian
padd_left = floor(flat_padd/2);
padd_right = ceil(flat_padd/2);
aux = [gauss((padd_left+1):cnt_gauss) ones(1,flat_padd) gauss((cnt_gauss+1):(end-padd_right))];
myWindow(1:length(aux)) = power(aux,5);
myWindowMat = repmat(myWindow,1,size(Data,2));
fftRawEeg = fft(Data);
filtSignal = ifft(fftRawEeg.*myWindowMat,'symmetric');

Data = filtSignal;

%% First - remove mean for every 10 minutes (or whole block if it's less than 10 minutes) and compute hilbert transform

L = length(Data);
T_mean = floor(10*60*Fs); % check mean every 10 minutes
if T_mean > L
    T_mean = L;
end
K = floor(L/T_mean);

% Initially we subtracted mean for battery voltage change and apparently
% this is not needed so we omitted that filter.

Data_wo_mean = cell(2, 1);
hilbertOutput = cell(2, 1);
for j = 1:2
    for i = 1:K
        temp_vec = Data((i-1)*T_mean+1:i*T_mean,j) - mean(Data((i-1)*T_mean+1:i*T_mean,j));
        Data_wo_mean{j} = [Data_wo_mean{j} temp_vec'];
    end
    
    data_after_hilbert = hilbert(Data_wo_mean{j});
    hilbertOutput{j} = abs(data_after_hilbert);
    
end

%% Second - get the peaks of the hilbert transform

% Notice I don't allow a peak to be close more than 1.8 seconds to the next
% one to exclude the un-wanted jumps in values. I think this value can be
% set for every "breather" based on minimal breathing tempo (here we can go
% up to 15).
pks = cell(2, 1);
locs = cell(2, 1);
minPeakDistanceInSeconds = 1.8;
minPeakDistanceValue = minPeakDistanceInSeconds*Fs; 
for j = 1:2
    [pks{j},locs{j}] = findpeaks(hilbertOutput{j},'MinPeakDistance', minPeakDistanceValue);
end

%% Third - average the peaks for 1 minutes -can play with reasonable time-frame

L = length(Data);
bin = 1; % bin size in min to average peaks in
minimal_peaks_per_minute = 12; % at least 5 Hz
frame_length = bin*60; % (sec) check mean every "bin" minutes
minimal_peaks_per_frame = minimal_peaks_per_minute * bin;
T_mean = floor(frame_length*Fs);
K = floor(L/T_mean);

val_per_frame = cell(2, 1);
Resp_freq = cell(2, 1);

for j = 1:2
    val_per_frame{j} = nan(1, K);
    Resp_freq{j} = nan(1, K);
    for i = 1:K
        indices_peaks = find(locs{j} > (i-1)*T_mean & locs{j} < i*T_mean);
        if isempty(indices_peaks)
            temp_val = 0;
            no_of_pks = 0;
        else
            temp_val = mean(pks{j}(indices_peaks));
            if temp_val>noiseThreshold
                no_of_pks = length(indices_peaks);
            else
                if j == 1
                    tmp_j = 2;
                else
                    tmp_j = 1;
                end
                indices_peaks = find(locs{tmp_j} > (i-1)*T_mean & locs{tmp_j} < i*T_mean);
                no_of_pks = length(indices_peaks);
            end
        end
        val_per_frame{j}(i) = temp_val;
        Resp_freq{j}(i) = no_of_pks;
    end
end

NewLocs = T_mean/2:T_mean:K*T_mean-T_mean/2;

vpr1 = val_per_frame{1};
vpr2 = val_per_frame{2};

noise1 = vpr1<noiseThreshold | isnan(vpr1);
noise2 = vpr2<noiseThreshold | isnan(vpr2);
noise_by_peak = noise1&noise2;
noise_by_count = max(cat(1, Resp_freq{:})) < minimal_peaks_per_frame;

noise_vec= noise_by_peak| noise_by_count;

Resp = [vpr1; vpr2; NewLocs; Resp_freq{1}; Resp_freq{2}];

Resp(:,noise_by_peak | noise_by_count) = [];
end