function [timings_per_subj]=Sleep_Wake_timings(subjData,sbj,accdata,UseSelfReportedTimings,Fs)

if ~exist('UseSelfReportedTimings','var')
UseSelfReportedTimings=false;
end

if isempty(sbj)
UseSelfReportedTimings=1;
else
acc_timing=accdata(sbj,:);  
end

if UseSelfReportedTimings
    [night, morning,NapStartIndex, NapEndIndex] = SelfReportedTimings(subjData.StartHour, subjData.SleepTime, subjData.WakeUpTime, subjData.NapStart, subjData.NapEnd,Fs);
    
    timings_per_subj.NapStart=NapStartIndex;
    timings_per_subj.NapEnd=NapEndIndex;
    timings_per_subj.Start_sleep=night;
    timings_per_subj.Wake_up=morning;
else
    timings_per_subj.NapStart=acc_timing.start_nap;
    timings_per_subj.NapEnd=acc_timing.end_nap;
    timings_per_subj.Start_sleep=acc_timing.night;
    timings_per_subj.Wake_up=acc_timing.morning;
end

if isempty(timings_per_subj.NapStart)
    timings_per_subj.NapStart=nan;
    timings_per_subj.NapEnd=nan;
end

end

function [night, morning,NapStartIndex, NapEndIndex] = SelfReportedTimings(StartHour, SleepTime, WakeUpTime,NapStart, NapEnd,Fs)

    morning=ConvertTimeIntoIndex(StartHour,WakeUpTime,Fs);
    night=ConvertTimeIntoIndex(StartHour, SleepTime,Fs);
    if ~isnan(NapStart)
    NapStartIndex=ConvertTimeIntoIndex(StartHour, NapStart,Fs);
    else
        NapStartIndex=nan;
    end

    if ~isnan(NapEnd)
    NapStartIndex=ConvertTimeIntoIndex(StartHour, NapEnd,Fs);
    else
        NapEndIndex=nan;
    end
end