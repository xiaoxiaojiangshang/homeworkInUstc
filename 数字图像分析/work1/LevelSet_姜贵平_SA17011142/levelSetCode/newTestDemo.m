%%%%%%%%
%  本程序是主要基于‘Active Contours Without Edges’的实现代码，主要不同的如下
% delta H的实现(secondDerivative.m)，高斯平滑g的实现(computeG.m)，div（g*delta()/|delta|）的实现。
% 相比较原来的程序，能够成功将双细胞风格，但是血管效果不好，尝试各种高斯平滑也很难解决。
%%%%%%%

clear;
close all;
clc;
Img=imread('three.bmp');
% Img=imread('twoCells.bmp');
%  Img=imread('vessel.bmp');

U=Img(:,:,1);
I=double(U);

% get the size
[nrow,ncol] =size(U);

%%% init phi
alpha=3;
phi_0=alpha*ones(size(U));
phi_0(5:nrow-5, 5:ncol-5)=-alpha;
figure; mesh(phi_0); title('Signed Distance Function')
%%%

%%%% parameters
delta_t=5; %time step
mu = 0.04;% update_para
nu = 1.5; % areaTerm coefficient
lambda=5; % legthTerm coefficient
epsilon=1.5; %used in Dirac function
%%%%

sigma=1.5;
g=computeG(I,sigma);
[gx,gy]=gradient(g);


% iteration should begin from here
phi=phi_0;
figure(2);
imagesc(uint8(I));colormap(gray)
hold on;
plotLevelSet(phi,0,'r');

numIter = 1;
for k=1:1000
    phi = newRevolution(I, phi,g,gx, gy, mu, nu, lambda, delta_t, epsilon, numIter);   % update level set function
    if mod(k,4)==0
        pause(0.05);
        figure(2);
        imagesc(uint8(I));colormap(gray)
        hold on;
        plotLevelSet(phi,0,'r');
    end
end
