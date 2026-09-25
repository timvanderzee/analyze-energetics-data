function[] = estimate_momarm(Ps)

fs = 1000;
dt = 1/fs;

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

% Ps = 16;

conds = {'_nulhoek', '_ROM'};

colors = lines(20);

FLm = nan(15, 13, 2);
KAm = nan(15, 13, 2);

for P = Ps
    disp(P)
    
    subject_folder = fullfile(datafolder, ['P', num2str(P)]);
    
    %% Cybex files
    cybex_folder = fullfile(subject_folder, 'cybex');
    
    %     subject_folder = ['C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset\p', num2str(P), '\cybex'];
    
    if isfolder(cybex_folder)
        
        for j = 1:length(conds)
            
            cd(cybex_folder)
            filename = ['p', num2str(P), conds{j}, '.c3d'];
            
            if exist(filename, 'file')
                data = ezc3dRead(filename);
                
                % Read analog data
                analogData = data.data.analogs;  % [samples × channels]
                
                N = length(analogData);
                t = 0:dt:(N-1)*dt;
                
                %             Kangle = analogData(:,17) * 180/pi;
                
                [b,a] = butter(1, 0.2/(.5*fs), 'low');
                
                Kangle = analogData(:,17) * 180/pi;
                Ktorq = analogData(:,20) * 1000;
                Kvel = analogData(:,18);
                Kvel_filt = filtfilt(b,a,abs(Kvel));
                
                id = Kvel_filt(:) < .01; % & t(:) < 130;
                
            end
            
            %% ultrasound
            ultrasound_folder = fullfile(subject_folder, 'ultrasound');
            %         delay = 2;
            
            if isfolder(ultrasound_folder)
                cd(ultrasound_folder)
                filename = ['p', num2str(P), conds{j}, '.mat'];
                
                
                load(filename, 'Time', 'FL');
                
                Faslen = interp1(Time, FL, t) / 10; % mm -> cm
                
                %             Faslen(t > 100) = nan;
                %
                %             if P == 10
                %                 Faslen(t > 50 & t < 70) = nan;
                %             elseif P == 11
                %                 Faslen(t > 120) = nan;
                %             elseif P == 15
                %                 Faslen(t > 90) = nan;
                %
                %             end
                
                isf = isfinite(Faslen);
                %             p0 = polyfit(Kangle(id(:)&isf(:)) * pi/180, Faslen(id(:)&isf(:)), 2);
                
                %             p = fmincon(@(p) fitp(p, Kangle(id(:)&isf(:)) * pi/180,  Faslen(id(:)&isf(:))), p0, [1 0 0; 0 1 0], [0 -2]);
                
                %             pd = polyder(p);
                
                
                
                figure(1)
                subplot(221)
                plot(t, Kangle, 'k.'); hold on
                plot(t(id), Kangle(id), '.', 'color', colors(P,:)); hold on
                
                subplot(222)
                plot(t, Faslen, 'k.'); hold on
                plot(t(id), Faslen(id),'.', 'color', colors(P,:)); hold on
                
                subplot(223)
                plot(Kangle(id) * pi/180, Faslen(id), '.', 'color', colors(P,:)); hold on
                %             plot((0:80)* pi/180, polyval(p, (0:80)* pi/180));
                
                
                if j == 2
                    angs = .19 + (0:5:60) * pi/180;
                else
                    angs = mean(Kangle, 'omitnan') * pi/180;
                end
                
                Kangle_rad = Kangle * pi/180;
                
                for jj = 1:length(angs)
                    
                    FLm(P, jj, j) = mean(Faslen(id & Kangle_rad > (angs(jj) - .03) & Kangle_rad < (angs(jj) + .03)), 'omitnan');
                    KAm(P, jj, j) = mean(Kangle_rad(id & Kangle_rad > (angs(jj) - .03) & Kangle_rad < (angs(jj) + .03)), 'omitnan');
                end
                
                plot(KAm(P,:,j), FLm(P,:,j), 'o', 'color', colors(P,:));
            
                
                
                %             plot(x,y,'k--')
                
%                 subplot(224)
                %             plot((0:80)* pi/180, polyval(pd, (0:80)* pi/180));
                
                %             Bs(P,:) = pd;
                
                
            end
            
        end
    end
end

return
%% combine
% close all
FLs = [FLm(:,:,2) FLm(:,1,1)];
KAs = [KAm(:,:,2) KAm(:,1,1)];

FLs = FLm(:,:,2);
KAs = KAm(:,:,2);

id1 = 6;
id2 = 12;

figure(100)

subplot(121)
plot(mean(KAs, 'omitnan'), mean(FLs, 'omitnan'),'o-'); hold on
plot(mean(KAs(:,id1:id2), 'omitnan'), mean(FLs(:,id1:id2), 'omitnan'),'o-')

p0 = polyfit(mean(KAs(:,id1:id2), 'omitnan'), mean(FLs(:,id1:id2), 'omitnan'),2);
p = fmincon(@(p) fitp(p, mean(KAs(:,id1:id2), 'omitnan'), mean(FLs(:,id1:id2), 'omitnan')), p0, [1 0 0; 0 1 0], [0 -2]);

hold on


x = linspace(0,1.5, 100);

plot(x, polyval(p, x), 'k--')


subplot(122)
plot(x, polyval(polyder(p), x), 'k--')


%%
figure(1)
subplot(223)


for ii = 1:length(angs)
    xline(angs(ii),'k--')
end

%             y = -3 * x + 1.2 * 3;

r1 = -2;
r2 = -4;

r = (r2-r1)/(pi/2);
R = r * x + r1;
L = r/2 * x.^2 + r1 * x + 2;

plot(x,L)


subplot(224)
plot(x, R)
for ii = 1:length(angs)
    xline(angs(ii),'k--')
end
%% save
% cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
% save('gravity.mat', 'As', 'Bs')

% end
end

%%
function[cost] = fitp(p, x, y)

yf = polyval(p, x);
cost = sum((y(:)-yf(:)).^2);

end



