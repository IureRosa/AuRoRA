clearvars
close all
clc

try
    fclose(instrfindall);
catch
end
%%

J = JoyControl;
P = Pioneer3DX; % P�oneer3DX Experimento
P.pPar.a = 0;
P.pPar.alpha = 0;

%%
% Temporizadores
Ta = tic;
Tp = tic;

figure
grid on
hold on
axis([-2 2 -2 2])
axis equal
%%
% while J.pFlag ~= 0 && Condi��o
% Condi��o ser� o erro de posi��o do rob� (Xd - X)
d= 1 ;
P = parabaixo(P,d);


%%






