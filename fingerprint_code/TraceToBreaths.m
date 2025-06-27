function [breaths, dataTwoChannelsCleared] = TraceToBreaths(dataTwoChannels, Fs, varargin)
%TraceToBreaths Splits respiration-trace to breaths and calculate LI.
%   TraceToBreaths(dataTwoChannels, Fs) Splits respiration trace to
%   breaths, and then find the peak-value in each nostril and compared the
%   Laterlity index (LI) by comparing the peak in each nostril.
%
%   TraceToBreaths(..., 'MinBreathDuration', MIN_DURATION) controls the
%   minimal duration of inhale (in seconds) to be counted as a breath
%   (Defautl value: 0.5 second).
%
%   TraceToBreaths(..., 'MinBreathHeightComparedToMaxValue', MIN_HEIGHT)
%   controls the minimal height of the inhale (compared to maximal value in
%   the trace) to be counted as a breath (Default value: 0.05).
%
%   TraceToBreaths(..., 'MinDurationForPlateau', MIN_DURATION) controls the
%   minimal duration of plateau (98% of the maximal value in the channel,
%   in seconds) to ignore the LI of this breath in the moving-median
%   (Default value: 0.2 seconds)
%
%   TraceToBreaths(..., 'MovingMedianDuration', MOVING_MEDIAN_DURATION)
%   controls the duration used for the moving-median (in minutes) when
%   calculating LI on a given time-window (Default value: 1 minute).
%
%   2023/08/01 - Lior .G.

%% Constants
MIN_BREATH_DURATION_IN_SEC = 0.5;
MIN_BREATH_HEIGHT_COMPARED_TO_MAX_VALUE = 0.05;
MIN_DURATION_FOR_IDENTIFYING_PLATEAU = 0.2;
LI_MOVING_MEDIAN_DURATION_IN_MINUTES = 1;

%% Read input parameters
min_breath_duration = read_parameter(varargin, 'MinBreathDuration', MIN_BREATH_DURATION_IN_SEC);
min_breath_height_compared_to_max_value = read_parameter(varargin, 'MinBreathHeightComparedToMaxValue', MIN_BREATH_HEIGHT_COMPARED_TO_MAX_VALUE);
min_duration_for_identifying_plateau = read_parameter(varargin, 'MinDurationForPlateau', MIN_DURATION_FOR_IDENTIFYING_PLATEAU);
LI_moving_median_duration_in_minutes = read_parameter(varargin, 'MovingMedianDuration', LI_MOVING_MEDIAN_DURATION_IN_MINUTES);

%% Verify size - DataForUse should be nx2
if size(dataTwoChannels, 2) ~= 2 && size(dataTwoChannels, 1) == 2
    dataTwoChannels = dataTwoChannels';
end

%% Correct zeroing
diff_between_channels = dataTwoChannels(:, 2) - dataTwoChannels(:, 1);
[diff_between_channels_hist, diff_between_channels_edges] = histcounts(diff_between_channels, 10000);
[~, highest_edge_ind] = max(diff_between_channels_hist);
possible_range_for_diff_median = diff_between_channels_edges([highest_edge_ind-1, highest_edge_ind+2]);
possible_range_indices = diff_between_channels >= possible_range_for_diff_median(1) & diff_between_channels <= possible_range_for_diff_median(2);
possible_zero_offset_by_channel = mean(dataTwoChannels(possible_range_indices, :));
eccentricity_differences = abs(diff(abs(possible_zero_offset_by_channel))) / sum(abs(possible_zero_offset_by_channel));
if eccentricity_differences <= 0.25
    possible_zero_offset_by_channel = ones(size(possible_zero_offset_by_channel)) * mean(possible_zero_offset_by_channel);
end
%fprintf('Fixing data with the following values: %1.3f, %1.3f\n', possible_zero_offset_by_channel);
dataTwoChannelsCleared = dataTwoChannels - possible_zero_offset_by_channel;

%% When there is "NaN" - take the value just before (it happen in the LabChart when the measured value got above/below the maximal/minimal value
nanMeasurements = isnan(dataTwoChannelsCleared);
[nanMeasurementsIndices, nanMeasurementsChannels] = find(nanMeasurements);
for i=1:numel(nanMeasurementsIndices)
    if nanMeasurementsIndices(i) == 1 % for the first sample - take the first not-Nan value
        indexOfFirstNotNanValue = find(~isnan(dataTwoChannelsCleared(:, nanMeasurementsChannels(i))), 1);
        valueToUse = dataTwoChannelsCleared(indexOfFirstNotNanValue, nanMeasurementsChannels(i));
    else % Take the value from the sample before
        valueToUse = dataTwoChannelsCleared(nanMeasurementsIndices(i)-1, nanMeasurementsChannels(i));
    end
    dataTwoChannelsCleared(nanMeasurementsIndices(i), nanMeasurementsChannels(i)) = valueToUse;
end

%% Get single channel, to identify breaths
dataSingleChannel = sum(dataTwoChannelsCleared, 2);

%% Identify inhales
inhalesInSingleChannel = dataSingleChannel > 0;
inhalesInSingleChannelBlocks = regionprops(inhalesInSingleChannel, {'Area', 'PixelIdxList'});

%% Add volumes and peaks
peakInEachBlock = num2cell(arrayfun(@(st) max(dataSingleChannel(st.PixelIdxList)), inhalesInSingleChannelBlocks));
volumeInEachBlock = num2cell(arrayfun(@(st) sum(dataSingleChannel(st.PixelIdxList)), inhalesInSingleChannelBlocks) / Fs);
startTimeOfEachBlock = num2cell(arrayfun(@(st) st.PixelIdxList(1), inhalesInSingleChannelBlocks) / Fs);
[inhalesInSingleChannelBlocks.StartTime] = deal(startTimeOfEachBlock{:});
[inhalesInSingleChannelBlocks.Peak] = deal(peakInEachBlock{:});
[inhalesInSingleChannelBlocks.Volume] = deal(volumeInEachBlock{:});
peakTimeWithinEachBlock = arrayfun(@(st) find(dataSingleChannel(st.PixelIdxList) == st.Peak, 1), inhalesInSingleChannelBlocks) / Fs;
peakTimeInEachBlock = num2cell(peakTimeWithinEachBlock + [inhalesInSingleChannelBlocks.StartTime]');
[inhalesInSingleChannelBlocks.PeakTime] = deal(peakTimeInEachBlock{:});

%% Remove shallow or short inhales
minBreathDurationInSamples = min_breath_duration * Fs;
minBreathPeak = min_breath_height_compared_to_max_value * max([inhalesInSingleChannelBlocks.Peak]);
breaths = inhalesInSingleChannelBlocks([inhalesInSingleChannelBlocks.Area] >= minBreathDurationInSamples & [inhalesInSingleChannelBlocks.Peak] >= minBreathPeak); 

%% Get peak and volume for each nostril
peakLeftInEachBlock = num2cell(arrayfun(@(st) max(dataTwoChannelsCleared(st.PixelIdxList, 1)), breaths));
volumeLeftInEachBlock = num2cell(arrayfun(@(st) sum(dataTwoChannelsCleared(st.PixelIdxList, 1)), breaths) / Fs);
peakRightInEachBlock = num2cell(arrayfun(@(st) max(dataTwoChannelsCleared(st.PixelIdxList, 2)), breaths));
volumeRightInEachBlock = num2cell(arrayfun(@(st) sum(dataTwoChannelsCleared(st.PixelIdxList, 2)), breaths) / Fs);

[breaths.Peak_Left] = deal(peakLeftInEachBlock{:});
[breaths.Peak_Right] = deal(peakRightInEachBlock{:});
[breaths.Volume_Left] = deal(volumeLeftInEachBlock{:});
[breaths.Volume_Right] = deal(volumeRightInEachBlock{:});

%% Identify breaths with plateau
maxValueLeft = max([breaths.Peak_Left]);
maxValueRight = max([breaths.Peak_Right]);
plateauLengthInEachBlock = arrayfun(@(st) sum(dataTwoChannelsCleared(st.PixelIdxList, 1) >= 0.98*maxValueLeft | dataTwoChannelsCleared(st.PixelIdxList, 2) >= 0.98*maxValueRight), breaths) / Fs;
plateauLengthCrossedThreshold = plateauLengthInEachBlock >= min_duration_for_identifying_plateau;
plateauLengthInEachBlockCells = num2cell(plateauLengthInEachBlock);
plateauLengthCrossedThresholdCells = num2cell(plateauLengthCrossedThreshold);
[breaths.PlateauDuration] = deal(plateauLengthInEachBlockCells{:});
[breaths.PlateauTooLong] = deal(plateauLengthCrossedThresholdCells{:});

%% Get the LI for each breath
LI_by_peaks = ([breaths.Peak_Right] - [breaths.Peak_Left]) ./ ([breaths.Peak_Right] + [breaths.Peak_Left]);
LI_by_peaks_cells = num2cell(LI_by_peaks);
[breaths.LI_by_peak] = deal(LI_by_peaks_cells{:});

%% Get median of LI with the given time-window
LI_by_peaks_without_plateau = LI_by_peaks;
LI_by_peaks_without_plateau([breaths.PlateauTooLong]) = nan;
breahts_times = [breaths.StartTime];
LI_by_peaks_mov_median_relevant = nan(size(LI_by_peaks));
for i=1:numel(breahts_times)
    breahts_times_rounded_relevant = abs(breahts_times - breahts_times(i)) <= LI_moving_median_duration_in_minutes * 30;
    LI_by_peaks_mov_median_relevant(i) = nanmean(LI_by_peaks_without_plateau(breahts_times_rounded_relevant));
end

LI_by_peaks_mov_median_cells = num2cell(LI_by_peaks_mov_median_relevant);
[breaths.LI_by_peak_mov_median] = deal(LI_by_peaks_mov_median_cells{:});
end


function parameter_value = read_parameter(input_parameters, parameter_name, parameter_default_value)
current_parameter_index = find(strcmp(input_parameters, parameter_name), 1);
if isempty(current_parameter_index)
    parameter_value = parameter_default_value;
elseif current_parameter_index == numel(input_parameters)
    parameter_value = parameter_default_value;
    fprintf('Warning: The following input-parameter does not have a value: %s\n', parameter_name);
else
    parameter_value = input_parameters{current_parameter_index+1};
    if ~isnumeric(parameter_value)
        fprintf('Warning: The following input-parameter does not have a numeric value: %s\n', parameter_name);
        parameter_value = parameter_default_value;
    end
end
end