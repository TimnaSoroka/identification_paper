function [full_time_mean_wake_values]=convert_calibrated_units48(full_time_mean_wake_values)
%input is zelano table

load('/Users/worg/Documents/calibration_ADinst_Holter/calibrations_fitresults.mat')
        for row=1:size(full_time_mean_wake_values,1)
            for column=1:size(full_time_mean_wake_values,2)
converted_wake(row,column)=fitresult.p1*full_time_mean_wake_values(row,column) + fitresult.p2;
            end
        end
        full_time_mean_wake_values(:,[1 2 5 6 8 9 25 26 29 30 32 33])=converted_wake(:,[1 2 5 6 8 9 25 26 29 30 32 33]);
        end