%% 
clear all
close all
clc

filename = [pwd '\rawgen\' 'tst.bin'];
type = 'int8';
n = 100;

%% gen
% a = randi(1,n, type);
% b = randi(1,n, type);
a = cos(-2*pi:0.01:2*pi)*n;
b = sin(-2*pi:0.01:2*pi)*n;
signal = complex(a,b);

figure
plot(1:numel(signal), real(signal));
figure
plot(1:numel(signal), imag(signal));
% return
sdrgen(filename, signal, type)
signal = [];
%% get
signal = sdrget(filename, type);
figure
plot(1:numel(signal), real(signal));
figure
plot(1:numel(signal), imag(signal));