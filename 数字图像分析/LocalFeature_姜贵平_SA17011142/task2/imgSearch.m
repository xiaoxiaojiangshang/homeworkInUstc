function [ result ] = imgSearch( src,dim)
%输入vlad方式保存的特征的路径src,dim表示VLAD表达的特征的维度，128*k
%输出是（图像数量）*4维的矩阵，每一行对应查询的结果

allFiles = dir(src);
fileNum = length(allFiles);
dim2 = fileNum-2;
vladMatrix = zeros(dim, dim2);
result = zeros(dim2,4);

%% 导入dim张图像的VLAD方式的特征向量，构成一个大的矩阵
for i= 3: fileNum
    fileName = allFiles(i).name;
    filePath = [src,'/',fileName];
    temp = load(filePath);
    vladMatrix(:,i-2)=temp.newFeat;
end

%% 计算得到距离最近的4张图像
for i=1:dim2
    temp = repmat(vladMatrix(:,i),1,dim2);
    distance = sqrt(sum((temp-vladMatrix).^2)); %当k取得较大时（如64）该值会溢出
    sortdis = sort(distance);
    for j= 1:4
          result(i,j)=find(distance==sortdis(j));
    end
end
