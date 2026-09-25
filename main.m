clear all; close all; clc
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze'))
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\process'))

Ps = 17;

%% convert US
extract_faslen_and_phi(Ps)

%% momarm
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
Ps = 12;
get_energetics(Ps)

%% analyze - dataset 1
close all
Ps = [1:8, 10:15];
analyze_cycle_data(Ps, 1, 15)

%% analyze - dataset 2
close all
Ps = 16:22;
analyze_cycle_data(Ps, 2, 17)
 
 %% plot
close all
figure(1)
% Ps = [7:8, 10:15];
Ps = [7:8, 10:15];
[eff1, vm1] = analyze_energetics(Ps, 1, 12, 0, 1);

%%
figure(2)
Ps = 16:22;
[eff2, vm2] = analyze_energetics(Ps, 2, 17);

%% efficiency figures
% i = 2;

close all
figure(1)
rat = make_efficiency_figures(vm1(1:6,:), eff1(1:6,:,:), 1, 1);
% make_efficiency_figures(vm2, eff2(:,:,:), 2)


