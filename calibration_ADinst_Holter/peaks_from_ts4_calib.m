function[inhales_and_exhales_properties_passed_threshold]=peaks_from_ts4_calib(TimeSeries)
%length parameters
Fs=6;
sampleLength=1/Fs;
time_in_serial_sec_from_start=(1:length(TimeSeries))/Fs;

peaks_properties = {...
    'MinPeakDistance', 11, ...     %0.5 * whole_day_period_in_seconds, ...
    'MinPeakWidth',0.4,...
    'MinPeakProminence', 0.07};

Thresh_param.Volume= 0.01;
Thresh_param.Duration= 0.25;
Thresh_param.Prctile_Peakvalue=90; %1 percent of max
Thresh_param.PeakValue=0.01; %1 percent of max
Thresh_param.duration_of_neigbors_for_baseline_in_minutes=1;

[inhale_peaks, inhale_indices] = findpeaks(TimeSeries, peaks_properties{:});
[exhale_peaks, exhale_indices] = findpeaks(-TimeSeries, peaks_properties{:});
%exhale_peaks = -exhale_peaks;

Thresh_in=median(inhale_peaks(inhale_peaks>prctile(inhale_peaks,Thresh_param.Prctile_Peakvalue)));
Thresh_ex=median(exhale_peaks(exhale_peaks>prctile(exhale_peaks,Thresh_param.Prctile_Peakvalue)));

inhale_peaks_to_keep= inhale_peaks > Thresh_param.PeakValue*Thresh_in; %0.1
exhale_peaks_to_keep = exhale_peaks > Thresh_param.PeakValue*Thresh_ex;  %-0.1

inhale_peaks = inhale_peaks(inhale_peaks_to_keep);
inhale_indices_to_keep = inhale_indices(inhale_peaks_to_keep);
inhale_locations = time_in_serial_sec_from_start(inhale_indices_to_keep);
exhale_peaks = exhale_peaks(exhale_peaks_to_keep);
exhale_indices_to_keep = exhale_indices(exhale_peaks_to_keep);
%exhale_locations = time_in_serial_sec_from_start(exhale_indices_to_keep);

% figure
% plot(TimeSeries)
% hold on
% plot(inhale_indices_to_keep,inhale_peaks,'ko')
% plot(exhale_indices_to_keep,-exhale_peaks,'ro')

%% Find properties for each inhales and for each exhale, with corrected-times
all_relevant_locations_indices = [inhale_indices_to_keep; exhale_indices_to_keep];
duration_of_neigbors_for_baseline_in_minutes = Thresh_param.duration_of_neigbors_for_baseline_in_minutes;
if ~isempty(all_relevant_locations_indices)
 inhales_and_exhales_properties = nested_FindPeaksProperties(sampleLength, duration_of_neigbors_for_baseline_in_minutes, TimeSeries, all_relevant_locations_indices);
%inhales_and_exhales_properties = new_calculation_volume(sampleLength, duration_of_neigbors_for_baseline_in_minutes, TimeSeries, all_relevant_locations_indices);

else
    inhales_and_exhales_properties=struct('PeakLocation',[], 'PeakValue',[], 'Volume',[],'Duration',[],'StartTime',[],'Latency',[],'NumberOfPeaks',[]);
end
%% Filter short or shallow inhales and exhales
minimalLengthInSeconds = Thresh_param.Duration;
inhales_and_exhales_passed_Duration_threshold = inhales_and_exhales_properties([inhales_and_exhales_properties.Duration] >= minimalLengthInSeconds);
tmp=abs([inhales_and_exhales_passed_Duration_threshold.Volume]);
inhales_and_exhales_properties_passed_threshold = inhales_and_exhales_passed_Duration_threshold( tmp >  Thresh_param.Volume*median(tmp));

end