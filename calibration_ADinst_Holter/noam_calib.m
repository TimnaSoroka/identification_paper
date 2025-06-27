clear
close all
load("calibaration_10032024_Data.mat")

theshhold=540;
Fs=6;
n=size(Data_struct,2);

% for i=1:n
% recording_length(i)=length(Data_struct(i).Holter);
% end

%recording_length_in_minutes=(recording_length/Fs)/60;
%fprintf(['average ' num2str(mean(recording_length_in_minutes)) ' std ' num2str(std(recording_length_in_minutes))])

for i=1:n

concatenated_Holter=[];
concatenated_SenS=[];
test=i;
train=setdiff(1:n,i);

for ii=1:length(train)
    Holter=Data_struct(train(ii)).Holter;
    resampled_SenS=Data_struct(train(ii)).resampled_SenS;

  peaks_to_fit=peaks_from_ts3_calib(Holter);
 % figure
 % subplot(2,1,1)
 % plot(Holter)
peaks_to_fit2=peaks_from_ts4_calib(resampled_SenS);
 % subplot(2,1,2)
 % plot(resampled_SenS)
c=concatenated_Holter>theshhold | concatenated_Holter<-theshhold;
concatenated_Holter_no_plato=concatenated_Holter(~c);
concatenated_SenS_no_plato=concatenated_SenS(~c);

    concatenated_Holter=[concatenated_Holter;Holter];
concatenated_SenS=[concatenated_SenS;resampled_SenS];
end


[fitresult, gof] = fit(concatenated_Holter_no_plato, concatenated_SenS_no_plato,'Poly3','Normalize', 'off');
%fprintf(num2str(gof.rsquare))

H_test=Data_struct(test).Holter;
S_test=Data_struct(test).resampled_SenS;

c=H_test>theshhold | H_test<-theshhold;
H_test=H_test(~c);
S_test=S_test(~c);

peaks=peaks_from_ts3_calib(H_test);
plot(H_test)
zelano_training=calculate_z(peaks);

peaks2=peaks_from_ts3_calib(S_test);
zelano_testing=calculate_z(peaks2);

for ii=1:3

if ii==1
x=zelano_training.Inhale_Volume;
D.Inhale_Volume_observed(i)=zelano_testing.Inhale_Volume;
D.Inhale_Volume_predicted(i) = fitresult.p1*x^3 + fitresult.p2*x^2 + fitresult.p3*x + fitresult.p4;
elseif ii==2
    x=zelano_training.Exhale_Volume;
D.Exhale_Volume_observed(i)=zelano_testing.Exhale_Volume;
D.Exhale_Volume_predicted(i) = fitresult.p1*x^3 + fitresult.p2*x^2 + fitresult.p3*x + fitresult.p4;
elseif ii==3
D.Rate_predicted(i)=zelano_training.Rate;
D.Rate_observed(i)=zelano_testing.Rate;
end

end

end

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
    mean_observed=mean(abs([D.(val_observed)]),'omitmissing');
    std_observed=std(abs([D.(val_observed)]),'omitmissing');

    figure
plot(abs([D.(val_observed)]),abs([D.(val_predicted)]),'ro')
lsline()
title(rmse(abs([D.(val_observed)]),abs([D.(val_predicted)]),'omitmissing'))
xlabel(val_observed)
ylabel(val_predicted)

end
