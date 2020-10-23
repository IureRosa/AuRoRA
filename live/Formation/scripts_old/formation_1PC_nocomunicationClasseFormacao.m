%% CONTROLE DIN�MICO DE FORMA��O DE 2 ROB�S POR ESTRUTURA VIRTUAL
% Programa Original: Marcos Felipe e Wagner Casagrande
% Adapta��o para Matlab : Chacal   e Marcos Felipe
% NERO - 2018

clear all
close all
clc
try
    fclose(instrfindall)
end
%% Configura��o da pasta
PastaAtual = pwd;
PastaRaiz = 'AuRoRa 2018';
% cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))
cd(PastaAtual)

%% Inicializa��o de classes

n = 2; %Numero de rob�s

for ii=1:n
    
    P{ii} = Pioneer3DX(ii);
    P{ii}.pID = ii;
    %     P{ii}.mSetUDP('255.255.255.255');
    %     P{ii}.pStatus.Conectado = 1;
end

%Posi��o inicial dos rob�s
P{1}.pPos.X = [0 0 0 0 0 0 0 0 0 0 0 0]';  % robo 1
P{2}.pPos.X = [1 -2 0 0 0 0 0 0 0 0 0 0]'; % robo 2

F = Formation_2Robots;

%%
for ii = 1:n
    RastrosR(ii).X = [];
    RastrosR(ii).Xd = [];
    RastrosR(ii).U = [];
end

%% Forma��o

% Vari�veis da forma��o
F.pPos.Q = [0; 0; 0; 0];         %xf ; yf ; rof ; alfaf
F.pPos.Q(1)    = (P{1}.pPos.X(1) + P{2}.pPos.X(1))/2;
F.pPos.Q(2)    = (P{1}.pPos.X(2) + P{2}.pPos.X(2))/2;
F.pPos.Q(3)   = sqrt((P{2}.pPos.X(1) - P{1}.pPos.X(1))^2 + (P{2}.pPos.X(2) - P{1}.pPos.X(2))^2);
F.pPos.Q(4) = atan2((P{2}.pPos.X(2) - P{1}.pPos.X(2)),(P{2}.pPos.X(1) - P{1}.pPos.X(1)));

% Vari�veis de forma��o desejadas
F.pPos.Qd = [3; 5; 1; 0];        % [xf,yf,rof,alfaf]

% Erro de posi��o inicial
F.pPos.Qtil = F.pPos.Qd - F.pPos.Q;

% Rastros da forma��o
RastrosF.q = [];
RastrosF.qTil = [];
RastrosF.vC = [];

%% Par�metros dos controladores
% ganhos do controlador cinem�tico
F.pPar.l = [.7 .7 .7 1];     %
% l = ones(1,4);
F.pPar.k = [.2 .2 .6 .07];

% matrizes de ganho
L = [ F.pPar.l(1), 0,    0,    0;
    0,    F.pPar.l(2), 0,    0;
    0,    0,    F.pPar.l(3), 0;
    0,    0,    0,    F.pPar.l(4)];

Kappa = [F.pPar.k(1), 0,         0,    0;
          0,         F.pPar.k(2),0,    0;
          0,         0,         F.pPar.k(3), 0;
          0,         0,          0,    F.pPar.k(4)];

% par�metros din�micos do pioneer 3dx (tese Felipe Martins)
for ii = 1:n
    P{ii}.pPar.th = [0.2604 0.2509 0.000499 0.9965 0.00263 1.0768]; % theta
    
    P{ii}.pPar.H = [P{ii}.pPar.th(1), 0 ; 0, P{ii}.pPar.th(2)];  % matriz do modelo din�mico do rob�
    P{ii}.pPar.I = 1;                                    % fator para ajuste (?)
    
    % ganhos do controlador din�mico
    P{ii}.pPar.Lu = 1;
    P{ii}.pPar.Lw = 1;
    P{ii}.pPar.ku = 1;
    P{ii}.pPar.kw = 1;
end
%% Simula��o

parar = 0;         % flag de parada da simula��o
figure
axis([-5,10,-2,15]);
grid on;
hold on

t_experimento = tic;
t_plot = tic;
t_controle = tic;

RastroControle = [];
RastroSimulacao = toc(t_experimento);

while parar == 0
    
    % Obt�m dados dos sensores dos rob�s
    P{1}.mLerDadosSensores;
    P{2}.mLerDadosSensores;
    
    if toc(t_controle)>0.1
        RastroControle = [RastroControle; toc(t_controle)];
        t_controle = tic;
        RastroSimulacao = [RastroSimulacao; toc(t_experimento)]; % salva tempo de simula��o
        
        % C�lculo das vari�veis de forma��o a partir da posi��o dos rob�s       
          F.pPos.X = [P{1}.pPos.X(1:6); P{2}.pPos.X(1:6)];
          F.mCalculaFormacao;  

%         if( abs(F.pPos.Q(4))>pi)
%             if(F.pPos.Q(4)>=0)
%                 F.pPos.Q(4) = -2*pi + F.pPos.Q(4);
%             else
%                 F.pPos.Q(4) = 2*pi + F.pPos.Q(4);
%             end
%         end
%         

        F.mCalculaVcin;
        P{1}.pSC.Uc = F.pSC.tempVc{1};
        P{2}.pSC.Uc = F.pSC.tempVc{2};
        
%         % Caso n�o use controle din�mico ==============================
% 
%         P{1}.pSC.Ur = F.pSC.Vc(1:2);
%         P{2}.pSC.Ur = F.pSC.Vc(3:4);
% 
%         % =============================================================
        
        % CONTROLE DIN�MICO ----------------------------------------------
        % C�lculo da acelera��o
        for ii = 1:n
            
            P{ii}.pSC.uw_old = P{ii}.pSC.U(1:2);       % salva velocidade anterior para c�lculo de acelera��o
            P{ii}.mLerDadosSensores;         % l� dados dos sensores do rob�
            P{ii}.pSC.uw_new = P{ii}.pSC.U(1:2);       % salva velocidade atual
            P{ii}.pSC.acc = (P{ii}.pSC.uw_new - P{ii}.pSC.uw_old)/.1;   % calcula acelera��o (a=dV/dt)
        end
        
        % C�lculo da velocidade de controle din�mico
        for ii = 1:n
            P{ii}.mCalculaVdin;
        end
        % FIM DO CONTROLE DIN�MICO ----------------------------------------
        
        % Envia sinal de controle aos rob�s
        P{1}.mEnviarSinaisControle;
        P{2}.mEnviarSinaisControle;

        for ii=1:n
            RastrosR(ii).X = [RastrosR(ii).X; P{ii}.pPos.X(1:6)'];
            RastrosR(ii).Xd = [RastrosR(ii).Xd; P{ii}.pPos.Xd(1:6)'];
            RastrosR(ii).U = [RastrosR(ii).U; P{ii}.pSC.U(1:2)'];
        end
        
        % Salva dados
        RastrosF.q = [RastrosF.q;  F.pPos.Q'];
        RastrosF.qTil = [RastrosF.qTil; F.pPos.Qtil'];
        RastrosF.vC = [RastrosF.vC; F.pSC.Vc'];
        
    end
    
    % Desenha trajet�ria em tempo real
    if toc(t_plot)>0.5
        t_plot = tic;
        try
            %             delete(fig(1));
            %             delete(fig(2));
            delete(fig(3));
            delete(fig(4));
            %
        end
        %         fig(1) = plot(P{1}.pPos.X(1),P{1}.pPos.X(2),'s');
        %         fig(2) = plot(P{2}.pPos.X(1),P{2}.pPos.X(2),'s');
        fig(3) = plot([P{1}.pPos.X(1),P{2}.pPos.X(1)],[P{1}.pPos.X(2),P{2}.pPos.X(2)]);
        fig(4) = plot(F.pPos.Q(1),F.pPos.Q(2),'kx');
        fig(5) = plot(F.pPos.Qd(1),F.pPos.Qd(2),'rx');
        %
        P{1}.mCADplot2D([1 0 0]);
        P{2}.mCADplot2D([0 0 1]);
        
        %         axis([-5, 5, -5, 5]);
        drawnow
    end
    
    % Crit�rio de parada da simula��o
    if (abs(F.pPos.Qtil(1))<0.5 && abs(F.pPos.Qtil(2))<0.05 && abs(F.pPos.Qtil(3))<0.1 && abs(F.pPos.Qtil(4))<pi/18)
        parar = 1;
    end
end
% Envia sinal de parada para cada rob�
if parar == 1
    %     for nmsg=1:20
    %         %enviar mensagem parar
    %         for ii=1:n
    %             P{ii}.mParar;
    %         end
    %     end
    
    % Plota Resultados
    figure
    hold on
    plot(RastrosF.vC(:,1)),title('Velocidade Linear');
    plot(RastrosF.vC(:,3));
    grid on;
    figure
    hold on
    plot(RastrosF.vC(:,2));
    plot(RastrosF.vC(:,4)),title('Velocidade Angular');
    grid on;
    figure;
    
    plot(RastrosF.qTil(:,[1 2 3]));
    title('Erro Posi��o'),legend('X','Y','\rho');
    grid on;
    figure;
    plot(RastrosF.qTil(:,4)),title('Erro Angulo da forma��o');
    grid on;
end