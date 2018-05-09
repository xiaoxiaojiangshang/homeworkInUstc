function [ result ] = imgSearch( src,dim)
%����vlad��ʽ�����������·��src,dim��ʾVLAD����������ά�ȣ�128*k
%����ǣ�ͼ��������*4ά�ľ���ÿһ�ж�Ӧ��ѯ�Ľ��

allFiles = dir(src);
fileNum = length(allFiles);
dim2 = fileNum-2;
vladMatrix = zeros(dim, dim2);
result = zeros(dim2,4);

%% ����dim��ͼ���VLAD��ʽ����������������һ����ľ���
for i= 3: fileNum
    fileName = allFiles(i).name;
    filePath = [src,'/',fileName];
    temp = load(filePath);
    vladMatrix(:,i-2)=temp.newFeat;
end

%% ����õ����������4��ͼ��
for i=1:dim2
    temp = repmat(vladMatrix(:,i),1,dim2);
    distance = sqrt(sum((temp-vladMatrix).^2)); %��kȡ�ýϴ�ʱ����64����ֵ�����
    sortdis = sort(distance);
    for j= 1:4
          result(i,j)=find(distance==sortdis(j));
    end
end
