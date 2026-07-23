clear all; close all; clc

T = 2.5; % desired total duration
A = 60; % desired angular excursion

% Tflip = .1; % mandatory flip time

% v_f = [50 100 150 200]*1.1; % forward speed (deg/s)
v_f = [60 120 180 240]; % forward speed (deg/s)
T_r = 1; % (s)

T_b = T - (T_r + Tflip) - A./v_f;
v_b = A./T_b

