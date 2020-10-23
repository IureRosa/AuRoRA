% Inicializa vari�veis
function mInit(obj)
obj.pPos.X    = zeros(12,1); % posi��o inicial dos rob�s [x1 y1 z1 phi1 theta1 psi1 x2 y2 z2 phi2 theta2 psi2]
% obj.pPos.X    = zeros(4,1);  % posi��o dos rob�s [x1 y1 x2 y2]
obj.pPos.dX   = zeros(4,1);  % velocidades dos rob�s [dx1 dy1 dx2 dy2]
obj.pPos.Xr   = zeros(4,1);  % posi��o dos rob�s [x1 y1 x2 y2]
obj.pPos.dXr  = zeros(4,1);  % velocidades de refer�ncia dos rob�s [dxr1 dyr1 dxr2 dyr2]

obj.pPos.Q    = zeros(4,1);  % vari�veis da forma��o [xf yf rof alfaf]
obj.pPos.Qd   = zeros(4,1);  % forma��o desejada
obj.pPos.dQd  = zeros(4,1);  % derivada da forma��o desejada
obj.pPos.Qtil = zeros(4,1);  % erro de forma��o
obj.pPos.dQr  = zeros(4,1);  % forma��o de refer�ncia

obj.pSC.Ur = zeros(4,1);     % sinal de controle [u1 w1 u2 w2];
obj.pSC.Ud = zeros(4,1);     % sinal de controle [u1 w1 u2 w2];


% Gain
% obj.pPar.K1 = 1*diag([.23 .23 0.6 0.5]);          % ganho controlador cinem�tico
% obj.pPar.K2 = 1*diag([.5 .5 .5 .5]);              % ganho controlador cinem�tico

% ganho trajetoria - teste marcos
obj.pPar.K1 = 1*diag([.4 .4 0.6 1.5]);          % ganho controlador cinem�tico
obj.pPar.K2 = 1*diag([.5 .5 .5 .5]);              % ganho controlador cinem�tico

end

