function plot_fig1()%% raw data plot for figure1

D=importdata("24_raw_bin_data/wBL819/snifferdata_271021_110539.csv");
StartRecording=1635230862921; %extracted from txt

data=D.data;


data(:,4)=-data(:,4);

respiration=data(:,[2 4]);
accelero=data(:,[6 7 8])/1024;

times_in_seconds = data(:, 1);
timesInSecondsFromSessionStart = times_in_seconds - times_in_seconds(1);
secondsInDay = 60*60*24;
timesInSerialFromSessionStart = timesInSecondsFromSessionStart / secondsInDay;

        timestamp_in_num = datenum([1970 1 1 3 0 StartRecording/1000]); %I converted it manualy to local timezone
    times_vec = timesInSerialFromSessionStart + timestamp_in_num;

range=1:360:length(times_vec);
t=datestr(times_vec(range), 'HH:MM');
% time_vec=t(noise_vec==0,:);
% X_axis_text_RESP=time_vec(1:60:end,:);
X_axis_text=t(1:60:end,:);

f= figure('Color', [1,1,1],'Position', [145         557        1686         420]); %, 
subplot(2,1,1)
plot(respiration)
xticks(1:21600:size(data,1)); %every hour: 6 event in sec*60*60
xticklabels(X_axis_text);
xlabel('Time (Hours)')
ylabel('Pressure (Pascal)')
%set(gca,'FontSize',15)

subplot(2,1,2)
plot(accelero)
xticks(1:21600:size(data,1)); %every hour: 6 event in sec*60*60
xticklabels(X_axis_text);
xlabel('Time (Hours)')
ylabel('acceleration (G)')
%set(gca,'FontSize',15)

length_to_plot=1;
start=60*360;
f= figure('Color', [1,1,1],'Position', [145         557        1686         420]); %, 
subplot(2,1,1)
d=respiration(start:start+length_to_plot*360,:);
X_axis_short_text=t(start/360:start/360+length_to_plot,:);
plot(d)
xticks(1:360:size(d,1)); %every minutes: 6 event in sec*60*60
xticklabels(X_axis_short_text);
xlabel('Time (Hours)')
ylabel('Pressure (Pascal)')
set(gca,'FontSize',15)

subplot(2,1,2)
plot(accelero(start:start+length_to_plot*360,:));
xticks(1:360:size(d,1)); %every hour: 6 event in sec*60*60
xticklabels(X_axis_short_text);
xlabel('Time (Hours)')
ylabel('acceleration (G)')
set(gca,'FontSize',15)

end