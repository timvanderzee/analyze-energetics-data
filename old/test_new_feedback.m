clear all; close all; clc

cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\0903\P3\nexus\t1')

vtarget = 50;

vels = [50   100   150   200   -50  -100 -150 -200 0 0];
conds = {'c50_01', 'c100_01', 'c150_01', 'c200_01', 'e50_01', 'e100_01', 'e150_01', 'e200_01', 'ISOM_ext', 'ISOM_FL'};
data = ezc3dRead(['P3_', conds{vels == vtarget}, '.c3d']);

%%
% Check available analog channels
analogLabels = data.parameters.ANALOG.LABELS.DATA;

% Read analog data
analogData = data.data.analogs;  % [samples × channels]

signals_of_interest = {'Angular Velocity.1'};

id = nan(1,length(signals_of_interest));
for i = 1:length(signals_of_interest)
    for j = 1:length(analogLabels)
        if strcmp(analogLabels{j}, signals_of_interest(i))
            id(i) = j;
        end
    end
end

N = length(analogData);
dt = 1/1000;
t = 0:dt:(N-1)*dt;

Vel  = analogData(:,id(1)) * -180/pi;

%% make signal
close all

figure(1)
ax1 = subplot(211);
h = line('xdata', t, 'ydata', Vel);
g = line('xdata', t(1), 'ydata', Vel(1),'marker', 'o');
box off
ylim(ax1, [-250 250])

ax2 = subplot(212);
k = line('xdata', [0 max(t)], 'ydata', [1 1], 'linewidth', 2);
box off
ylim(ax2, [-.5 1.5])

time = 0;
fac = 5;

for i = 1:fac:6000
    
    % flip if negative
    vnow = Vel(i) * sign(vtarget); 
    
    % if movement, show target and reset timer
    if vnow > (sign(vtarget)*(vtarget * .9))
        
        time = 0;
        target = 1;
        
    % if no movement, add to timer
    else
        
        time = time + dt * fac;
        
        % if before timer, relax
        if time < 1.3
            target = 0;
            
        else % if timer, show target
            target = 1;
        end
    end

    set(g, 'xdata', t(i), 'ydata', Vel(i));
    set(ax1, 'xlim', t(i) + [-1 1]);
    
    set(k, 'ydata', [target target])
    set(ax2, 'xlim', t(i) + [-1 1]);
    
    drawnow

end


    
