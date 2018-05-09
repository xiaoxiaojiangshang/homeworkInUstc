function C = codebook( src,k)
%输入src是包含图像SIFT特征文件的文件夹，
%输出是codebook

siftDim=128;

allFiles=dir(src);
fileNum=0; % dsift文件数目
allfeatNum=0; % 所有dsift总共的feature数目

%% 统计所有disft的数目，赋值给allfeatNum
for i = 3 : length(allFiles)
    fileName = allFiles(i).name;
    if length(fileName) > 5 && strcmp(fileName(end-5 : end), '.dsift') == 1 % find dsift image file
        filepath = [src, '/', fileName];
        fid = fopen(filepath,'rb');
        featNumTemp = fread(fid, 1, 'int32'); % 文件中SIFT特征的数目
        allfeatNum =allfeatNum + featNumTemp;
        fileNum=fileNum+1;
        fclose(fid);
    end
end     

%% 分别读入每一副图像的sift特征，整合成大的矩阵，记为allFeat
allFeat=zeros(siftDim,allfeatNum);
lastFeatNum=1;

for i = 3 : length(allFiles)
    fileName = allFiles(i).name;
    if length(fileName) > 5 && strcmp(fileName(end-5 : end), '.dsift') == 1 % find dsift image file
        filepath = [src, '/', fileName];
        fid = fopen(filepath,'rb');
        featNum = fread(fid, 1, 'int32'); % 文件中SIFT特征的数目
        for j = lastFeatNum : lastFeatNum + featNum-1 % 逐个读取SIFT特征
            allFeat(:, j) = fread(fid, siftDim, 'uchar'); %先读入128维描述子
            fread(fid,4,'float32');
        end
        fclose(fid);
        lastFeatNum=lastFeatNum+featNum;
    end
end

%% 由kmeans计算得到codebook,并保存
opts = statset('Display','final','MaxIter',200); % can set the maxiter
[idx, C] = kmeans(allFeat',k,'Options',opts);
C=C';
save('codebook.mat','C');
