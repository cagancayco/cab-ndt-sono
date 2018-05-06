%% Sonometric Data Loading

clear; clc

%% Specify test names

datasets   = {'20rps_60ms', ...
              '20rps_30ms', ...
              '40rps_60ms', ...
              '40rps_30ms', ...
              '40rps_30ms_B'};
        
specimen   = 'NDT896';
dxn        = 'axi';

nTx        = 8;
nRx        = 24;
nCrystals  = nTx + nRx;

label_file = 'Machine Learning Training Set.xlsx';

%% Instantiate matrices

% nTests = 5, nTransmitters = 8, nReceivers = 24
preprocessed   = cell(5, nTx, nRx);  % preprocessed trace data
t_preprocessed = cell(5, nTx, nRx);  % preprocessed time data
raw            = cell(5, nTx, nRx);  % raw trace data
t_raw          = cell(5, nTx, nRx);  % raw time data
labels         = zeros(5, nTx, nRx); % numerical label of trace quality
tx_rx          = cell(5, nTx, nRx);  % test and transmitter-receiver pair names

%% Extract data from text files

for i = 1:numel(datasets)
    test_name          = datasets{i};
    fname_preprocessed = strcat(specimen,'_',dxn,'_',test_name,'.TXT');
    fname_raw          = strcat(specimen,'_',dxn,'_',test_name,'_ML.TXT');
    
    [p_time, p_data, p_adc] = Read_Sonometrics(fname_preprocessed,nCrystals,nTx,1);
    [r_time, r_data, r_adc] = Read_Sonometrics(fname_raw,nCrystals,nTx,1);
    
    for j = 1:nTx
        for k = 1:nRx
            
            t_preprocessed{i,j,k} = p_time(1:332);
            preprocessed{i,j,k}   = p_data{j,2}(1:332,k);
            t_raw{i,j,k}          = r_time(1:332);
            raw{i,j,k}            = r_data{j,2}(1:332,k);
            
            if k == 1
                tx_rx{i,j,k} = [replace(test_name,'_',' '),' ','Tx ',num2str(j),', Rx 0',num2str(k+8)];
            else
                tx_rx{i,j,k} = [replace(test_name,'_',' '),' ','Tx ',num2str(j),', Rx ',num2str(k+8)];
            end
            
        end
    end
    
    curr_labels   = xlsread('Machine Learning Training Set.xlsx', test_name);
    labels(i,:,:) = curr_labels';
end

% Reshape the matrices
labels         = reshape(labels,[1,960])';
tx_rx          = reshape(tx_rx,[1,960])';
preprocessed   = cell2mat(reshape(preprocessed,[1,960]));
raw            = cell2mat(reshape(raw,[1,960]));
t_preprocessed = cell2mat(reshape(t_preprocessed,[1,960]));
t_raw          = cell2mat(reshape(t_raw,[1,960]));

[~, alphaorder] = sort(tx_rx);
labels          = labels(alphaorder);
tx_rx           = tx_rx(alphaorder);
preprocessed    = preprocessed(:, alphaorder);
raw             = raw(:, alphaorder);
t_preprocessed  = t_preprocessed(:, alphaorder);
t_raw           = t_raw(:, alphaorder);

%% Create Struct

sono_struct = struct;

for m = 1:960
    sono_struct(m).tx_rx          = tx_rx{m};
    sono_struct(m).label          = labels(m);
    sono_struct(m).t_raw          = t_raw(:,m);
    sono_struct(m).raw            = raw(:,m);
    sono_struct(m).t_preprocessed = t_preprocessed(:,m);
    sono_struct(m).preprocessed   = preprocessed(:,m);   
end

for n = 1:960
    sono_struct(n).d_norm   = mat2gray(sono_struct(n).raw);
    sono_struct(n).d_avg    = mean(sono_struct(n).raw);
    sono_struct(n).v        = diff(sono_struct(n).raw)./diff(sono_struct(n).t_raw);
    sono_struct(n).v_norm    = mat2gray(sono_struct(n).v);
    sono_struct(n).v_avg    = mean(abs(sono_struct(n).v));
    sono_struct(n).v_max    = max(abs(sono_struct(n).v));
    sono_struct(n).a        = diff(sono_struct(n).v)./diff(sono_struct(n).t_raw(2:end));
    sono_struct(n).a_norm   = mat2gray(sono_struct(n).a);
    sono_struct(n).a_max    = max(abs(sono_struct(n).a));
    
    if sono_struct(n).v_avg == 0 || sono_struct(n).d_avg > 180
        sono_struct(n).quality = 0;
    elseif sono_struct(n).v_avg > 5000 || sono_struct(n).a_max > 4e5 || sum(sono_struct(n).raw > 180) > 0
        sono_struct(n).quality = 1;
    else
        sono_struct(n).quality = 2;
    end

    if sono_struct(n).label == 2
        sono_struct(n).comp_lab = 1;
    elseif sono_struct(n).label == 3
        sono_struct(n).comp_lab = 2;
    else
        sono_struct(n).comp_lab = sono_struct(n).label;
    end    
    
end

for p = 1:length(sono_struct)
    
    sono_struct(p).outliers = [];
    
    if sono_struct(p).quality == 1
        v_outliers = [];
        for q = 1:length(sono_struct(p).v_norm)-1
            if abs(sono_struct(p).v_norm(q+1) - sono_struct(p).v_norm(q)) > 0.2
                v_outliers = [v_outliers; q];
            end
        end
    
        a_outliers = [];
        for r = 1:length(sono_struct(i).a_norm)-1
            if abs(sono_struct(p).a_norm(r+1) - sono_struct(p).a_norm(r)) > 0.2
                a_outliers = [a_outliers; r];
            end
        end
        
        sono_struct(p).outliers = intersect(v_outliers,a_outliers) + 1;
        
        if length(sono_struct(p).outliers) == 1
            sono_struct(p).quality = 2;
        end
    end
    
end



output_file = strcat(specimen,'_',dxn,'.mat');
save(output_file, 'sono_struct')

