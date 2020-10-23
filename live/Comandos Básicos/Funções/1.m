function p3dx = paracima(p3dx,d)
% Fun��o ''Para cima''
%   A fun��o ''Para cima'' faz o rob� avan�ar uma determinada dist�ncia ''d'' para cima em um plano
%   xy.
if P.pFlag.comando ~= 2
    if p3dx.pFlag.comando == 0
        p3dx.pPos.Xd(1:2) = [ p3dx.pPos.X(1); p3dx.pPos.X(2) + d ];
        p3dx.pFlag.comando = 1;
    end
    % Posi��o desejada:
    % p3dx.pPos.Xd
    beta = pi/2 - abs(p3dx.pPos.X(6));
    while abs(beta) > pi
        if beta > 0
            beta = beta - 2*pi;
        else
            beta = beta + 2*pi;
        end
    end
    if beta > 0.1
        p3dx.pSC.Ud = [0; 0.2];
    elseif beta < -0.1
        p3dx.pSC.Ud = [0; -0.2];
    elseif norm(p3dx.pPos.Xd(1:2) - p3dx.pPos.X(1:2)) > 0.1
        p3dx.pSC.Ud = [0.5; 0];
    else
        p3dx.pSC.Ud = [0; 0];
        p3dx.pFlag.comando = 2;
    end
end
end

