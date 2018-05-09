function [hxx,hyy]=secondDerivative(I)

hxx=zeros(size(I));
hyy=zeros(size(I));
for jColumn=1:size(I,2)
  for iRow =2:size(I,1)-1    
        hxx(iRow,jColumn)= I(iRow+1,jColumn)+ I(iRow-1,jColumn)-2* I(iRow,jColumn);
  end
end
for iRow=1:size(I,1) 
  for jColumn =2:size(I,2)-1   
        hyy(iRow,jColumn)= I(iRow,jColumn+1)+ I(iRow,jColumn-1)-2* I(iRow,jColumn);
  end
end
    
    
