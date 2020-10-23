function p3dx = parabaixo(p3dx,d)
% Fun��o ''Para baixo''
% A fun��o ''Para baixo'' faz o rob� avan�ar uma determinada dist�ncia ''d'' para baixo em um plano
% xy.
p3dx.rGetSensorData;
p3dx.pPos.Xd(1:2) = [ p3dx.pPos.X(1) ; p3dx.pPos.X(2) - d ];
Ta = tic;
Tp = tic;
while true
if toc(Ta) > 0.1
    Ta = tic;
%     T_Atual = toc(T);

%   Posi��o desejada
    % Posi��o desejada:
    % p3dx.pPos.Xd
    beta = - pi/2 - p3dx.pPos.X(6);
    while abs(beta) > pi
        if beta > 0
            beta = beta - 2*pi;
        else
            beta = beta + 2*pi;
        end
    end
    if beta > 0.1
        p3dx.pSC.Ud = [0; 1];
    elseif beta < -0.1
        p3dx.pSC.Ud = [0; -1];
    elseif norm(p3dx.pPos.Xd(1:2) - p3dx.pPos.X(1:2)) > 0.08
        p3dx.pSC.Ud = [0.4; 0];
    else
        p3dx.pSC.Ud = [0; 0];
        break
    end
    
%   Coletando sinais de posi��o e velocidade do rob�
%   Odometria
    p3dx.rGetSensorData;
    
%   Sinal de controle 
%   P.pSC.Ud = [Linear; Angular];
% P.pSC.Ud = [ 1; 0.5];

%   Enviar Comandos para o Pioneer
    p3dx.rSendControlSignals;
    
%   Seguran�a #2
    p3dx.pSC.Ud = [0; 0];
end
if toc(Tp) > 0.2
    Tp = tic;
    
    p3dx.mCADdel;
    
    p3dx.mCADplot(1,'r')
    
    drawnow
end
end
end

