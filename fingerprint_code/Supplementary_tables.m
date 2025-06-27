directory='/Users/worg/Documents/fingerprint/not_relevant/';


load([ directory 'beck_wake_table_supp_prc_1585_BM.mat']);
[SuppTable_Beck_Wake]=prepare_tables(TableToCSV,'Wake','Beck');
load([ directory 'beck_sleep_table_supp_prc_1585_BM.mat']);
[SuppTable_Beck_Sleep]=prepare_tables(TableToCSV,'Sleep','Beck');
load([ directory 'TA_wake_table_supp_prc_1585_BM.mat']);
[SuppTable_TA_Wake]=prepare_tables(TableToCSV,'Wake','STAI-Trait');
load([ directory 'TA_sleep_table_supp_prc_1585_BM.mat']);
[SuppTable_TA_Sleep]=prepare_tables(TableToCSV,'Sleep','STAI-Trait');
load([ directory 'AQ_wake_table_supp_prc_1585_BM.mat']);
[SuppTable_AQ_Wake]=prepare_tables(TableToCSV,'Wake','AQ');
load([ directory 'AQ_sleep_table_supp_prc_1585_BM.mat']);
[SuppTable_AQ_Sleep]=prepare_tables(TableToCSV,'Sleep','AQ');


[SuppTable_Beck_Wake,SuppTable_Beck_Sleep,...
    SuppTable_TA_Wake,SuppTable_TA_Sleep,...
    SuppTable_AQ_Wake,SuppTable_AQ_Sleep];





function [SuppTable]=prepare_tables(TableToCSV,state,fieldname)
load('vars.mat');
param=[1:16,18:25];
var_names=var_names(param);
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