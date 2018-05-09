clear;
clc;
tic

%% ����codebook
src='./test images'; %
k=16; 
CB  = codebook(src, k);

%% ����ÿ��ͼ���VLAD����
imgvlad(CB,src,'./ImgVLAD');
    
%% ���㰴ŷ�Ͼ����ѯ�Ľ��
 result= imgSearch('./ImgVLAD',128*k);

%% �������ͼ����Ŀ
dim1=size(result,1); %dim1��ʾͼ�������
groundtruth = zeros(dim1,4); %groundtruth����
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
title(['��ѯǰ�ĵ���������(ƽ��',num2str(meanscore),')']);

%%
toc

