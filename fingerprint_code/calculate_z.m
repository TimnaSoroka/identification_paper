function [z]= calculate_z(peaks,block_length)

only_inhales=peaks([peaks.PeakValue]>0);
only_exhales=peaks([peaks.PeakValue]<0);

z.Inhale_Volume=mean([only_inhales.Volume]);
z.Exhale_Volume=mean([only_exhales.Volume]);
z.Inhale_Duration=mean([only_inhales.Duration]);
z.Exhale_Duration=mean([only_exhales.Duration]);
z.Inhale_value=mean([only_inhales.PeakValue]);
z.Exhale_value=mean([only_exhales.PeakValue]);

z.Inter_breath_interval=mean(diff([only_inhales.StartTime]));
z.Rate=1./[z.Inter_breath_interval];
z.Tidal_volume=[z.Inhale_Volume]+[z.Exhale_Volume];
z.Minute_Ventilation=[z.Rate].*[z.Tidal_volume];

z.Duty_Cycle_inhale=mean([only_inhales.Duration]./[z.Inter_breath_interval]);
z.Duty_Cycle_exhale=mean([only_exhales.Duration]./[z.Inter_breath_interval]);

z.COV_InhaleDutyCycle=std([only_inhales.Duration])./mean([only_inhales.Duration]);
z.COV_ExhaleDutyCycle=std([only_exhales.Duration])./mean([only_exhales.Duration]);

z.COV_BreathingRate=std(diff([only_inhales.StartTime]))./[z.Inter_breath_interval];

z.COV_InhaleVolume=std([only_inhales.Volume])./[z.Inhale_Volume];
z.COV_ExhaleVolume=std([only_exhales.Volume])./[z.Exhale_Volume];

offsets=[peaks.StartTime]+[peaks.Duration];
[~,idx_s]=sort([peaks.StartTime]);
in=[peaks.PeakValue]>0;
InEx_s=in(idx_s);
offsets_sorted=offsets(idx_s);
onsets=[peaks.StartTime];
onsets_sorted=onsets(idx_s);

inhale_pause=[];
exhale_pause=[];

for i=1:length(offsets)-1
pause=onsets_sorted(i+1)-offsets_sorted(i);
if InEx_s(i)==1 && InEx_s(i+1)==0 && pause>=0.05 
    inhale_pause(end+1)=pause;
elseif InEx_s(i)==0 && InEx_s(i+1)==1 && pause>=0.05 
   exhale_pause(end+1)=pause;
end
end

z.Inhale_Pause_Duration=mean(inhale_pause);
z.Exhale_Pause_Duration=mean(exhale_pause);
z.COV_InhalePauseDutyCycle=std(inhale_pause)./mean(inhale_pause);
z.COV_ExhalePauseDutyCycle=std(exhale_pause)./mean(exhale_pause);
z.Duty_Cycle_InhalePause=mean(inhale_pause./[z.Inter_breath_interval]);
z.Duty_Cycle_ExhalePause=mean(exhale_pause./[z.Inter_breath_interval]);

z.PercentBreathsWithExhalePause=length(exhale_pause)*100./(size(peaks,1)-size(only_inhales,1));
z.PercentBreathsWithInhalePause=length(inhale_pause)*100./size(only_inhales,1);

%     'Percent of Breaths With Inhale Pause'
end