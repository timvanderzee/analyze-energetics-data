clear all; close all; clc

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

Ps = [10, 11, 12, 15];
delay = 2;

for P = Ps
    disp(P)

    subject_folder = fullfile(datafolder, ['P', num2str(P)]);
    ultrasound_folder = fullfile(subject_folder, 'ultrasound');
    
    
    if isfolder(ultrasound_folder)
        cd(ultrasound_folder)
        
        files = dir('*.mat');
        
        for i = 1:length(files)
            
            disp(files(i).name);
            load(files(i).name, 'Fdat');
            
            FL = Fdat.Region.FL;
            PEN = Fdat.Region.PEN;
            Time = Fdat.Region.Time + delay; % convert to nexus time
            
            newname = erase(files(i).name, '_tracked');
            
            save(newname, 'FL', 'PEN', 'Time')
        end
    end
end
