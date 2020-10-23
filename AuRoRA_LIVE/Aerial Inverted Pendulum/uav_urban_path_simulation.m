%% Simula��o do planejamento de trajet�ria para bambol�s (wayposes)
% - Implementar seguimento de caminho
% - Destorcer curva para proteger bambol�s passados

% Boas pr�ticas
close all
clear
clc

% CONTROLAR TEMPO TOTAL DE SIMULA��O: (min = 100s)
T = 120;

try
    fclose(instrfindall);
    
    % Rotina para buscar pasta raiz
    PastaAtual = pwd;
    PastaRaiz = 'AuRoRA';
    cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
    addpath(genpath(pwd))
    
    disp('Diret�rio raiz e caminho bem definidos!')
    
catch
    disp('Diret�rio raiz errado!')
end

% =========================================================================
% Defini��o da cena:
figure(1)
axis([-3 4 -4 3 0 3])
view(-72.90,19.80)
grid on

%Diametro do drone real
dD = 0.63; 

% Bambol�s:
b1 =[1;1;1]; n1 = [-1;-0.5;1]; 
v1 = [1;0;1];       u1 = [0;1;0.5];


b2 = [2;0.1;1];     n2 = [-1;-1;1].*-0.25;
v2 = [0.5;0;0.5];   u2 = [0;0.5;0.5];

b3 = [-2;-2;1.5];   n3 = [1;0;0];
v3 = [0;-1;0];      u3 = [0;0;1];


% Conjunto dos bambol�s:
Bmb = [b1,b2,b3]; Nb = [n1,n2,n3];
Vb = [v1,v2,v3];  Ub = [u1,u2,u3];

%% Plots ==================================================================
% Pontos:
ps = [0;0;0]; % ponto inicial
CB = [];

for i = 1:size(Nb,2)
    if i>1
        ControlPoints = [pfd,pfd-2*dD.*n];
        CB = [CB, DBezierCurve(ControlPoints)];
             
        ps =pf-sign(pf).*dD.*n;        
    end
    
    pf = Bmb(:,i);
    n  = Nb(:,i);
    V = Vb(:,i)/norm(Vb(:,i));
    U = Ub(:,i)/norm(Ub(:,i));

    % Deslocamento do ponto:
    pfd = pf + dD.*n; % ponto final deslocado por seguran�a

    dp = pfd-ps; % ponto inicial ao ponto deslocado

    % Defini��o Retas:
    t = -1.5:0.1:1.5;
    L = t.*n; % passa pelo bambol�
    R = t.*dp; % do drone ao bambol�
    z = t.*cross(R,L)+pfd; % normal ao plano

    % Ponto de controle:
    idx = find(abs(n)==max(abs(n)));
    pc = pfd + n.*dD;

    % Desenho dos pontos e retas ==========================================
    % Ponto inicial:                  (PRETO)
    hold on
    plot3(ps(1),ps(2),ps(3),'ko')
    hold on
    plot3(ps(1),ps(2),ps(3),'k*')

    % Ponto final:                  (VERMELHO)
    hold on
    plot3(pf(1),pf(2),pf(3),'ro')
    hold on
    plot3(pf(1),pf(2),pf(3),'r*')


    % Ponto final deslocado:        (VERMELHO)
    hold on
    plot3(pfd(1),pfd(2),pfd(3),'ro')
    hold on
    plot3(pfd(1),pfd(2),pfd(3),'r*')

    % Ponto de controle:              (AZUL)
    hold on
    plot3(pc(1),pc(2),pc(3),'b*')
    hold on
    plot3(pc(1),pc(2),pc(3),'bo')

    % Normal ao bambol�:
    hold on
    plot3(L(1,:)+pfd(1),L(2,:)+pfd(2),L(3,:)+pfd(3),'b-.','LineWidth',1)

    % Do drone ao bambol�:
    hold on
    plot3([pfd(1) ps(1)],[pfd(2) ps(2)],[pfd(3) ps(3)],'r:.','LineWidth',1.2)

    % Bambol� 1: 
    u = 0:0.01:2*pi;
    XB = pf(1) +0.63.*cos(u).*V(1) +0.63*sin(u).*U(1);
    YB = pf(2) +0.63.*cos(u).*V(2) +0.63*sin(u).*U(2);
    ZB = pf(3) +0.63.*cos(u).*V(3) +0.63*sin(u).*U(3);
    hold on
    plot3(XB,YB,ZB,'LineWidth',2)
    grid on

    % Calcular e desenhar curva de B�zier:
    ControlPoints = [ps,pc,pfd];
    CB = [CB, DBezierCurve(ControlPoints)];

    % Pontos de Controle:
    hold on
    plot3(ControlPoints(1,:),ControlPoints(2,:),...
          ControlPoints(3,:),'r:.','LineWidth',1.2)
      
    if i==size(Nb,2)
        ControlPoints = [pfd,pfd-2*dD.*n];
        CB = [CB, DBezierCurve(ControlPoints)];
    end
end

hold on
plot3(CB(1,:),CB(2,:),CB(3,:),'b--','LineWidth',2.5)
%% Simula��o ==============================================================
A = ArDrone;

A.pPos.X = zeros(12,1);
XX = [];
flag1=1;
tmax = T; % Tempo Simula��o em segundos
X = zeros(1,19); % Dados correntes da simula��o
ControlPoints = [];
ps = [0;0;0]; % ponto inicial

t = tic;
tc = tic;
tp = tic;
TT = 0;

while toc(t) < tmax
    if toc(tc) > 1/30
        tc = tic;
        tt = toc(t);
        TT = (tt/tmax);
        itT = floor(size(CB,2)*TT)+1;     
        
        clc
        fprintf('Calculando: %0.2g%% \n',TT*100);
        
        A.pPos.Xd(1) = CB(1,itT);  
        A.pPos.Xd(2) = CB(2,itT);
        A.pPos.Xd(3) = CB(3,itT);

        %             12        12      1
        XX = [XX [A.pPos.Xd; A.pPos.X; tt]];

        % Controlador
        A.rGetSensorData
        A = cUnderActuatedController(A);        
        A.rSendControlSignals;
    end
end

clc
disp('Calculado!')
disp('Desenhando cena...')
disp('Pronto para reproduzir.')
%% Resimulando ============================================================
% disp('Reproduzindo simula��o...')
% hold on
% plot3(XX(13,:),XX(14,:),XX(15,:),'g-','LineWidth',2)
% grid on
% for tr = 1:5:size(XX,2)
%     A.pPos.X = XX([13:24],tr);
%     
%     A.mCADplot;
%     drawnow
% end
% =========================================================================


