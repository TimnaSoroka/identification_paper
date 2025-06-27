directory='/Users/worg/Documents/fingerprint/not_relevant/';

load([directory 'beck_wake_table_supp_prc_1585_final.mat']);
[SuppTable_Beck_Wake]=prepare_tables_nc(TableToCSV,'Wake','Beck');
load([directory 'beck_sleep_table_supp_prc_1585_final.mat']);
[SuppTable_Beck_Sleep]=prepare_tables_nc(TableToCSV,'Sleep','Beck');
load([directory 'TA_wake_table_supp_prc_1585_final.mat']);
[SuppTable_TA_Wake]=prepare_tables_nc(TableToCSV,'Wake','TA');
load([directory 'TA_sleep_table_supp_prc_1585_final.mat']);
[SuppTable_TA_Sleep]=prepare_tables_nc(TableToCSV,'Sleep','TA');
load([directory 'AQ_wake_table_supp_prc_1585_final.mat']);
[SuppTable_AQ_Wake]=prepare_tables_nc(TableToCSV,'Wake','AQ');
load([directory 'AQ_sleep_table_supp_prc_1585_final.mat']);
[SuppTable_AQ_Sleep]=prepare_tables_nc(TableToCSV,'Sleep','AQ');



[SuppTable_Beck_Wake,SuppTable_Beck_Sleep,...
    SuppTable_TA_Wake,SuppTable_TA_Sleep,...
    SuppTable_AQ_Wake,SuppTable_AQ_Sleep];



function [SuppTable]=prepare_tables_nc(TableToCSV,state,fieldname)
param=[6:8,10];
var_names={'mean_LI','mean_LI_Power','cycle_periodicity','Nostril_Corr'};
for i=1:size(param,2)
    param_Data=TableToCSV(param(i));
SuppTable(i).Var=var_names{i};
SuppTable(i).Field=fieldname;
SuppTable(i).State=state;
SuppTable(i).Group_L=[num2str(param_Data.mean_group_L,2) '±'  num2str(param_Data.std_group_L,2)];
SuppTable(i).Group_H=[num2str(param_Data.mean_group_H,2) '±'  num2str(param_Data.std_group_H,2)];
SuppTable(i).Fstat=['F(1, ' num2str(param_Data.DF2) ')= ' num2str(param_Data.FStat,2)];
SuppTable(i).P=[num2str(param_Data.p_val,3)];
%SuppTable(i).Effect_Size=['η2 = ' num2str(param_Data.effect_size,2)];
SuppTable(i).Corr=['Corr=' num2str(param_Data.Corr,2) ' p= ' num2str(param_Data.CorrP,3)];
end
end