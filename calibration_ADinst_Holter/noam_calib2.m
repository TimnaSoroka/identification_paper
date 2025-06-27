clear
close all
load("calibaration_10032024_Data.mat")
Data_struct(3)=[];
Data_struct(6)=[];
Data_struct(1)=[];

theshhold=540;
Fs=6;
n=size(Data_struct,2);


for ii=1:n
    Holter=Data_struct(ii).Holter;
    resampled_SenS=Data_struct(ii).resampled_SenS;

  peaks_to_fit=peaks_from_ts3_calib(Holter);
 
peaks_to_fit2=peaks_from_ts4_calib(resampled_SenS);
 % subplot(2,1,2)
 % plot(resampled_SenS)
% c=concatenated_Holter>theshhold | concatenated_Holter<-theshhold;
% concatenated_Holter_no_plato=concatenated_Holter(~c);
% concatenated_SenS_no_plato=concatenated_SenS(~c);
% 
%     concatenated_Holter=[concatenated_Holter;Holter];
% concatenated_SenS=[concatenated_SenS;resampled_SenS];
if size(peaks_to_fit,1)~=size(peaks_to_fit2,1)
B=[peaks_to_fit.PeakLocation];
A=[peaks_to_fit2.PeakLocation];
to_erase=[];
to_erase2=[];

for i=1:size(A,2)
    if ismember(A(i),B) || ismember(A(i)+1,B) || ismember(A(i)-1,B)
        continue
    else
        to_erase(end+1)=i;
    end
end
peaks_to_fit2([to_erase])=[];
for i=1:size(B,2)
    if ismember(B(i),A) || ismember(B(i)+1,A) || ismember(B(i)-1,A)
        continue
    else
to_erase2(end+1)=i;
    end
end
peaks_to_fit([to_erase2])=[];
figure
 subplot(2,1,1)
 plot(Holter)
 hold on
  plot([peaks_to_fit.PeakLocation],[peaks_to_fit.PeakValue],'ko')
   subplot(2,1,2)
 plot(resampled_SenS)
 hold on
plot([peaks_to_fit2.PeakLocation],[peaks_to_fit2.PeakValue],'ko')
   Data_struct(ii).Holter_peaks=peaks_to_fit; 
   Data_struct(ii).ADI_peaks=peaks_to_fit2; 

else

   Data_struct(ii).Holter_peaks=peaks_to_fit; 
   Data_struct(ii).ADI_peaks=peaks_to_fit2; 

end
end

for i=1:n

concatenated_Holter=[];
concatenated_SenS=[];
test=i;
train=setdiff(1:n,i);

for ii=1:length(train)
    Holter=Data_struct(train(ii)).Holter_peaks;
    resampled_SenS=Data_struct(train(ii)).ADI_peaks;
 
concatenated_Holter=[concatenated_Holter;Holter];
concatenated_SenS=[concatenated_SenS;resampled_SenS];
end

A=[concatenated_Holter.PeakValue]';
B=[concatenated_SenS.PeakValue]';
[fitresult, gof] = fit(A,B,'poly1');

Honly_inhales=concatenated_Holter([concatenated_Holter.PeakValue]>0);
Hinter=diff([Honly_inhales.StartTime]);
H_rate=1./Hinter;

ADonly_inhales=concatenated_SenS([concatenated_SenS.PeakValue]>0);
ADinter=diff([ADonly_inhales.StartTime]);
AD_rate=1./ADinter;

[fit_rate, gof_rate] = fit(H_rate',AD_rate','poly1');



%fprintf(num2str(gof.rsquare))
close all

for cc=1:3
  zelano_training=Data_struct(test).Holter_peaks;
  zelano_testing=Data_struct(test).ADI_peaks;
if cc==1
y=[zelano_training.Volume]>0;
x=[zelano_training(y).Volume];
D.Inhale_Volume_observed{i}=[zelano_testing(y).Volume];
%D.Inhale_Volume_predicted = fitresult.p1*x^3 + fitresult.p2*x^2 + fitresult.p3*x + fitresult.p4;
D.Inhale_Volume_predicted{i} = [fitresult.p1*x + fitresult.p2]; % + fitresult.p3*x + fitresult.p4;

Inhale_Volume_rmse(i)=rmse([D.Inhale_Volume_observed{i}],[D.Inhale_Volume_predicted{i}]);

In_range(i)= max([D.Inhale_Volume_observed{i}]) - min([D.Inhale_Volume_observed{i}]);
Inhale_Volume_rmspe(i) = (1.0 - (Inhale_Volume_rmse(i) / In_range(i))) * 100;

elseif cc==2
y=[zelano_training.Volume]<0;
if sum(y)<0.3*(size(zelano_training,1))
    D.Exhale_Volume_observed{i}=nan;
    D.Exhale_Volume_predicted{i}=nan;
    Exhale_Volume_rmse(i)=nan;
    Exhale_Volume_rmspe(i)=nan;
else
x=[zelano_training(y).Volume];
D.Exhale_Volume_observed{i}=[zelano_testing(y).Volume];
%D.Inhale_Volume_predicted = fitresult.p1*x^3 + fitresult.p2*x^2 + fitresult.p3*x + fitresult.p4;
D.Exhale_Volume_predicted{i} = [fitresult.p1*x + fitresult.p2]; % + fitresult.p3*x + fitresult.p4;

Exhale_Volume_rmse(i)=rmse([D.Exhale_Volume_observed{i}],[D.Exhale_Volume_predicted{i}]);

ex_range(i)= max(abs([D.Exhale_Volume_observed{i}])) - min(abs([D.Exhale_Volume_observed{i}]));
Exhale_Volume_rmspe(i) = (1.0 - (Exhale_Volume_rmse(i) / ex_range(i))) * 100;
end
elseif cc==3

y=zelano_training([zelano_training.PeakValue]>0);
x_inter=diff([y.StartTime]);
x_r=1./x_inter;

Y=zelano_testing([zelano_testing.PeakValue]>0);
X_inter=diff([Y.StartTime]);
X_r=1./X_inter;

D.Rate_observed{i}=[X_r];
D.Rate_predicted{i} = [fit_rate.p1*x_r + fit_rate.p2]; % + fitresult.p3*x + fitresult.p4;

Rate_rmse(i)=rmse([D.Rate_observed{i}],[D.Rate_predicted{i}]);

rate_range(i)= max([D.Rate_observed{i}]) - min([D.Rate_observed{i}]);
Rate_rmspe(i) = (1.0 - (Rate_rmse(i) / rate_range(i))) * 100;

end

end
end

rmse.Exhale_Volume_rmse=mean(Exhale_Volume_rmse,'omitmissing');
rmse.Rate_rmse=mean(Rate_rmse);
rmse.Inhale_Volume_rmse=mean(Inhale_Volume_rmse);

rmse.P_Exhale_Volume_rmse=mean(Exhale_Volume_rmspe,'omitmissing');
rmse.P_Rate_rmse=mean(Rate_rmspe);
rmse.P_Inhale_Volume_rmse=mean(Inhale_Volume_rmspe);

rmse.std_Exhale_Volume_rmse=std(Exhale_Volume_rmse,'omitmissing');
rmse.std_Rate_rmse=std(Rate_rmse);
rmse.std_Inhale_Volume_rmse=std(Inhale_Volume_rmse);

rmse.stdP_Exhale_Volume_rmse=std(Exhale_Volume_rmspe,'omitmissing');
rmse.stdP_Rate_rmse=std(Rate_rmspe);
rmse.stdP_Inhale_Volume_rmse=std(Inhale_Volume_rmspe);

for iii=1:3
    if iii==1
CV='Inhale_Volume';
    elseif iii==2
CV='Exhale_Volume';
    elseif iii==3
CV='Rate';
    end

    val_observed=[(CV) '_observed'];
    val_predicted=[(CV) '_predicted'];
        rmsed=[(CV) '_rmse'];
        rmse_std=['std_' (CV) '_rmse'];
rmspe=['P_' (CV) '_rmse'];
        rmspe_std=['stdP_' (CV) '_rmse'];

    % mean_observed=mean(cell2mat(D.(val_observed)),'omitmissing');
    % std_observed=std(cell2mat(D.(val_observed)),'omitmissing');

    figure
plot(abs(cell2mat(D.(val_observed))),abs(cell2mat(D.(val_predicted))),'ro')
lsline()
title(rmse.(rmsed))
xlabel(val_observed)
ylabel(val_predicted)
fprintf(['average ' val_observed ' error= ' num2str(rmse.(rmsed),3) '±'  num2str(rmse.(rmse_std),3) '\n'])
fprintf(['percentage accuracy ' val_observed ' is= ' num2str(rmse.(rmspe),3) '±'  num2str(rmse.(rmspe_std),3) '\n'])
set(gca, 'FontSize',15)
end

for i=1:n
recording_length(i)=length(Data_struct(i).Holter);
end

recording_length_in_minutes=(recording_length/Fs)/60;
fprintf(['average ' num2str(mean(recording_length_in_minutes)) ' std ' num2str(std(recording_length_in_minutes))])
