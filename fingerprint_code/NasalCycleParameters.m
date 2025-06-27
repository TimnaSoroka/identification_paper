function[measureResults, winStats, pace_LI_corr,Resp]=NasalCycleParameters(DataToUse,Fs,noiseThreshold)

Data=DataToUse;
        [Resp,~]=hilbert24(Data, Fs, noiseThreshold);

% one number variables
Laterality_Index=(Resp(1,:)-Resp(2,:))./(Resp(1,:)+Resp(2,:));
measureResults.MeanLateralityIndex = mean(Laterality_Index);
measureResults.stdLateralityIndex = std(Laterality_Index);
measureResults.stdAmplitudeLI = std(abs(Laterality_Index));
measureResults.MeanAmplitudeLI = mean(abs(Laterality_Index));
[NostrilCorrR, NostrilCorrP] = corrcoef(Resp(1,:), Resp(2,:));
measureResults.Nostril_Corr_RValue = NostrilCorrR(2,1);
measureResults.Nostril_Corr_PValue = NostrilCorrP(2,1);


% 1HourInterval
numOfSleepHours = floor(length(Resp)/60);
M_LI_1hourInt = zeros(1, numOfSleepHours);
V_LI_1hourInt = zeros(1, numOfSleepHours);
CorrR_1hourInt = zeros(1, numOfSleepHours);
CorrP_1hourInt = zeros(1, numOfSleepHours);
for i=1:length(Resp)/60
    interval=(i-1)*60+1:(i)*60;
    local_LI=Laterality_Index(interval);
    M_LI_1hourInt(i)= mean(local_LI);
    V_LI_1hourInt(i)= mean(abs(local_LI));
    [R_1hourInt, P_1hourInt]=corrcoef(Resp(1,interval),Resp(2,interval));
    CorrR_1hourInt(i)=R_1hourInt(1,2);
    CorrP_1hourInt(i)=P_1hourInt(1,2);
end

winStats.M_LI_1hourInt = M_LI_1hourInt;
winStats.V_LI_1hourInt = V_LI_1hourInt;
winStats.CorrR_1hourInt = CorrR_1hourInt;
winStats.CorrP_1hourInt = CorrP_1hourInt;

% [NostrilCorrWakeR, NostrilCorrWakeP]=corrcoef(Resp_wake(1,:), Resp_wake(2,:));
% measureResults.Nostril_corr_Wake = NostrilCorrWakeR(2,1);
% measureResults.Nostril_corr_Wake_p = NostrilCorrWakeP(2,1);

%pace-LI 24 hours
Mpace=mean(Resp(4:5,:));
% if Start_sleep>Wake_up
%     sleep_int = [1:Wake_up Start_sleep:length(Resp)];
% else
%     sleep_int = Start_sleep:Wake_up;
% end
% 
% Mpace_sleep=mean(Mpace(sleep_int));
% tmp=Mpace;
% tmp(sleep_int)=[];
% Mpace_wake=mean(tmp);
% 
% pace_LI_corr.Mpace_sleep = Mpace_sleep;
% pace_LI_corr.Mpace_wake = Mpace_wake;

prc10=prctile(Mpace,10);
prc90=prctile(Mpace,90);
%prc5=prctile(Mpace,5);
%prc95=prctile(Mpace,95);
pace_L=Laterality_Index(Mpace<prc10);
pace_H=Laterality_Index(Mpace>prc90);

pace_LI_corr.pace_L = pace_L;
pace_LI_corr.pace_H = pace_H;

% %pace-LI wake
% 
% Mpace_wake=mean(Resp_wake(4:5,:));
% 
% prc10_wake=prctile(Mpace_wake,10);
% prc90_wake=prctile(Mpace_wake,90);
% %prc5_wake=prctile(Mpace_wake,5);
% %prc95_wake=prctile(Mpace_wake,95);
% pace_L_wake=LI_wake(Mpace_wake<prc10_wake);
% pace_H_wake=LI_wake(Mpace_wake>prc90_wake);
% 
% pace_LI_corr.pace_L_wake = pace_L_wake;
% pace_LI_corr.pace_H_wake = pace_H_wake;
% 
% %pace-LI sleep
% 
% Mpace_sleep=mean(Resp(4:5,:));
% 
% prc10_sleep=prctile(Mpace_sleep,10);
% prc90_sleep=prctile(Mpace_sleep,90);
% %prc5_sleep=prctile(Mpace_sleep,5);
% %prc95_sleep=prctile(Mpace_sleep,95);
% pace_L_sleep=LI(Mpace_sleep<prc10_sleep);
% pace_H_sleep=LI(Mpace_sleep>prc90_sleep);
% 
% pace_LI_corr.pace_L_sleep = pace_L_sleep;
% pace_LI_corr.pace_H_sleep = pace_H_sleep;

% Code added by Lior G.
% if toDisplayAreaByLIThreshold
%     ShowGraphForAreaByLIThreshold(LI_wake, LI);
% end

% save data to AllSubjData struct
% updatedSubjData.RawDataFilePath = subjData.RawDataFilePath;
% updatedSubjData.StartHour = subjData.RecordingStart;
% if isfield(subjData, 'SleepTime') && isfield(subjData, 'WakeUpTime')
%     updatedSubjData.SleepTime = subjData.SleepTime;
%     updatedSubjData.WakeUpTime = subjData.WakeUpTime;
% else
%     updatedSubjData.SleepTime = subjData.SleepTimeStart;
%     updatedSubjData.WakeUpTime = subjData.WakeTime;
% end
% if ~isempty(subjData.StartNap)
% updatedSubjData.NapStart=subjData.StartNap;
% updatedSubjData.NapEnd=subjData.EndNap;
% updatedSubjData.NapStart_Index_RawData=nap_start;
% updatedSubjData.NapEnd_Index_RawData=nap_end;
% end
% 
% updatedSubjData.Sleep_Index_RawData = night;
% updatedSubjData.Sleep_Index_SmoothedData = Start_sleep;
% updatedSubjData.WakeUp_Index_RawData = morning;
% updatedSubjData.WakeUp_Index_SmoothedData = Wake_up;
% updatedSubjData.hilbert_data = Resp(:, :);
% responseSmooothingWindow=10;
% clear SResp
% 
% SResp(1,:)=filtfilt(ones(1,responseSmooothingWindow)*1/responseSmooothingWindow,1,Resp(1,:));
% SResp(2,:)=filtfilt(ones(1,responseSmooothingWindow)*1/responseSmooothingWindow,1,Resp(2,:));
% % SResp(1,:)=smooth(Resp(1,:),responseSmooothingWindow);
% % SResp(2,:)=smooth(Resp(2,:),responseSmooothingWindow);
% 
% updatedSubjData.hilbert_smoothed_data = SResp;
% updatedSubjData.Gender = subjData.Gender;
% updatedSubjData.Group = subjData.group;
% updatedSubjData.Name = subjData.Name;
% updatedSubjData.Condition = subjData.ritalin;

end