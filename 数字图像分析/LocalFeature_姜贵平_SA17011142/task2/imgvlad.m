function imgvlad( codebook,src1,src2 )
%  根据codebook计算每一幅图像的vlad表达，
%  输入src1是图像dsift文件的保存位置，src2是得到的vlad表达存放的位置

siftDim=128;
%% 计算前保证，src2存在，且为空
if exist(src2,'dir')==0
    mkdir(src2);
end
allfile1=dir(src2);
for i=3:length(allfile1)
    filepath=[src2,'/',allfile1(i).name];
    delete(filepath);
end

%% 计算每幅图像的VLAD方式的特征表达，并保存
allFiles=dir(src1);
[cb1,cb2]=size(codebook);
for i = 3 : length(allFiles)
    fileName = allFiles(i).name;
    if length(fileName) > 5 && strcmp(fileName(end-5 : end), '.dsift') == 1 % find dsift image file
        filepath = [src1, '/', fileName];
        fid = fopen(filepath,'rb');
        featNumTemp = fread(fid, 1, 'int32'); % 文件中SIFT特征的数目
        SiftFeat = zeros(siftDim, featNumTemp);
        for j = 1 : featNumTemp % 逐个读取SIFT特征
            SiftFeat(:, j) = fread(fid, siftDim, 'uchar'); %先读入128维描述子
            fread(fid, 4, 'float32');
        end
        fclose(fid);
        newFeat = getNewFeat(SiftFeat,codebook,featNumTemp); %调用getNewFeat函数
        newFeat = newFeat(:); %展成长的列向量
        newFeatName=[fileName,'vlad.mat']; 
        newFeatPath= [src2, '/', newFeatName];
        save(newFeatPath,'newFeat'); %保存VLAD表达
    end
end     
end

%% 根据一幅图的Sift特征，由codebook得到特征的VLAD表达，featNum是sift特征的个数
 function newFeat =getNewFeat(SiftFeat,codebook,featNum)
    [cb1,cb2]=size(codebook);
    newFeat=zeros(cb1,cb2);
    for i =1:featNum
        origfeat=repmat(SiftFeat(:,i),1,cb2);
        distance = sum((origfeat-codebook).^2); 
        mincode = min(distance);
        minindex = find(distance==mincode(1)); %计算最近邻的向量，如果由多个结果，取第一个
        newFeat(:,minindex)=newFeat(:,minindex) + SiftFeat(:,i) - codebook(:,minindex); %有时会得到全零的列向量
    end
    newFeat = sign(newFeat).*(abs(newFeat).^0.5) + eps; %power normalization
    newFeat = newFeat./repmat((sqrt(sum(newFeat.^2))),cb1,1); %L2 normalization
end
