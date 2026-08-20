clear all; close all; clc
Ps = 19;

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
get_energetics(Ps)

%% analyze
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze')
Ps = 16:19;
analyze_cycle_data(Ps)

%% plot
Ps = 16:19;
close all
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze')
 analyze_energetics_dataset2(Ps)