%After running script_antipsychotic_clustering.m type the following:

%Note: all this is NORMALIZED (to positive controls) fish data, and only
%25uM data! All the extraction and normalization is done in the above
%script.
close all
clear all

script_antipsychotic_clustering
close all

load('clo_thior_data.mat');
load('haloperidol_doseresponse.mat');
data_halo = data_newbattery; clear data_newbattery;
data_clo = normalizeFishData(data_clo,clo_dmsoIdx,1);
data_thior = normalizeFishData(data_thior,thior_dmsoIdx,1);
data_halo = normalizeFishData(data_halo,halo_dmsoIdx,1);

drugA = data_thior(logical(idx_thior_25 + idx_thior_21),:);
drugB = data_clo(idx_clo_25,:);
drugA_name = 'Thioridazine';
drugB_name = 'Clozapine';

[data_feat, featnames] = compareDrugs(drugA, drugB, drugA_name, drugB_name);