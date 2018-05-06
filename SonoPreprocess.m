%% Sonometric Data Preprocessing

clear; clc;

%% Load sono_struct

struct_filename = 'NDT896_axi.mat';

load(struct_filename);

%% Preprocess okay signals

for i = 1:length(sono_struct)
    sono_struct(i).ipts = [];
    if sono_struct(i).quality == 1
        sono_struct(i).ipts =  findchangepts([sono_struct(i).outliers],'MinThreshold',2);
        
        numOutlierGrps = numel(sono_struct(i).ipts) + 1;
        
        
        
        
        
    end
end
