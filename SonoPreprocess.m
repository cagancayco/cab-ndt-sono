%% Sonometric Data Preprocessing

clear; clc;

%% Load sono_struct

struct_filename = 'NDT896_axi.mat';

load(struct_filename);

e_tolerance = 0.21;

%% Preprocess okay signals

counter = 0;
fixed = [];
for i = 1:length(sono_struct)
    sono_struct(i).ipts = [];
    sono_struct(i).outlier_types = [];
     sono_struct(i).auto_preprocessed = sono_struct(i).raw;
    if sono_struct(i).quality == 1
        sono_struct(i).ipts =  findchangepts([sono_struct(i).outliers],'MinThreshold',2);
        
        numOutlierGrps = numel(sono_struct(i).ipts) + 1;
        
        if numOutlierGrps == 1           
            sono_struct(i).auto_preprocessed(sono_struct(i).outliers(1:end-1)) = [];
            idx = 1:length(sono_struct(i).raw);
            idx(sono_struct(i).outliers(1:end-1)) = [];
            sono_struct(i).auto_preprocessed = (pchip(idx, sono_struct(i).auto_preprocessed, 1:length(sono_struct(i).raw)))';
            
            sono_struct(i).outlier_types = {'outlier'};            
           
            counter = counter + 1; fixed = [fixed; i];
        end
        
    plot(sono_struct(i).raw,'*-'); hold on; plot(sono_struct(i).outliers,sono_struct(i).raw(sono_struct(i).outliers),'*r'); plot(sono_struct(i).auto_preprocessed,'g'); hold off    
        
    end

    
end

