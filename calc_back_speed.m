clear all; close all; clc

T = 2.5; % desired total duration
A = 50; % desired angular excursion

% v_f = [50 100 150 200]*1.1; % forward speed (deg/s)
v_f = [75 150 225]; % forward speed (deg/s)
T_r = 1; % (s)

T_b = T - T_r - A./v_f;
v_b = A./T_b

