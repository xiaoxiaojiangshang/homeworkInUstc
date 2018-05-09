function siftMatch(fignum,src_1,src_2,accFlag)
%fignum represent the figure number when all this match is done
%src_1 and src_2 give the path of pictures that will be matched

% Load two images and their SIFT features
ext1 = '.dsift'; %'.vsift_640'; % extension name of SIFT file
ext2 = '.dsift'; %'.vsift_640'; % extension name of SIFT file
siftDim = 128;

% load image
im_1 = imread(src_1);
im_2 = imread(src_2);

%load SIFT feature
% SIFT
% feature文件格式：binary格式，开头四个字节（int）为特征数目，后面逐个为SIFT特征结构体，每个SIFT特征包含128D的描述子（128个字节）
% 和 [x, y, scale, orientation]的16字节的位置、尺度和主方向信息（float）

featPath_1 = [src_1, ext1];
featPath_2 = [src_2, ext2];

fid_1 = fopen(featPath_1, 'rb');
featNum_1 = fread(fid_1, 1, 'int32'); % 文件中SIFT特征的数目
SiftFeat_1 = zeros(siftDim, featNum_1);
paraFeat_1 = zeros(4, featNum_1);
for i = 1 : featNum_1 % 逐个读取SIFT特征
    SiftFeat_1(:, i) = fread(fid_1, siftDim, 'uchar'); %先读入128维描述子
    paraFeat_1(:, i) = fread(fid_1, 4, 'float32');     %再读入[x, y, scale, orientation]信息
end
fclose(fid_1);

fid_2 = fopen(featPath_2, 'rb');
featNum_2 = fread(fid_2, 1, 'int32'); % 文件中SIFT特征的数目
SiftFeat_2 = zeros(siftDim, featNum_2);
paraFeat_2 = zeros(4, featNum_2);
for i = 1 : featNum_2 % 逐个读取SIFT特征
    SiftFeat_2(:, i) = fread(fid_2, siftDim, 'uchar'); %先读入128维描述子
    paraFeat_2(:, i) = fread(fid_2, 4, 'float32');     %再读入[x, y, scale, orientation]信息
end
fclose(fid_2);

% normalization
%.操作是相应的位操作。
SiftFeat_1 = SiftFeat_1 ./ repmat(sqrt(sum(SiftFeat_1.^2)), size(SiftFeat_1, 1), 1);
SiftFeat_2 = SiftFeat_2 ./ repmat(sqrt(sum(SiftFeat_2.^2)), size(SiftFeat_2, 1), 1);

% find the matched features
ratio = 0.8; % the ratio of the nearest feature distanec to the second one
index = 1; %
Result = zeros(2,featNum_1); % Result(1,i) and Result(2,i) are indexes of matched features in two pictures

if (accFlag)
    Result=kmeansAccelerate(SiftFeat_1,SiftFeat_2);
else
    for i = 1:featNum_1
        sup_siftfeat1 = repmat(SiftFeat_1(:,i), 1, featNum_2);
        Distance = sum((sup_siftfeat1-SiftFeat_2).^2);
        [mindist,x] = min(Distance); %
        if(mindist<0.15)  % this is just a try to get less matched result
            temp = Distance < ((1/ratio^2)*mindist); % if the distance break the ratio rule, make it 1, else 0;
            if(sum(temp)==1)
                Result(:,index)=[i;x];
                index=index+1;
            end
        end
    end
end
% show the matched results in one picture
[row, col, ~] = size(im_1);
[r2, c2, ~] = size(im_2);
imgBig = 255 * ones(max(row, r2), col + c2, 3);
imgBig(1 : row, 1 : col, :) = im_1;
imgBig(1 : r2, col + 1 : end, :) = im_2; %% 将两幅图像拼成了一副大图像，左右排列
paraFeat_2(1, :) = paraFeat_2(1, :) + col; % 第二幅图像中的SIFT feature的列坐标要修改，亦即x坐标，第一行所有列

figure(fignum); imshow(uint8(imgBig)); axis on;
hold on;

x=find(Result(1,:)>0);

for i=1:size(x,2)
    index1 = Result(1,i);
    index2 = Result(2,i);
    c1=paraFeat_1(1:2,index1);
    c2=paraFeat_2(1:2,index2);
    plot([c1(1),c2(1)],[c1(2),c2(2)]);
end