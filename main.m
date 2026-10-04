clear all; close all; clc
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze'))
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\process'))

Ps = 23;

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
analyze_cycle_data(Ps, 2, 23)
 
 %% plot
close all
figure(1)
% Ps = [7:8, 10:15];
% Ps = [1:8, 10:15];
Ps = 1:15;
[eff1, vm1] = analyze_energetics(Ps, 1, 15, 0, 1);

%%
figure(1)
Ps = 16:23;
[Y, vm2] = analyze_energetics(Ps, 2, 23, [], [], 'joint-based');

%% metabolic cost figures
if ishandle(2), close(2); end; figure(2)
make_metabolic_figures(vm2, Y, 2, Ps, 23);

%% efficiency figures
% i = 2;

% close all
figure(3)
% rat = make_efficiency_figures(vm1(1:6,:), eff1(1:6,:,:), 1, 1);
make_efficiency_figures(vm2, repmat(Pmet',1,1,3), 2, 1, Ps, 23)

%% analyze gender and sport effects
make_masterthesis_figures(eff1, eff2)








