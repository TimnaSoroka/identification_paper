function inhales_and_exhales_properties = nested_FindPeaksProperties_TS(sampleLength, duration_of_neigbors_for_baseline_in_minutes, respirationData, peaksLocations)
%% Split respiration-data to connected-components, and calculate for each one the duration and the volume
    % respirationData=respirationData*0.001438 + 0.004754;

thresholdForVolume = 0;
resamplingTimes = 4;
respirationDataInterpolated = interp(respirationData, resamplingTimes);
respirationDataInterpolatedAfterThreshold = respirationDataInterpolated;
respirationDataInterpolatedAfterThreshold(abs(respirationDataInterpolated) < thresholdForVolume) = 0;
respirationDataInterpolatedAfterThresholdPositive = respirationDataInterpolatedAfterThreshold > 0; 
respirationDataInterpolatedAfterThresholdNegative = respirationDataInterpolatedAfterThreshold < 0;

connectedCompPositive = bwconncomp(respirationDataInterpolatedAfterThresholdPositive);
connectedCompNegative = bwconncomp(respirationDataInterpolatedAfterThresholdNegative);
connectedCompPositiveProps = regionprops(connectedCompPositive, respirationDataInterpolatedAfterThreshold, {'Area', 'MeanIntensity', 'PixelIdxList'});
connectedCompNegativeProps = regionprops(connectedCompNegative, respirationDataInterpolatedAfterThreshold, {'Area', 'MeanIntensity', 'PixelIdxList'});
connectedCompProps = [connectedCompPositiveProps; connectedCompNegativeProps];

pixelsIndices = {connectedCompProps.PixelIdxList};
pixelsIndicesUpSamples = cellfun(@(indices) (indices-1)/resamplingTimes + 1, pixelsIndices, 'UniformOutput', false);

%% Map connected-component to peaks from input
pixelsIndicesUpSamplesRelevant = cellfun(@(indices) indices(mod(indices, 1) == 0), pixelsIndicesUpSamples, 'UniformOutput', false);
pixelsIndicesUpSamplesIndices = arrayfun(@(ind) ind*ones(size(pixelsIndicesUpSamplesRelevant{ind})), 1:numel(pixelsIndicesUpSamplesRelevant), 'UniformOutput', false);
pixelsIndicesUpsamplesTable = cat(2, cat(1, pixelsIndicesUpSamplesRelevant{:}), cat(1, pixelsIndicesUpSamplesIndices{:}));
[~, connectedCompIndexWithPeak, peaksIndicesWithConnectedComp] = intersect(pixelsIndicesUpsamplesTable(:,1), peaksLocations);
% matchedConnectedCompTable = arrayfun(@(ind) pixelsIndicesUpsamplesTable(pixelsIndicesUpsamplesTable(:,1) == ind, 2), indicesBothLists, 'UniformOutput', false);
pixelsIndicesUpsamplesTableRelevant = pixelsIndicesUpsamplesTable(connectedCompIndexWithPeak, :);
connectedComponentsIndicesRelevant = pixelsIndicesUpsamplesTableRelevant(:, 2);
connectedCompWithMatchedPeakUniqueIndices = unique(connectedComponentsIndicesRelevant);
matchedPeaksIndices = arrayfun(@(ind) peaksIndicesWithConnectedComp(connectedComponentsIndicesRelevant == ind), connectedCompWithMatchedPeakUniqueIndices, 'UniformOutput', false);
matchedPeaksIndicesRespirationData = cellfun(@(indices) respirationData(peaksLocations(indices)), matchedPeaksIndices, 'UniformOutput', false);
numOfPeaksInEachConnectedComp = cellfun(@(data) numel(data), matchedPeaksIndicesRespirationData);
absRespirationDataInEachConnectedComp = cellfun(@(data) abs(data), matchedPeaksIndicesRespirationData, 'UniformOutput', false);
peakToUseInEachConnectedComp = cellfun(@(abs_data) find(abs_data == max(abs_data), 1), absRespirationDataInEachConnectedComp);
matchedPeaksIndicesToUse = arrayfun(@(connectedCompIndex) matchedPeaksIndices{connectedCompIndex}(peakToUseInEachConnectedComp(connectedCompIndex)), 1:numel(matchedPeaksIndices));
matchedConnectedComponents = connectedCompProps(connectedCompWithMatchedPeakUniqueIndices);

%% Get peaks values
matchedPeaksLocations = peaksLocations(matchedPeaksIndicesToUse);
peaksValues = respirationData(matchedPeaksLocations);

matchedPeaksLocationsInSeconds = (matchedPeaksLocations-1) * sampleLength;

%% Find crossing-thresholdForVolume points (for each connected component) using linear interpolation
matchedConnectedComponentsIndices = {matchedConnectedComponents.PixelIdxList};
matchedConnectedComponentsStartIndices = cellfun(@(indices) indices(1), matchedConnectedComponentsIndices);
matchedConnectedComponentsStartIndices_Start = max(1, matchedConnectedComponentsStartIndices-1);
dataAtStartIndices = respirationDataInterpolated(matchedConnectedComponentsStartIndices)';
thresholdWithSignOnStartIndices = sign(dataAtStartIndices) * thresholdForVolume;
dataAtStartIndicesReferencedToThreshold = dataAtStartIndices - thresholdWithSignOnStartIndices;
dataAtOneSampleBeforeStartIndicesReferencedToThreshold = respirationDataInterpolated(matchedConnectedComponentsStartIndices_Start)' - thresholdWithSignOnStartIndices;
crossingZeroBeforeStartIndices = (matchedConnectedComponentsStartIndices_Start.*dataAtStartIndicesReferencedToThreshold - matchedConnectedComponentsStartIndices.*dataAtOneSampleBeforeStartIndicesReferencedToThreshold)./(dataAtStartIndicesReferencedToThreshold-dataAtOneSampleBeforeStartIndicesReferencedToThreshold);

matchedConnectedComponentsEndIndices = cellfun(@(indices) indices(end), matchedConnectedComponentsIndices);
matchedConnectedComponentsEndIndices_Next = min(matchedConnectedComponentsEndIndices+1, numel(respirationDataInterpolated));
dataAtEndIndices = respirationDataInterpolated(matchedConnectedComponentsEndIndices)';
thresholdWithSignOnEndIndices = sign(dataAtEndIndices) * thresholdForVolume;
dataAtEndIndicesReferencedToThreshold = dataAtEndIndices - thresholdWithSignOnEndIndices;
dataAtOneSampleAfterEndIndicesReferencedToThreshold = respirationDataInterpolated(matchedConnectedComponentsEndIndices_Next)' - thresholdWithSignOnEndIndices;
crossingZeroAfterEndIndices = ((matchedConnectedComponentsEndIndices_Next).*dataAtEndIndicesReferencedToThreshold - matchedConnectedComponentsEndIndices.*dataAtOneSampleAfterEndIndicesReferencedToThreshold)./(dataAtEndIndicesReferencedToThreshold-dataAtOneSampleAfterEndIndicesReferencedToThreshold);


%% Get connected components values
durations = (crossingZeroAfterEndIndices - crossingZeroBeforeStartIndices) / resamplingTimes * sampleLength;
volumes = arrayfun(@(ind) trapz([crossingZeroBeforeStartIndices(ind); matchedConnectedComponentsIndices{ind}; crossingZeroAfterEndIndices(ind)], ...
    [0; respirationDataInterpolatedAfterThreshold(matchedConnectedComponentsIndices{ind}); 0]), 1:numel(durations)) / resamplingTimes * sampleLength;
startTimesUpsampled = (crossingZeroBeforeStartIndices(:)-1)/resamplingTimes + 1;
startTimesUpsampledInSeconds = (startTimesUpsampled - 1) * sampleLength;
% EndTimeUpSampled= (crossingZeroAfterEndIndices(:)-1)/resamplingTimes + 1;
% EndTimesUpsampledInSeconds = (EndTimeUpSampled - 1) * sampleLength;
% 
latencies = matchedPeaksLocationsInSeconds - startTimesUpsampledInSeconds;


%% Summarize all the data
properties_table = array2table([matchedPeaksLocations(:), peaksValues(:), volumes(:), durations(:), startTimesUpsampledInSeconds(:), latencies(:), numOfPeaksInEachConnectedComp(:)], ...
    'VariableNames', {'PeakLocation', 'PeakValue', 'Volume', 'Duration', 'StartTime', 'Latency', 'NumberOfPeaks'});
inhales_and_exhales_properties = table2struct(properties_table);

% %% Add comparing to neighbor
% durations_of_neigbors_for_baseline_in_minutes = [0.5, 1, 2, 5];
% current_peaks_locations = cell(1, numel(durations_of_neigbors_for_baseline_in_minutes));
% for duration_of_neigbors_for_baseline_in_minutes_index = 1:numel(durations_of_neigbors_for_baseline_in_minutes)
%     duration_of_neigbors_for_baseline_in_minutes = durations_of_neigbors_for_baseline_in_minutes(duration_of_neigbors_for_baseline_in_minutes_index);
%     duration_of_neigbors_for_baseline_in_seconds = duration_of_neigbors_for_baseline_in_minutes * 60;
%     for is_inhale = 0:1 % 0:1
%         if is_inhale
%             relevant_indices =  [inhales_and_exhales_properties.PeakValue] > 0;
%         else
%             relevant_indices = [inhales_and_exhales_properties.PeakValue] < 0;
%         end
%         relevant_properties = inhales_and_exhales_properties(relevant_indices);
%         relevant_start_times = startTimesUpsampledInSeconds(relevant_indices);
%         [start_times_sorted, relevant_start_times_order] = sort(relevant_start_times);
%         relevant_properties_sorted = relevant_properties(relevant_start_times_order);
%         durations_sorted = [relevant_properties.Duration];
%         end_times_sorted = start_times_sorted + durations_sorted(:);
%         
%         time_for_baseline_start = start_times_sorted - duration_of_neigbors_for_baseline_in_seconds;
%         time_for_baseline_end = end_times_sorted + duration_of_neigbors_for_baseline_in_seconds;
%         neighbors_for_each_peak = arrayfun(@(ind) relevant_properties_sorted(end_times_sorted > time_for_baseline_start(ind) & start_times_sorted < time_for_baseline_end(ind) & time_for_baseline_start ~= time_for_baseline_start(ind)), ...
%             1:numel(time_for_baseline_start), 'UniformOutput', false);
%         
%         neighbors_avg_cells = cellfun(@(neighbors) AveragePeaksProperties(neighbors), neighbors_for_each_peak, 'UniformOutput', false);
%         neighbors_avg = [neighbors_avg_cells{:}];
%         
%         normalized_to_neighbors_avg_cells = arrayfun(@(ind) NormalizePeakProperties(relevant_properties_sorted(ind), neighbors_avg(ind)), ...
%             1:numel(neighbors_avg), 'UniformOutput', false);
%         normalized_to_neighbors_avg = [normalized_to_neighbors_avg_cells{:}];
%         
%          fieldsToNormalize = {'PeakValue', 'Volume', 'Duration', 'Latency'};
%         f = figure;
%         for i=1:numel(fieldsToNormalize)
%             fieldName = fieldsToNormalize{i};
%             subplot(2,2,i);
%             [~, h1, h2] = plotyy(relevant_start_times_order, [relevant_properties_sorted.(fieldName)], ...
%                 relevant_start_times_order, [normalized_to_neighbors_avg.([fieldName '_Normalized'])]);
%             h1.LineStyle = 'none';
%             h1.Marker = 'x';
%             h2.LineStyle = 'none';
%             h2.Marker = 'o';
%             title(fieldName);
%         end
%         f.Name = ['Is inhale = ' num2str(is_inhale) ' - Baseline=' num2str(duration_of_neigbors_for_baseline_in_minutes) ' minute(s)'];
%         f_children = f.Children;
%         f_axes = f_children(strcmp({f_children.Type}, 'axes'));
%         linkaxes(f_axes, 'x');
%         xlim(f_axes, [1, max(relevant_start_times_order)]);
        %close(f);
        %%
%         f = PlotDurationAndVolume(normalized_to_neighbors_avg, ...
%             sampleLength, duration_of_neigbors_for_baseline_in_minutes, ...
%             respirationData, relevant_properties_sorted);
%         current_peaks_locations{duration_of_neigbors_for_baseline_in_minutes_index} = sort(...
%             [normalized_to_neighbors_avg([normalized_to_neighbors_avg.Duration_Normalized] > 3 & [normalized_to_neighbors_avg.Volume_Normalized] > 3).StartTime]);
%         close(f);
%     end
% end

%%
% figure;
% colors = {'rx', 'go', 'k^', 'mv'};
% legends_strings = cell(size(current_peaks_locations));
% for i=1:numel(current_peaks_locations)
%     values = current_peaks_locations{i};
%     plot(values, ones(size(values)) + i/20, colors{i});
%     hold on;
%     legends_strings{i} = ['Baseline = ' num2str(durations_of_neigbors_for_baseline_in_minutes(i))];
% end
% ylim([0, 2]);
% legend(legends_strings{:});
    
end