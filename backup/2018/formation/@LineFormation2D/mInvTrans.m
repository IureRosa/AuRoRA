function mInvTrans(obj,par)
% Inverse transformation
%  + ------------------------+      +---------------------+
%  |   [xf yf rhof alfaf]    | ===> |   [x1 y1 x2 y2 ]    |
%  |  Formation variables(Q) |      |  Formation Pose(X)  |
%  +-------------------------+      +---------------------+

% 'par' define a transforma��o com valores:
% >> correntes (c)
% >> desejados (d)

% Caso 'par' n�o seja definida pelo usu�rio, considerar corrente
if nargin<2
    par = 'c';  % current
end

if obj.pPar.Type(1) == 'c'   % centro da forma��o = entre os dois robos
    if par == 'c'
        %  Transforma��o inversa [x1 y1 x2 y2]
        obj.pPos.Xr(1) = obj.pPos.Q(1) - obj.pPos.Q(3)/2*cos(obj.pPos.Q(4));
        obj.pPos.Xr(2) = obj.pPos.Q(2) - obj.pPos.Q(3)/2*sin(obj.pPos.Q(4));
        obj.pPos.Xr(3) = obj.pPos.Q(1) + obj.pPos.Q(3)/2*cos(obj.pPos.Q(4));
        obj.pPos.Xr(4) = obj.pPos.Q(2) + obj.pPos.Q(3)/2*sin(obj.pPos.Q(4));
        
    elseif par == 'd'
        %  Transforma��o inversa [x1 y1 x2 y2]
        obj.pPos.Xd(1) = obj.pPos.Qd(1) - obj.pPos.Qd(3)/2*cos(obj.pPos.Qd(4));
        obj.pPos.Xd(2) = obj.pPos.Qd(2) - obj.pPos.Qd(3)/2*sin(obj.pPos.Qd(4));
        obj.pPos.Xd(3) = obj.pPos.Qd(1) + obj.pPos.Qd(3)/2*cos(obj.pPos.Qd(4));
        obj.pPos.Xd(4) = obj.pPos.Qd(2) + obj.pPos.Qd(3)/2*sin(obj.pPos.Qd(4));
        
        obj.pPos.Xd = obj.pPos.Xd';
    end
    
elseif obj.pPar.Type(1) == 'r'   % centro da forma��o = robo
    
    if par == 'c'
        % Posi��o
        % Transforma��o inversa [x1 y1 x2 y2]
        obj.pPos.Xr(1) = obj.pPos.Q(1);
        obj.pPos.Xr(2) = obj.pPos.Q(2);
        obj.pPos.Xr(3) = obj.pPos.Q(1) + obj.pPos.Q(3)*cos(obj.pPos.Q(4));
        obj.pPos.Xr(4) = obj.pPos.Q(2) + obj.pPos.Q(3)*sin(obj.pPos.Q(4));
        
    elseif par == 'd'
        % Transforma��o inversa [x1 y1 x2 y2]
        obj.pPos.Xd(1) = obj.pPos.Qd(1);
        obj.pPos.Xd(2) = obj.pPos.Qd(2);
        obj.pPos.Xd(3) = obj.pPos.Qd(1) + obj.pPos.Qd(3)*cos(obj.pPos.Qd(4));
        obj.pPos.Xd(4) = obj.pPos.Qd(2) + obj.pPos.Qd(3)*sin(obj.pPos.Qd(4));
        
        obj.pPos.Xd = obj.pPos.Xd';
    end
    
else
    disp('Formation type not found.');
end
end