function p3dx = manterposicao(p3dx, d)
%Fun��o ''Manter Posi��o'

p3dx.rGetSensorData;
p3dx.pPos.Xd(1:2) = [ p3dx.pPos.X(1) + d ; p3dx.pPos.X(2) ];
Ta = tic;
Tp = tic;
while true
if toc(Ta) > 0.1
    Ta = tic;
%     T_Atual = toc(T);

p3dx.pPos.Xd(1:2) = p3dx.pPos.X(1:2);
if p3dx.pPos.Xd(1:2) == p3dx.pPos.X(1:2)
     p3dx.pSC.Ud = [0; 0];
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
end
if toc(Tp) > 0.2
    Tp = tic;
    
    p3dx.mCADdel;
    
    p3dx.mCADplot(1,'r')
    
    drawnow
end
end

