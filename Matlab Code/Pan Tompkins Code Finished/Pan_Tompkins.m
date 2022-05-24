clear all;
path = 'C:\Users\44777\Desktop\DSP\data';

files = dir(strcat(path,'\*.mat'));
N = length(files) ;   % total number of files 
sense_array = [];
pp_array = [];

for i = 1:N
    thisfile = files(i).name;
    data = load(thisfile);
    indx = thisfile(1:end-4);
    sig = data.(indx).sig;
    ann = data.(indx).ann;
    ann_type = data.(indx).annType;
    ann_types_array = ["N", "L", "R", "B", "A", "a", "J", "S", "V", "r", "F", "e", "j", "n", "E", "/", "F", "q", "?"];

    fs = 360;
    [num, denom] = butter(1,[8 15]/(fs/2));
    band_pass    = filtfilt(num,denom,sig); % Nagates phase shift
    band_pass = abs(band_pass);
    derivitive_squared = diff(band_pass).^2;
    signal = movmean(derivitive_squared, 57.6);

    [pks,locs] = findpeaks(signal,'MINPEAKDISTANCE',round(0.2*fs));
    [pksf,locsf] = findpeaks(band_pass,'MINPEAKDISTANCE',round(0.2*fs));


    THR_SIGI = max(signal(1:2*fs))*1/3;  
    THR_NOISEI = mean(signal(1:2*fs))*1/2;

    THR_SIGF = max(band_pass(1:2*fs))*1/3;               
    THR_NOISEF = mean(band_pass(1:2*fs))*1/2; 
    
    SPKI = THR_SIGI;
    NPKI = THR_NOISEI;
    SPKF = THR_SIGF;
    NPKF = THR_NOISEF;

    threshlinei = zeros(length(pks),1);
    SIGS = ones(length(pks),1);
    SIG_VAL = ones(length(pks),1);
    
    RR_avg1_count = 1;
    AVG1_LIST = zeros(length(8),1);
    RR_avg2_count = 1;
    AVG2_LIST = zeros(length(8),1);
    
    percentage = zeros(length(ann),1);
    PREVPEAKLOC = 0;
    SEARCH = 0;
    
    non_type    = zeros(length(ann),1);
    missed_beats = zeros(length(ann), 1);
    cardiologist = zeros(length(ann),1);
    false_positive = zeros(length(ann),1);
    false_negative = zeros(length(ann),1);
    true_positive = zeros(length(ann),1);
    f = 1;
    e = 1;
    d = 1;
    c = 1;
    b = 1;
    a = 1;
    
    for n = 1:length(pks)
        
        if SEARCH == 0
            THRESHOLDI = NPKI + 0.25*(SPKI-NPKI);
            THRESHOLDF = NPKF + 0.25*(SPKF-NPKF);
        elseif SEARCH == 1
            THRESHOLDI = 0.5 * (NPKI + 0.25*(SPKI-NPKI));
            THRESHOLDF = 0.5 * (NPKF + 0.25*(SPKF-NPKF));
        end
        
        RR_AVG1 = 0.125*mean(AVG1_LIST);
        RR_AVG2 = 0.125*mean(AVG2_LIST);
        PEAKI = pks(n);
        PEAKLOC = locs(n);
        RRPEAK = abs(PREVPEAKLOC - PEAKLOC);
        PREVPEAKLOC = PEAKLOC;
        
                
        [dist,idx] = min(abs(locsf-PEAKLOC));
        
        if dist < 30
            PEAKF = pksf(idx);
            
            if PEAKI < THRESHOLDI
                NPKI = (0.125*PEAKI) + (0.875*NPKI);
                
                if RR_avg1_count ~= 8
                    AVG1_LIST(RR_avg1_count) = PEAKLOC;
                    RR_avg1_count = RR_avg1_count + 1;
                    
                elseif RR_avg1_count == 8
                    RR_AVG1 = 0.125*mean(AVG1_LIST);
                    AVG1_LIST = AVG1_LIST(2:end);
                    AVG1_LIST(8) = PEAKLOC;
                    
                    if RRPEAK < RR_AVG1
                        if RR_avg2_count ~= 8
                            AVG2_LIST(RR_avg2_count) = PEAKLOC;
                            RR_avg2_count = RR_avg2_count + 1;
                            
                        elseif RR_avg2_count == 8
                            RR_AVG2 = 0.125*mean(AVG2_LIST);
                            
                            if RRPEAK < (0.92 * RR_AVG2) || RRPEAK > (1.16 * RR_AVG2)
                                SEARCH = 1;
                            else
                                AVG2_LIST = AVG2_LIST(2:end);
                                AVG2_LIST(8) = PEAKLOC;
                                SEARCH = 0;
                            end
                        end
                    end
                end
            else
                if PEAKF < THRESHOLDF
                    NPKF = (0.125*PEAKF) + (0.875*NPKF);                    
                else
                    SPKI = (0.125*PEAKI) + (0.875*SPKI);
                    SPKF = (0.125*PEAKF) + (0.875*SPKF);
                    SIGS(n) = locs(n);
                    SIG_VAL(n) = pks(n);
                end
            end          
        else
            continue
        end
        threshlinei(n) = THRESHOLDI;
        
        [check,local] = min(abs(ann - SIGS(n)));
        
        if check < 5
            percentage(n) = ann(local);
        else
            percentage(n) = 0;
        end        
    end
    

    % This code takes out non beat types from the ann locations and puts
    % them into a list called non_type
    for z=1:length(ann_type)
        if (ismember(ann_types_array, ann_type(z))) == 0
            non_type(a) = ann(z);
            a = a +1;
        end
    end
    
    % This code compares the list of non types to the list of ann locations
    % and if this comparison returns as a zero, it means its an accepted
    % beat and we confirm it is cardiologist data
    for w=1:length(ann)
        if (ismember(non_type,ann(w)))==0
            cardiologist(c) = ann(w);
            c = c + 1;
        end
    end
    
    cardiologist = cardiologist(cardiologist ~= 0);
    accepted = unique(percentage);
    
    % This code compares the cardiologist data to the accepted list of ann
    % locations that the code says it closely detected. If this code
    % returns a zero, we note it as a missed beat
    for y=1:length(cardiologist)
        if (ismember(accepted, cardiologist(y))) == 0
            missed_beats(b) = cardiologist(y);
            b = b + 1;
        end
    end
    
    % This code compares the data we have have located to the non type
    % datasets in the can we have hit a false positive
    for h=1:length(accepted)
        if (ismember(non_type, accepted(h))) == 0
            continue
        else
            false_positive(a) = accepted(h);
            d = d + 1;
        end
    end
    
    % This code compares the cardiologist data without the non type beats
    % to the missed beats we have to check is the code has any false
    % negatives
    for j=1:length(cardiologist)
        if (ismember(missed_beats, cardiologist(j))) == 0
        else
            false_negative(f) = cardiologist(j);
            f = f + 1;
        end
    end
    
    % This code compares the data we have have located to the cardiologist
    % data without the non type beats to check for true positives
    for g=1:length(cardiologist)
        if (ismember(accepted, cardiologist(g))) == 0
        else
            true_positive(e) = cardiologist(g);
            e = e + 1;
        end
    end
    
    % This section takes out all the zeros and repeated data from the above
    % calculations as this was a predefined array of zeros at the start and
    % no values should be repeated in a time array
    false_positive = unique(false_positive);
    false_positive = false_positive(false_positive ~=0);
    
    false_negative = unique(false_negative);
    false_negative = false_negative(false_negative ~=0);
    
    true_positive = unique(true_positive);
    true_positive = true_positive(true_positive ~=0);
 
    missed_beats = unique(abs(missed_beats));
    missed_beats = missed_beats(missed_beats ~= 0);
    non_type = unique(abs(non_type));
    non_beats = non_type(non_type ~= 0);
    
    threshlinei(threshlinei <= 0 ) = NaN;

    % This is for sensitivities and PPV
    sensitivity = (size(true_positive) / ((size(true_positive) + size(false_negative))))* 100;
    ppv = (size(true_positive) / ((size(true_positive) + size(false_positive)))) * 100; 
    disp(indx);
    disp(sensitivity);
    disp(ppv);
    
    figure;
    hold on
    plot(1:length(signal), signal);
    plot(SIGS, signal(SIGS), 'x');
    plot(ann, signal(ann), 'o')
    plot(non_beats, signal(non_beats), '*');
    plot(locs, threshlinei, '--r');
    
    sense_array(i) = sensitivity;
    pp_array(i) = ppv;

end

perf_s = mean(sense_array);
perf_p = mean(pp_array);