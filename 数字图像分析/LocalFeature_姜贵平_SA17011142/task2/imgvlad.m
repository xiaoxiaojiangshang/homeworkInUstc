function imgvlad( codebook,src1,src2 )
%  ����codebook����ÿһ��ͼ���vlad��
%  ����src1��ͼ��dsift�ļ��ı���λ�ã�src2�ǵõ���vlad����ŵ�λ��

siftDim=128;
%% ����ǰ��֤��src2���ڣ���Ϊ��
if exist(src2,'dir')==0
    mkdir(src2);
end
allfile1=dir(src2);
for i=3:length(allfile1)
    filepath=[src2,'/',allfile1(i).name];
    delete(filepath);
end

%% ����ÿ��ͼ���VLAD��ʽ��������������
allFiles=dir(src1);
[cb1,cb2]=size(codebook);
for i = 3 : length(allFiles)
    fileName = allFiles(i).name;
    if length(fileName) > 5 && strcmp(fileName(end-5 : end), '.dsift') == 1 % find dsift image file
        filepath = [src1, '/', fileName];
        fid = fopen(filepath,'rb');
        featNumTemp = fread(fid, 1, 'int32'); % �ļ���SIFT��������Ŀ
        SiftFeat = zeros(siftDim, featNumTemp);
        for j = 1 : featNumTemp % �����ȡSIFT����
            SiftFeat(:, j) = fread(fid, siftDim, 'uchar'); %�ȶ���128ά������
            fread(fid, 4, 'float32');
        end
        fclose(fid);
        newFeat = getNewFeat(SiftFeat,codebook,featNumTemp); %����getNewFeat����
        newFeat = newFeat(:); %չ�ɳ���������
        newFeatName=[fileName,'vlad.mat']; 
        newFeatPath= [src2, '/', newFeatName];
        save(newFeatPath,'newFeat'); %����VLAD���
    end
end     
end

%% ����һ��ͼ��Sift��������codebook�õ�������VLAD��featNum��sift�����ĸ���
 function newFeat =getNewFeat(SiftFeat,codebook,featNum)
    [cb1,cb2]=size(codebook);
    newFeat=zeros(cb1,cb2);
    for i =1:featNum
        origfeat=repmat(SiftFeat(:,i),1,cb2);
        distance = sum((origfeat-codebook).^2); 
        mincode = min(distance);
        minindex = find(distance==mincode(1)); %��������ڵ�����������ɶ�������ȡ��һ��
        newFeat(:,minindex)=newFeat(:,minindex) + SiftFeat(:,i) - codebook(:,minindex); %��ʱ��õ�ȫ���������
    end
    newFeat = sign(newFeat).*(abs(newFeat).^0.5) + eps; %power normalization
    newFeat = newFeat./repmat((sqrt(sum(newFeat.^2))),cb1,1); %L2 normalization
end
