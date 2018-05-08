%% Sonometric Data Preprocessing

clear; clc;

%% Load sono_struct

struct_filename = 'NDT896_axi.mat';

load(struct_filename);

e_tolerance = 0.21;

%% Preprocess okay signals

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
%         else
%             diff_outliers = [];
%             for j = 1:length(sono_struct(i).outliers)
%                 
%                 %diff_before = sono_struct(i).raw(sono_struct(i).outliers(j)) - sono_struct(i).raw(sono_struct(i).outliers(j)-1);
%                 diff_after = sono_struct(i).raw(sono_struct(i).outliers(j)+1) - sono_struct(i).raw(sono_struct(i).outliers(j));
%                 diff_outliers = [diff_outliers;diff_after]; %diff_before,diff_after];                
%             end
%             
%             left_bin = floor(min(abs(diff_outliers))*10)/10;
%             right_bin = ceil(max(abs(diff_outliers))*10)/10;
%             
%             edges = left_bin:0.1:right_bin;
%             
%             counts = histcounts(abs(diff_outliers),edges);
%             counts = counts/numel(diff_outliers);
%             
%             levelshift_vals = [];
%             for k = 2:length(counts)
%                 if counts(k) >= 0.2 && edges(k) > 1
%                     levelshift_vals = [levelshift_vals; (edges(k)+ edges(k-1))/2];
%                 end                
%             end
%             
%             if numel(levelshift_vals) > 1
%                 for k = 2:length(levelshift_vals)
%                     if levelshift_vals(k)-levelshift_vals(k-1) <= e_tolerance
%                         levelshift_vals(k) = (levelshift_vals(k) + levelshift_vals(k-1))/2;
%                         levelshift_vals(k-1) = 0;
%                     end
%                 end
%             end
%                 
%             levelshift_vals(levelshift_vals==0) = [];
%             
%             outlier_groups = cell(numOutlierGrps,1);
%             
%             levelshift_points = [];
%             
%             for m = 1:numOutlierGrps
%                 if m == 1
%                     outlier_groups{m} = sono_struct(i).outliers(1:sono_struct(i).ipts(m)-1);
%                 elseif m == numOutlierGrps
%                     outlier_groups{m} = sono_struct(i).outliers(sono_struct(i).ipts(m-1):end);
%                 else
%                     outlier_groups{m} = sono_struct(i).outliers(sono_struct(i).ipts(m-1):sono_struct(i).ipts(m)-1);
%                 end                                            
%             end
%             
%             if numOutlierGrps == 2 && numel(diff_outliers) == 4
%                 if diff_outliers(1) < 0
%                     sono_struct(i).auto_preprocessed(sono_struct(i).outliers(2):sono_struct(i).outliers(3)) = sono_struct(i).auto_preprocessed(sono_struct(i).outliers(2):sono_struct(i).outliers(3)) + levelshift_vals;
%                 else
%                     sono_struct(i).auto_preprocessed(sono_struct(i).outliers(2):sono_struct(i).outliers(3)) = sono_struct(i).auto_preprocessed(sono_struct(i).outliers(2):sono_struct(i).outliers(3)) - levelshift_vals;
%                 end
%             end
            
           
        end
        
    plot(sono_struct(i).raw,'*-'); hold on; plot(sono_struct(i).outliers,sono_struct(i).raw(sono_struct(i).outliers),'*r'); plot(sono_struct(i).auto_preprocessed,'g'); hold off    
        
    end
end
