clear; clc; close all;

% Jetson Nano 연결
hwobj = jetson('192.168.0.29','digitalcomu','0000');

% 명령 실행
system(hwobj, 'echo Hello World > /tmp/output.txt');

system(hwobj, 'echo Hello World > /tmp/output.txt');
[status, cmdout] = system(hwobj, 'cat /tmp/output.txt');
disp("Command Output:");
disp(cmdout);
