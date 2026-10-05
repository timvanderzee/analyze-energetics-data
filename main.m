clear all; close all; clc
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze'))
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\process'))

Ps = 16;

%% convert US
extract_faslen_and_phi(Ps)

%% momarm
Ps = 16:23;
estimate_momarm(Ps)

%% gravity
get_gravity(Ps);

%% mvc
close all
get_MVC(Ps)

%% convert
convert_c3d_to_mat(Ps)

%% cycle data
close all
get_cycle_data(Ps)

%% get energetics
close all
Ps = [1:8, 10:15];
get_energetics(Ps)

%% analyze - dataset 1
close all
Ps = [1:8, 10:15];
analyze_cycle_data(Ps, 1, 15)

%% analyze - dataset 2
close all
Ps = 16:23;
analyze_cycle_data(Ps, 2, 16, 1)
 
 %% plot
close all
figure(1)
% Ps = [7:8, 10:15];
% Ps = [1:8, 10:15];
Ps = 1:15;
[eff1, vm1] = analyze_energetics(Ps, 1, 15, 0, 1);

%% plot - dataset 2
if ishandle(1), close(1); end
figure(1)
Ps = 16:23;
[Y, vm2] = analyze_energetics(Ps, 2, [], [], [], 'joint-based');

%%
figure(1)
set(gcf, 'units', 'normalized', 'position', [.1 .1 .31 .25])

%% metabolic cost figures
clc
% if ishandle(2), close(2); end; figure(2)
close all
[~, h, p] = make_metabolic_figures(vm2, Y, 2, Ps, []);

%%
figure(1)
set(gcf, 'units', 'normalized', 'position', [.1 .1 .31 .25])

%% velocity plot
vels = [30 60 120 240];
[~, id] = sort(vels);

close all
figure(2)
color = lines(2);

% gcolor = color;
% gcolor([1

% sigs = [-1 1];

for j = 1:2
    if j == 1
        id = 1:4;
    else
        id = 5:8;
    end
    
    vm = abs(vm2);

    subplot(131)
    bar(1:4, mean(vm2(id,:),2), 'facecolor', color(j,:)); hold on 
    errorbar(1:4, mean(vm2(id,:),2), std(vm2(id,:),1,2),'.', 'color', color(j,:)); hold on 
    
    plot(1:4, vm2(id,:), '.-', 'color', [brighten(color(j,:), .3) .2])
    box off
    xticks(1:4)
    xticklabels(vels)
    xlabel('Joint velocity (deg/s)')
    ylabel('Fascicle velocity (mm/s)')
    title('Muscle fascicle velocity')
    
    
    subplot(132)
        plot(vm(id,:), Y(id,:,2), '.-', 'color', [brighten(color(j,:), .3) .2]); hold on
    errorbar(mean(vm(id,:),2), mean(Y(id,:,2),2), std(Y(id,:,2),1,2), std(Y(id,:,2),1,2),std(vm(id,:),1,2),std(vm(id,:),1,2), 'o', ...
        'color', color(j,:),  'markerfacecolor', color(j,:)); hold on 

    box off
    ylim([0 300])
    xlabel('|Fascicle velocity| (mm/s)')
    ylabel('Net metabolic rate (W)')
    title('Metabolic energy cost')
    
    subplot(133)

    plot(vm(id,:), Y(id,:,4), '.-', 'color',[brighten(color(j,:), .3) .2]); hold on
    box off
    
    errorbar(mean(vm(id,:),2), mean(Y(id,:,4),2), std(Y(id,:,4),1,2), std(Y(id,:,4),1,2),std(vm(id,:),1,2),std(vm(id,:),1,2), 'o', ...
        'color', color(j,:),  'markerfacecolor', color(j,:)); hold on 
    yline(0, 'k-')
    xlabel('|Fascicle velocity| (mm/s)')
    ylabel('Mechanical efficiency (%)')
    title('Mechanical efficiency')
end

set(gcf, 'units', 'normalized', 'position', [.1 .1 .31 .25])
%% efficiency figures
% i = 2;

eff = Y(:,:,4);

close all
figure(3)
% rat = make_efficiency_figures(vm1(1:6,:), eff1(1:6,:,:), 1, 1);
make_efficiency_figures(vm2, repmat(eff,1,1,3), 2, 1, Ps, 23)

%% analyze gender and sport effects
make_masterthesis_figures(eff1, eff2)








