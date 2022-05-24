clear all
close all
clc

%% Load and Extract data 
load('ECGData.mat');      % load in data from all three databases 
data = ECGData.Data;      %extract data from mat file  
labels = ECGData.Labels;  % extract labels from mat file 

%% Take 30 recording of each condition and define length as 500 samples 
ARR = data(1:24, :);       %first 24 recordings taken for Arrythmia 
ARR_Test = data(25:30,:);  
CHF = data(97:120,:);      %Next 30 taken from heart failure (starts at 97)
CHF_Test = data(121:126,:);
NSR = data(127:150,:);     %Next 30 taken from Normal Sinus Rhythm (starting at 127)
NSR_Test = data(151:156,:);

signallength = 6553;        %break all 30 big signals down into small signals 
                           %of sample length 6553 this results in a total 
                           %num of 300 signals for each condition (split 80/20)                           

%% 
fb = cwtfilterbank('SignalLength', signallength, 'Wavelet','amor','VoicesPerOctave', 12);
% continuous wavelet transform filter bank function uses the length of 6553
% and the type of wavelet used is Analytic Morlet (amor)
%12 wavelet bandpass used per octive in the CWT 

%% create directories to store data for each condition  
mkdir('ecgdataset');       %ecgdataset file 
mkdir('ecgdataset\arr');   % arr file within 
mkdir('ecgdataset\chf');   % chf file within
mkdir('ecgdataset\nsr');   % nsr file within 
mkdir('ecgTest');
mkdir('ecgTest\arr');
mkdir('ecgTest\chf');
mkdir('ecgTest\nsr');

%% Define types of ecg wave 
ecgtype = {'ARR', 'CHF', 'NSR'};  %define the type of ecg wave condition 


%% execute function for splitting the signal into a RGB image  
ecg2cwtscg(ARR     , fb, ecgtype{1});    % converts the arr signals to images
ecg2cwtscg(CHF     , fb, ecgtype{2});    % converts the chf signals to images 
ecg2cwtscg(NSR     , fb, ecgtype{3});    % converts the nsr signals to images
ecg2cwtscgTEST(ARR_Test, fb, ecgtype{1});  
ecg2cwtscgTEST(CHF_Test, fb, ecgtype{2});  
ecg2cwtscgTEST(NSR_Test, fb, ecgtype{3});  

