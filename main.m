clear all; close all; clc
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze'))
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\process'))

Ps = 7;

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
Ps = [7:8, 10:19];
get_energetics(Ps)

%% analyze - dataset 1
Ps = [7:8, 10:15];
analyze_cycle_data(Ps, 1)

%% analyze - dataset 2
Ps = 16:19;
analyze_cycle_data(Ps, 2)
 
 %% plot - dataset 1
if ishandle(1), close(1); end
if ishandle(2), close(2); end

Ps = [7:8, 10:15];
analyze_energetics(Ps)

%% plot - dataset 2
Ps = 16:19;
% close all
figure(3)
analyze_energetics_dataset2(Ps)