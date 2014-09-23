function [F,V]=logic2isosurface(L,controlPar)

%%

%%

%% GET CONTROL PARAMETERS

if isfield(controlPar,'kernelSize')    
    kernelSize=controlPar.kernelSize;
else %DEFAULT
    kernelSize=3; 
end

if isfield(controlPar,'contourLevel')    
    contourLevel=controlPar.contourLevel;
else %DEFAULT
    contourLevel=0.5; 
end

if isfield(controlPar,'voxelSize')    
    voxelSize=controlPar.voxelSize;   
else %DEFAULT
    voxelSize=[1 1 1];
end

if isfield(controlPar,'capOpt')    
    capOpt=controlPar.capOpt;
else %DEFAULT
    capOpt=1;
end

if isfield(controlPar,'nSub')    
    nSub=controlPar.nSub;
else %DEFAULT
    nSub=[1 1 1];
end

if isfield(controlPar,'kernelType')    
    kernelType=controlPar.kernelType;
else %DEFAULT
    kernelType=1;
end

siz=size(L);

%% SMOOTHEN LOGIC

%Define smoothening kernel
switch kernelType
    case 1 %Simple averaging kernel
        hg=ones(kernelSize,kernelSize,kernelSize);
        hg=hg./sum(hg(:));
    case 2
        hg=gauss_kernel(kernelSize,ndims(L),2,'width');
end

%Convolve logic
L=convn(double(L),hg,'same');

%% CREATE ISO-SURFACE

%Pad with zeros if desired
if capOpt==1
    Lpad=zeros(size(L)+2*kernelSize);
    Lpad(1+kernelSize:siz(1)+kernelSize,1+kernelSize:siz(2)+kernelSize,1+kernelSize:siz(3)+kernelSize)=L;
    L=Lpad;
    siz=size(L);
end

% Get image coordinates
[J,I,K]=meshgrid(1:1:siz(2),1:1:siz(1),1:1:siz(3));
if capOpt==1
    I=I-kernelSize; J=J-kernelSize; K=K-kernelSize; %Correct for padding
end

%Convert to Cartesian coordinates using voxels size if provided
[X,Y,Z]=im2cart(I,J,K,voxelSize);

%Resample mesh and image
nNew=round(siz./nSub);
useRange_I=unique(round(linspace(1,siz(1),nNew(1))));
useRange_J=unique(round(linspace(1,siz(2),nNew(2))));
useRange_K=unique(round(linspace(1,siz(3),nNew(3))));

X_iso=X(useRange_I,useRange_J,useRange_K);
Y_iso=Y(useRange_I,useRange_J,useRange_K);
Z_iso=Z(useRange_I,useRange_J,useRange_K);
L_iso=L(useRange_I,useRange_J,useRange_K);

% X_iso=X(1:nSub(1):end,1:nSub(2):end,1:nSub(3):end);
% Y_iso=Y(1:nSub(1):end,1:nSub(2):end,1:nSub(3):end);
% Z_iso=Z(1:nSub(1):end,1:nSub(2):end,1:nSub(3):end);
% L_iso=L(1:nSub(1):end,1:nSub(2):end,1:nSub(3):end);

%Derive isosurface
[F,V] = isosurface(X_iso,Y_iso,Z_iso,L_iso,contourLevel);
F=F(:,[3 2 1]); %Flip face order so normal is outward

%Derive caps
if capOpt==2
    [Fc,Vc] = isocaps(X_iso,Y_iso,Z_iso,L_iso,contourLevel);
    Fc=Fc(:,[3 2 1]); %Flip face order so normal is outward
    
    %Merge patch data
    F=[F;Fc+size(V,1);];
    V=[V;Vc;];
    [~,ind1,ind2]=unique(pround(V,5),'rows');
    V=V(ind1,:);
    F=ind2(F);
end
