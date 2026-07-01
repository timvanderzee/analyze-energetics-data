% clear all; close all; clc

titles = {'Activation', 'Velocity', 'Torque'};
ylabs = {'% max', 'deg/s', 'N-m'};

for ks = 1:9
    figure(ks)
    set(gcf, 'name', Sdata(1).conds{ks+1})
    set(gcf, 'units', 'normalized', 'position', [.3 .3 .6 .6])
    
    for session = 1:6
         tlin = linspace(0,Tcycle(ks,session), 500);
        
        subplot(311)
        plot(tlin, Ameans(:,ks, session)); hold on
        
        subplot(312)
        plot(tlin, vmeans(:,ks, session)); hold on
        
        subplot(313)
        plot(tlin, Tmeans(:,ks, session)); hold on
    end
    
    for k = 1:3
        subplot(3,1,k);
        box off
        xlabel('Time (s)');
        ylabel(ylabs{k})
        title(titles{k})
    end
end