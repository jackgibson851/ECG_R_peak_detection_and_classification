clear
clc
close all

%% Load in all files in sequential loop  
path = 'C:\Users\jackg\OneDrive\Documents\MATLAB\Digital_Signal_Processing\data';
files = dir(strcat(path, '\*.mat'));   % sets the directery to search and what files to search for (anything.mat)
n = length(files);                     % n defined for the for loop to set the length of the loop for all files. 
b = 1;              %patient in the loop (start at 1 and works up to 48)                  
 for i = 1:n

currentfile = files(i).name;  
data = load(currentfile);
indx = currentfile(1:end-4);
ecgsig = data.(indx).sig;        %.sig = ecg file 
ann = data.(indx).ann;           % .ann - annotations position
type = data.(indx).annType;      % . annType - the label on the annotation (needs to be changed to remove all non beats 

%% Pre Processing for removing non beats
% remove the non-beat values from the annotation types and add add the non beats to an array to predict the false negs 
a = 1;                            % set 'a' to one to initialise the position on the array  
clear CorrectString               % clear the previous correctString and FalseString
clear FalseString                 % variable at the start of each new data              
for i = 1 : length(type)          % cycle through from 1 to the length of the annType file to catch all annotations 
    

             % annotations named are all non-beats 
             % if these are found in the file set that value to a 0 or 1 for the 'a'th element 
         
        if type(i) == '?'
        CorrectString(a) = 0;
        FalseString(a) = 1;       % Non-beat annotations are collected in a Falsestring for a'th element 
    elseif type(i) == '[' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == ']' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == 'x' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == '(' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == ')' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == '~'
        CorrectString(a) = 0;
        FalseString(a) = 1;
    elseif type(i) == '!'
        CorrectString(a) = 0; 
        FalseString(a) = 1; 
    elseif type(i) == '+'
        CorrectString(a) = 0;
        FalseString(a) = 1;
    elseif type(i) == 'p' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;      
    elseif type(i) == 't' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;      
    elseif type(i) == 'u' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == '^' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == '|' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == 'S' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == 'T' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;      
    elseif type(i) == '*' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == 'D' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;       
    elseif type(i) == '"' 
        CorrectString(a) = 0; 
        FalseString(a) = 1;
    elseif type(i) == '@'
        CorrectString(a) = 0;
        FalseString(a) = 1; 
    else 
        CorrectString(a)= 1;       % If it's anything else then plot the the 'a'th array element to 1 
        FalseString(a) = 0; 
    end
    a = a+1;                          % shift the location in the array by one
end 
 locstr = CorrectString'.*ann;                % multiply the array of 1&0 by the locations of the
 Falselocstr = FalseString'.*ann;             % Do same fore Falselocstr
 Cardio_peak = locstr(locstr ~=0);            %annotations, all non zero values kept as Cardio_peak
 False_peak = Falselocstr(Falselocstr ~=0);   % same for False_peak used for calculating the false positive  

%% Descrete Wavelet Transform 

Fs = 360;                       % set the sampling frequency               
samples = 1:length(ecgsig);     % samples set to length of the ecg signal 
tx = samples./Fs;               % timing vector counts in seconds 

%Descrete wavelet transform 
wt = modwt(ecgsig, 5,'sym4');   % 5 level undecimated DWT using the ...
                                %'sym4' wavelet as it matches the normal ecg beat best 

wtrec = zeros(size(wt));        % array of zeros that makes length of wt all zero 

wtrec(4:5,:)=wt(4:5,:);         % the d4 and d5 coefficents extracted as ...
                                % frequencies we want lie in this area
                                
%inverse transform back but with zeros everywhere except where we keep
y1 = imodwt(wtrec, 'sym4');      

%% Set threshold for Peak Prediction 
y = abs(y1).^2;                  % square the magnitude to make all +ve

Threshold = mean(y);             % threshold moves with each new ecg signal 


%% Predict peaks and Beats Per Min 
[Rpeaks,Calculated_locs] = findpeaks(y,samples,'MinPeakHeight', Threshold,'MinPeakDistance',54); 

beat_num = length(Calculated_locs);                % No.of beats = No.ofPeaks 
timelimit = length(ecgsig)/Fs;                     % time limit in secs
BPM(b) = (beat_num*60)/timelimit;                  % calculate the beats per min 

%% Plot to figure, Raw ECG with fitted wavelet on top, predictions on abs squared vals under  
figure;
subplot(211);
plot(tx, ecgsig);               % plot the raw ecg data for 10 secs  
xlim([0,10]);  
hold on 
plot(tx, y1);                   % Plot the matched wavelet over the top of the ecg 
grid on;                  
xlabel('seconds');       
ylabel('ECG signal');
title(strcat('ECG signal   ',num2str(currentfile)));
legend('Raw ECG','Matched Wavelet');

subplot(212)
plot(samples,y);              % plot the abs. squared wavelet signal against the samples 
grid on 
xlim([0,3600]);               % limit to 10 sec of samples (@360Hz)
hold on 
plot(Calculated_locs, Rpeaks, 'ro');     % plot the predicted R peaks on top of the wavelet sig 
hold on 
plot(Cardio_peak, y(Cardio_peak), '*')   % plot the cardiologist values on top 
legend('Preprocessed Sig','Predicted "R" Peak', 'Cardiologist "R" Peak', 'Location','southwest');
xlabel('Samples');
title(strcat('R Peaks Found and Heart Rate:  ' , num2str(BPM(b))));

%% Performance analysis
tol =  5;   %54 samples is 150ms --> cardiac standard or Set to whatever tol is needed 
DS  =  1;
Positive = ismembertol(Cardio_peak, Calculated_locs', tol ,'DataScale',...
                        DS, 'ByRows', true ); 
False_P  = ismembertol(False_peak, Calculated_locs', tol, 'DataScale',...
                        DS, 'ByRows', true );  % returm 1 if in tol, 0 if not 

TP = Positive(Positive ~=0);           % True  Positive ( all peaks we correctly predict)
TN = length(ecgsig)-TP;                % True Negative  (don't need--> all values not peaks )
FP = False_P(False_P ~=0);             % False Positive (nothing there but we say there is)
FN = Positive(Positive ~=1);           % False Negative (was there and we missed)

Sensitivity(b) = length(TP)/(length(TP)+length(FN)) *100;
PPV(b)         = length(TP)/(length(TP)+length(FP)) *100;

%% Print to command Window
disp(strcat(num2str(currentfile), '--->  ', ' Heart Rate =', num2str(BPM(b)), ' BPM', ', Sensitivity =',...
    num2str(Sensitivity(b)), ' %', ', PPV =', num2str(PPV(b)), ' %' )); 
 
b=b+1; %move to next patient 

 end
 
 AvgSens = mean(Sensitivity);  % calculate the average sensitivity and Positive Predictive Value 
 AvgPPV = mean(PPV);
 Pats = [100,101,102,103,104,105,106,107,108,109,111,112,113,114,115,116,...
         117,118,119,121,122,123,124,200,201,202,203,205,207,208,209,210,...
         212,213,214,215,217,219,220,221,222,223,228,230,231,232,233,234];
     
  Tab_array = [Pats', BPM', Sensitivity', PPV']; % put all vals in 4x48 array 
  Performance_Table = array2table(Tab_array,'VariableNames',...
      {'Patient Number','BPM','Sensitivity (%)', 'PPV (%)'}) %convert array to table 
  
 disp(strcat('  Average Sensitivity =  ', num2str(AvgSens), ' %', '  Average PPV =  ', num2str(AvgPPV), ' %')); 