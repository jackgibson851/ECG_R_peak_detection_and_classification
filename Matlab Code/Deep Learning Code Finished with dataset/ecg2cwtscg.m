function ecg2cwtscg(ecgdata,cwtfb,ecgtype)
% Converts long ECG signal into shorter sample chunks
%then performs continuous wavelet transform and maps coefficents to 
%RGB values and stores as jpg to be fed to CNN for Transfer Learning 

numsigs = 10;       %number of signals to be produced from each larger signal (10)
siglength = 6553;     % length of each signal 
colourmap = jet(128);% Jet 128 colourmap used 

if ecgtype == 'ARR'    % if the ecgtype is ARR: go to the file in the created directory 
    pathToFolder = strcat('C:\Users\jackg\OneDrive\Documents\MATLAB\Digital_Signal_Processing\deep_learning\ecgdataset\arr\');
    findx =0; 
    for i = 1:24    % do for all 24 signals 
        indx = 0;         
        for k= 1:numsigs                                         % do for all chunks 
            ecgsignal = ecgdata(i,indx+1:indx+siglength);        %take the first chunk 
            coeff = abs(cwtfb.wt(ecgsignal));                    % find the coefficents 
            im = ind2rgb(im2uint8(rescale(coeff)), colourmap);   % convert to unsigned array, resize the
                                                                 %coefficents to between 0 and 1 and using colour map convert to image    
            filenameindex = findx+k;  
            filename = strcat(pathToFolder,sprintf('%d.jpg',filenameindex));
            imwrite(imresize(im,[227 227]),filename);         % stored as a jpg file in the current directory as an alexnet compatable 227x227
            indx=indx+siglength;
        end
        findx= findx+numsigs;   
    end
    
elseif ecgtype == 'CHF'  %if chf:  do the same but in chf directory  
    pathToFolder =strcat('C:\Users\jackg\OneDrive\Documents\MATLAB\Digital_Signal_Processing\deep_learning\ecgdataset\chf\');
    findx = 0; 
    for i = 1:24
        indx=0;
        for k= 1:numsigs 
            ecgsignal = ecgdata(i,indx+1:indx+siglength);
            coeff = abs(cwtfb.wt(ecgsignal));
            im = ind2rgb(im2uint8(rescale(coeff)), colourmap);
            filenameindex = findx+k;
            filename = strcat(pathToFolder,sprintf('%d.jpg',filenameindex));
            imwrite(imresize(im,[227 227]),filename);
            indx=indx+siglength;
        end
        findx= findx+numsigs;
    end
    
elseif ecgtype == 'NSR'   %if NSR:  do the same but in NSR directory
    pathToFolder =strcat('C:\Users\jackg\OneDrive\Documents\MATLAB\Digital_Signal_Processing\deep_learning\ecgdataset\nsr\');
    findx = 0; 
    for i = 1:24
        indx=0;
        for k= 1:numsigs 
            ecgsignal = ecgdata(i,indx+1:indx+siglength);
            coeff = abs(cwtfb.wt(ecgsignal));
            im = ind2rgb(im2uint8(rescale(coeff)), colourmap);
            filenameindex = findx+k;
            filename = strcat(pathToFolder,sprintf('%d.jpg',filenameindex));
            imwrite(imresize(im,[227 227]),filename);
            indx=indx+siglength;
        end
        findx= findx+numsigs;
    end        
end       