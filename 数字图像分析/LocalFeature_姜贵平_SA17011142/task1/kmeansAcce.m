function Result=kmeansAccelerate(SiftFeat_1,SiftFeat_2)
%  SiftFeat_1=SiftFeat_1(:,26);
% SiftFeat_2=SiftFeat_2(:,27);
Result = zeros(2,size(SiftFeat_1,2));  % Result(1,i) and Result(2,i) are indexes of matched features in two pictures
%%%%%
D=8;% 每8维聚类
siftDim = 128;
K=64;
m=16;
ratio=0.8;
%siftFeat_1 聚类
% idx 代表4835个8维数据属于哪类（64类）
% C   代表64个中心（8维）
%iPart 代表分割所在段1:8,9:16 ...
type1s=zeros(m,size(SiftFeat_1,2));
center1s=zeros(m,K,8);
for iPart=1:m
    start=iPart*8-7;
    partData=SiftFeat_1(start:start+7,:);
    [idx,C] = kmeans(partData',K);
    type1s(iPart,:)=idx;
    center1s(iPart,:,:)=C;
end

%siftFeat_2 聚类
type2s=zeros(m,size(SiftFeat_2,2));
center2s=zeros(m,K,8);
for iPart=1:m
    start=iPart*8-7;
    partData=SiftFeat_2(start:start+7,:);
    [idx,C] = kmeans(partData',K);
    type2s(iPart,:)=idx;
    center2s(iPart,:,:)=C;
end

% 16 个distance matrix
distMatrixs=zeros(m,K,K);
for iPart=1:m
 for jCenter=1:K
     sub_center1=repmat(center1s(iPart,jCenter,:),1,K);
     Distance = sum((sub_center1-center2s(iPart,:,:)).^2,3);
     distMatrixs(iPart,jCenter,:)=Distance;
 end
end

index = 1;
for iData = 1:size(SiftFeat_1,2)
% for iData=26:26
    Distance=zeros(size(SiftFeat_2,2),1);
    dataType1=type1s(:,iData);
    for jData=1:size(SiftFeat_2,2)
        dataType2=type2s(:,jData);
        temp=0;
        for iPart=1:m
           temp=temp+distMatrixs(iPart,dataType1(iPart),dataType2(iPart));
        end
        Distance(jData)=temp;
    end     
    [mindist,x] = min(Distance); %
   if(mindist<0.15)  % this is just a try to get less matched result
        temp = Distance < ((1/ratio^2)*mindist); % if the distance break the ratio rule, make it 1, else 0; 
        if(sum(temp)==1)
            Result(:,index)=[iData;x];
            index=index+1;
        end
    end
end

end

 
 
 
 