clear;
clc;
tic

%% 计算codebook
src='./test images'; %
k=16; 
CB  = codebook(src, k);

%% 计算每张图像的VLAD特征
imgvlad(CB,src,'./ImgVLAD');
    
%% 计算按欧氏距离查询的结果
 result= imgSearch('./ImgVLAD',128*k);

%% 计算相关图像数目
dim1=size(result,1); %dim1表示图像的数量
groundtruth = zeros(dim1,4); %groundtruth矩阵
for i = 1:dim1
    a = 4 * (ceil(i/4)-1) + 1;
    groundtruth(i,:) = (a:1:a+3)';
end

score = zeros(dim1,1);

for i = 1: dim1
    index = 0;
    for j = 1:4
        temp = find(groundtruth(i,:)==result(i,j));
        if(size(temp)>0)
            index=index+1;
        end
    end
    score(i)=index;
end
meanscore = mean(score);
bar(1:dim1,score,'c');
title(['查询前四的命中数量(平均',num2str(meanscore),')']);

%%
toc

