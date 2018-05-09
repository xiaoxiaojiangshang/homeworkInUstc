function g=computeG(I,sigma)

I = BoundMirrorExpand(I); 
gausFilter = fspecial('gaussian',15, sigma);
X=conv2(I,gausFilter,'same');
[Ix,Iy]=gradient(X);
g=1./(1+Ix.^2+Iy.^2);