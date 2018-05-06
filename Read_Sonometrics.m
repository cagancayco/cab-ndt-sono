function [time,data,adc] = Read_Sonometrics(filename,n_Tot,n_Tx,ad)
% This is a matlab function to read in Sonometrics text files and format them
% into a matlab structure.
% Written By: Sebastian Giudice and Ahmed Alshareef
% Modified: 12/15/2017

%INPUT
% filename -> name of sonometrics text file
% n_Tot -> total number of crystals (32)
% n_Tx -> total number of transmitters (8)
% ad -> number of ADC signals (1)

% OUTPUT
% Data output is an 8x2 cell. Each row is a transmitter. First column is
% transmitters and second column is each receiver. i.e. row 1, column 2 is
% transmitter 1 to all receivers. row 6, column 1 is transmitter 6 to other
% transmitters.

% Define and read in text file
if ad == 1
    str = importdata(filename,' ',72);
    raw_data = str.data;
    time = raw_data(:,1); % Time data
    adc = raw_data(:,2); % A/D channel with trigger info
    
elseif ad == 2
    str = importdata(filename,' ',73);
    raw_data = str.data;
    time = raw_data(:,1); % Time data
    adc = raw_data(:,2:3); % A/D channel with trigger info
end

% Define number of crystals
n_Rx = n_Tot - n_Tx; % Number of crystals receiving only
n_pair = n_Tot*n_Tx - n_Tx; % Number of Tx/Rx pairs

%%
% Separate Raw Data by Tx --> Each Row corresponds to each Tx
% 1st Column is TxRx, 2nd column is Rx
data = {};

if ad == 1
    for ii = 1:n_Tx
        data{ii,1} = raw_data(:,(3*ii + (n_Tot - 4)*(ii-1)):(3*ii + (n_Tot - 4)*(ii-1))+(n_Tx-2)); % Transmitter to all transmitters
        data{ii,2} = raw_data(:,(3*ii + (n_Tot - 4)*(ii-1))+(n_Tx-2)+1:(3*ii + (n_Tot - 4)*(ii-1))+(n_Tx-2)+1+(n_Rx-1)); % Transmitter to all receivers
    end
elseif ad == 2
    for ii = 1:n_Tx
        data{ii,1} = raw_data(:,(4*ii + (n_Tot - 5)*(ii-1)):(4*ii + (n_Tot - 5)*(ii-1))+(n_Tx-2)); % Transmitter to all transmitters
        data{ii,2} = raw_data(:,(4*ii + (n_Tot - 5)*(ii-1))+(n_Tx-2)+1:(4*ii + (n_Tot - 5)*(ii-1))+(n_Tx-2)+1+(n_Rx-1)); % Transmitter to all receivers
    end
end

