function C = codebook( src,k)
%����src�ǰ���ͼ��SIFT�����ļ����ļ��У�
%�����codebook

siftDim=128;

allFiles=dir(src);
fileNum=0; % dsift�ļ���Ŀ
allfeatNum=0; % ����dsift�ܹ���feature��Ŀ

%% ͳ������disft����Ŀ����ֵ��allfeatNum
for i = 3 : length(allFiles)
    fileName = allFiles(i).name;
    if length(fileName) > 5 && strcmp(fileName(end-5 : end), '.dsift') == 1 % find dsift image file
        filepath = [src, '/', fileName];
        fid = fopen(filepath,'rb');
        featNumTemp = fread(fid, 1, 'int32'); % �ļ���SIFT��������Ŀ
        allfeatNum =allfeatNum + featNumTemp;
        fileNum=fileNum+1;
        fclose(fid);
    end
end     

%% �ֱ����ÿһ��ͼ���sift���������ϳɴ�ľ��󣬼�ΪallFeat
allFeat=zeros(siftDim,allfeatNum);
lastFeatNum=1;

for i = 3 : length(allFiles)
    fileName = allFiles(i).name;
    if length(fileName) > 5 && strcmp(fileName(end-5 : end), '.dsift') == 1 % find dsift image file
        filepath = [src, '/', fileName];
        fid = fopen(filepath,'rb');
        featNum = fread(fid, 1, 'int32'); % �ļ���SIFT��������Ŀ
        for j = lastFeatNum : lastFeatNum + featNum-1 % �����ȡSIFT����
            allFeat(:, j) = fread(fid, siftDim, 'uchar'); %�ȶ���128ά������
            fread(fid,4,'float32');
        end
        fclose(fid);
        lastFeatNum=lastFeatNum+featNum;
    end
end

%% ��kmeans����õ�codebook,������
opts = statset('Display','final','MaxIter',200); % can set the maxiter
[idx, C] = kmeans(allFeat',k,'Options',opts);
C=C';
save('codebook.mat','C');
