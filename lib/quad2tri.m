function [varargout]=quad2tri(varargin)

% function [Ft,Vt,C]=quad2tri(Fq,Vq,triType,C)
% ------------------------------------------------------------------------
% This function converts quadrilateral patch data to triangular patch data.
% 
% 
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
% 
% 2014/11/03
%------------------------------------------------------------------------


%% Parse input
switch nargin
    case 2
        Fq=varargin{1};
        Vq=varargin{2};
        triType=[];
        C=[];
    case 3        
        Fq=varargin{1};
        Vq=varargin{2};
        triType=varargin{3};
        C=[];
    case 4        
        Fq=varargin{1};
        Vq=varargin{2};
        triType=varargin{3};
        C=varargin{4};        
    otherwise
        error('False number of input arguments');
end

if isempty(triType)
    triType='f';
end

%%
switch triType
    case 'b' %backward slash
        Ft=[Fq(:,[1 2 3]);Fq(:,[3 4 1]);];
        Vt=Vq;             
    case 'f' %Forward slash
        Ft=[Fq(:,[1 2 4]);Fq(:,[2 3 4]);];        
        Vt=Vq;        
    case 'x' %Cross type
        Vm=zeros(size(Fq,1),size(Vq,2));
        for q=1:1:size(Vq,2)
            X=Vq(:,q);
            FX=X(Fq);
            if size(Fq,1)==1 %Treat special case of single face
                FX=FX';
            end
            Vm(:,q)=mean(FX,2);
        end
        %Join point sets
        Vt=[Vq;Vm];
        
        indVm=(size(Vq,1)+1):size(Vt,1);
        %Create faces
        Ft=[Fq(:,1) Fq(:,2) indVm(:);...
            Fq(:,2) Fq(:,3) indVm(:);...
            Fq(:,3) Fq(:,4) indVm(:);...
            Fq(:,4) Fq(:,1) indVm(:)];
end

%Color vector now assumes all schemes allow for simply copying of the color
%information
if ~isempty(C)
    diffFac=size(Ft,1)./size(Fq,1); %An integer (e.g. 2 or 4)
    C=repmat(C,[diffFac,1]); %Copy color
end
    

varargout{1}=Ft;
varargout{2}=Vt;
varargout{3}=C;

end


