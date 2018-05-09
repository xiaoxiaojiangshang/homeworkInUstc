clear;close all;clc;
tic
%%accFlag 决定是否使用kmeans加速，true代表加速。
accFlag=false;
siftMatch(1,'./test images/ukbench00000.jpg','./test images/ukbench00003.jpg',accFlag); %0.3519
% siftMatch(2,'./test images/ukbench00012.jpg','./test images/ukbench00013.jpg');%0.3209
% siftMatch(3,'./test images/ukbench00052.jpg','./test images/ukbench00054.jpg');%0.1809
% siftMatch(4,'./test images/ukbench00080.jpg','./test images/ukbench00082.jpg');%0.2585
% siftMatch(5,'./test images/ukbench02165.jpg','./test images/ukbench02167.jpg'); %0.3508

toc