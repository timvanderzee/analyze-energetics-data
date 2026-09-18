function[] = get_gravity(Ps)

% Ps = 18;
% As =  nan(length(Ps),3);

cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
load('gravity.mat', 'As', 'Bs')

fs = 1000;
dt = 1/fs;

% fitting functions
func = @(a,x) a(1) * cosd(x-a(2)) + a(3);
cfunc = @(a,x,y) sum((y - func(a,x)).^2);
% as = linspace(-pi/2, pi, 100);
as = linspace(-90, 180, 100);

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

for P = Ps
    disp(P)

    subject_folder = fullfile(datafolder, ['P', num2str(P)]);
    
    %% Cybex files
    cybex_folder = fullfile(subject_folder, 'cybex');
    
%     subject_folder = ['C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset\p', num2str(P), '\cybex'];
    
    if isfolder(cybex_folder)
        cd(cybex_folder)
        filename = ['p', num2str(P), '_ROM.c3d'];
        
        if exist(filename, 'file')
            data = ezc3dRead(filename);
            
            % Check available analog channels
            analogLabels = data.parameters.ANALOG.LABELS.DATA;
            
            % Read analog data
            analogData = data.data.analogs;  % [samples × channels]
            
            
            N = length(analogData);
            t = 0:dt:(N-1)*dt;           
            
            [b,a] = butter(1, 0.2/(.5*fs), 'low');
            
            Kangle = analogData(:,17) * 180/pi;
            Ktorq = analogData(:,20) * 1000;
            Kvel = analogData(:,18);
            Kvel_filt = filtfilt(b,a,abs(Kvel));
            
            id = Kvel_filt(:) < .01; % & t(:) < 130;
            
            %%
            figure(P)
            subplot(221)
            plot(t, Kangle, t(id), Kangle(id));
            
            subplot(222)
            plot(t, Kvel, t, Kvel_filt)
            
            subplot(223)
            plot(t, Ktorq, t(id), Ktorq(id))
            
            subplot(224)
            plot(Kangle(id), Ktorq(id),'.')
            
            
            %% fit a cosine            
            A = fminsearch(@(a) cfunc(a,Kangle(id), Ktorq(id)), [1 1 1]);
                        
            hold on
            plot(as, A(1)*cosd(as-A(2)) + A(3));
            
            %% Save
            As(P,:) = A;
            
        else
            if P == 7 % take it from MVC and nulhoek

                
                filenames = {'p7_MVC_QUAD_L.c3d', 'p7_MVC_HAMS.c3d', 'p7_nulhoek.c3d'};
                
                for j = 1:length(filenames)
                    data = ezc3dRead(filenames{j});
                    
                    % Check available analog channels
                    analogLabels = data.parameters.ANALOG.LABELS.DATA;
                    
                    % Read analog data
                    analogData = data.data.analogs;  % [samples × channels]
                    
                    
                    N = length(analogData);
                    t = 0:dt:(N-1)*dt;
                    
                    [b,a] = butter(1, 0.5/(.5*fs), 'low');
                    
                    Kangle = analogData(:,17) * 180/pi;
                    Ktorq = analogData(:,20) * 1000;
                    Kvel = analogData(:,18);
                    Kvel_filt = filtfilt(b,a,abs(Kvel));
                    
                    id = t < 5;
                    
                    figure(P)
                    subplot(311)
                    plot(t(id), Kangle(id)); hold on
                    
                    subplot(312)
                    plot(t(id), Ktorq(id)); hold on
                    
                    subplot(313)
                    plot(Kangle(id), Ktorq(id),'.'); hold on
                    
                    mKangle(j) = mean(Kangle(id));
                    mKtorq(j) = mean(Ktorq(id));
                end
                
                A = fminsearch(@(a) cfunc(a,mKangle, mKtorq), [1 1 1]);
                hold on
                plot(as, A(1)*cosd(as-A(2)) + A(3));
                
                % Save
                As(P,:) = A;
                
            end
        end
        
        %% ultrasound
        ultrasound_folder = fullfile(subject_folder, 'ultrasound');
%         delay = 2;
        
        if isfolder(ultrasound_folder)
            cd(ultrasound_folder)
            filename = ['p', num2str(P), '_ROM.mat'];
            
            
            load(filename, 'Time', 'FL');

            Faslen = interp1(Time, FL, t) / 10; % mm -> cm
            
            Faslen(t > 100) = nan;
            
            if P == 10
                Faslen(t > 50 & t < 70) = nan;
            elseif P == 11
                Faslen(t > 120) = nan;
            elseif P == 15
                Faslen(t > 90) = nan;
            end
            
            isf = isfinite(Faslen);
            p0 = polyfit(Kangle(id(:)&isf(:)) * pi/180, Faslen(id(:)&isf(:)), 2);
            
            p = fmincon(@(p) fitp(p, Kangle(id(:)&isf(:)) * pi/180,  Faslen(id(:)&isf(:))), p0, [1 0 0; 0 1 0], [0 -2]);
            
            pd = polyder(p);
            
            figure(2)
            subplot(221)
            plot(t, Kangle); hold on
            plot(t(id), Kangle(id), '.'); hold on
            
            subplot(222)
            plot(t, Faslen); hold on
            plot(t(id), Faslen(id),'.'); hold on
            
            subplot(223)
            plot(Kangle(id) * pi/180, Faslen(id), '.'); hold on
            plot((0:80)* pi/180, polyval(p, (0:80)* pi/180));
            
            subplot(224)
            plot((0:80)* pi/180, polyval(pd, (0:80)* pi/180));
            
            Bs(P,:) = pd;
            
        end
                
    end
end

%% save
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
save('gravity.mat', 'As', 'Bs')

end


%%
function[cost] = fitp(p, x, y)

yf = polyval(p, x);
cost = sum((y(:)-yf(:)).^2);

end



