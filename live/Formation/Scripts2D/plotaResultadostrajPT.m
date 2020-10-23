%% Rotina para plotar gr�ficos de Formacaolinha2d trajet�ria
clear all
close all
clc
%% Rotina para buscar pasta raiz
PastaAtual = pwd;
PastaRaiz = 'AuRoRA 2018';
cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))

%% Declara os robos
P1 = Pioneer3DX;
P2 = Pioneer3DX;
LF = LineFormation2D('center');

%% Carrega dados
data = load('FL2dtraj_20180630T155638.txt');

%% Atribui��o de vari�veis
% data = data(1:1000,:);
%Tempo da simula��o
time  = data(:,end);                % tempo (s)

% Rob� 1
P1.pPos.Xd   = data(:,(1:12));       % postura desejada
P1.pPos.X    = data(:,12+(1:12));    % postura real
P1.pSC.Ud    = data(:,24+(1:2));     % sinal de controle
P1.pSC.U     = data(:,26+(1:2));     % velocidades do rob�
P1.pPos.Xtil = P1.pPos.Xd - P1.pPos.X; % erro de postura

% Rob� 2
P2.pPos.Xd   = data(:,28+(1:12));
P2.pPos.X    = data(:,40+(1:12));
P2.pSC.Ud    = data(:,52+(1:2));
P2.pSC.U     = data(:,54+(1:2));
P2.pPos.Xtil = P2.pPos.Xd - P2.pPos.X;

% Dados da Forma��o
LF.pPos.Qd    = data(:,56+(1:4));
LF.pPos.Qtil = data(:,60+(1:4));


% Vetor de posi��o dos rob�s: LF.pPos.X = [x1 y1 rho1 theta1 psi1 x2 y2 z2 rho2 theta2 psi2]
% Vetor da forma��o: LF.pPos.Q = [xf yf rhof alfaf]
for k=1:length(time)
    LF.pPos.X = [P1.pPos.X(k,1:6) P2.pPos.X(k,1:6)];
    LF.mDirTrans;
    Q(:,k) = LF.pPos.Q';
 
end

%% PLOTA RESULTADOS
sizeLineDesired   = 2;%'default';    % largura da linha
sizeLineReal      = 1.3;
sizeLegend = 20;  % tamanho da fonte
sizeSymbol = 2;   % tamanho dos s�mbolos
sizeLabel  = 20;  

%% Posi��o dos rob�s
figure;
axis([-4 6 -3 3]);
axis equal
hold on, grid on;
box on
% percurso realizado
p1 = plot(P1.pPos.X(:,1),P1.pPos.X(:,2),'r-','LineWidth',sizeLineDesired);
p2 = plot(P2.pPos.X(:,1),P2.pPos.X(:,2),'b-','LineWidth',sizeLineReal);
% title('Posi��o dos Rob�s','fontSize',lt);
xlabel('$x$ [m]','FontSize',sizeLabel,'interpreter','Latex'),ylabel('$y$ [m]','FontSize',sizeLabel,'Interpreter','latex');

% trajet�ria da forma��o desejada
pd  = plot(LF.pPos.Qd(:,1),LF.pPos.Qd(:,2),'k--','LineWidth',2);
% trajet�ria da forma��o real
pd2 = plot(Q(1,:),Q(2,:),'c-','LineWidth',sizeLineReal);

% plota robos e linhas de forma��o
for k = 1:150:length(time)
    
    % Obten��o da posi��o do centro dos rob�s
    P1.pPos.Xc([1 2 6]) = P1.pPos.X(k,[1 2 6])' - ...
        [P1.pPar.a*cos(P1.pPos.X(k,6)); P1.pPar.a*sin(P1.pPos.X(k,6)); 0];
    
    P2.pPos.Xc([1 2 6]) = P2.pPos.X(k,[1 2 6])' - ...
        [P2.pPar.a*cos(P2.pPos.X(k,6)); P2.pPar.a*sin(P2.pPos.X(k,6)); 0];
    
    
        % plota trianglinho
        P1.mCADplot2D('r');
        P2.mCADplot2D('b');
    
    %     % plota pioneer
%     A.mCADplot(1,'r');
%     B.mCADplot(1,'b');
    
    % plot linhas da forma��o executadas
    x = [P1.pPos.X(k,1) P2.pPos.X(k,1)];
    y = [P1.pPos.X(k,2) P2.pPos.X(k,2)];
    
    pl = line(x,y);
    pl.Color = 'g';
    pl.LineStyle = '-';
    pl.LineWidth = 1;
    
%     hold on
    
%     % plot linhas da forma��o desejadas
%     xd = [A.pPos.Xd(k,1) B.pPos.Xd(k,1)];
%     yd = [A.pPos.Xd(k,2) B.pPos.Xd(k,2)];
%     
%     pld = line(xd,yd);
%     pld.Color = 'm';
%     pld.LineStyle = '--';
%     pld.LineWidth = 1;
end

% lg1 = legend([p1 p2 pl pld],{'Robo 1', 'Robo 2','Real formation','Formacao desejada'});
% lg1 = legend([p1 p2 pld pl pd pd2],{'Robot 1', 'Robot 2','Desired Formation','Real Formation','Desired trajectory','Real trajectory'});
lg1 = legend([p1 p2 pl pd pd2],{'Rob\^{o} 1', 'Rob\^{o} 2','Linha da Forma\c c\~{a}o','Trajet\''{o}ria desejada','Trajet\''{o}ria real'});

lg1.FontSize = sizeLegend;
lg1.Location = 'SouthEast';
set(lg1,'Interpreter','latex');
% legend('boxoff')

%% Velocidades lineares
figure;
subplot(221)
plot(time(1:end-5),P1.pSC.Ud(1:end-5,1),'r--','LineWidth',sizeLineDesired),hold on;
plot(time(1:end-5),P1.pSC.U(1:end-5,1),'b','LineWidth',sizeLineReal);
legend({'$u_{1d}$','$u_{1r}$'},'FontSize',sizeLegend,'Interpreter','latex');
xlabel('Tempo [s]','FontSize',sizeLabel,'interpreter','Latex');
ylabel('Velocidade linear[m/s]','FontSize',sizeLabel,'interpreter','Latex');
xlim([0 time(end)]);
ylim([0 0.4]);
grid on;
box on
subplot(223)
plot(time(1:end-5),P2.pSC.Ud(1:end-5,1),'r--','LineWidth',sizeLineDesired),hold on;
plot(time(1:end-5),P2.pSC.U(1:end-5,1),'b','LineWidth',sizeLineReal);
% title('Velocidade Linear','fontSize',st);
xlabel('Tempo [s]','FontSize',sizeLabel,'interpreter','Latex');
ylabel('Velocidade linear [m/s]','FontSize',sizeLabel,'interpreter','Latex');
% legend({'Robot 1', 'Robot 2'},'Interpreter','latex');
legend({'$u_{2d}$','$u_{2r}$'},'FontSize',sizeLegend,'Interpreter','latex');
xlim([0 time(end)]);
ylim([0 0.4]);
grid on
box on
%% Velocidades Angulares -------------------------------------
% figure;
subplot(222);
plot(time(1:end-5),P1.pSC.Ud(1:end-5,2),'r--','LineWidth',sizeLineDesired),hold on;
plot(time(1:end-5),P1.pSC.U(1:end-5,2),'b','LineWidth',sizeLineReal);
legend({'$\omega_{1d}$','$\omega_{1r}$'},'FontSize',sizeLegend,'Interpreter','latex');
xlabel('Tempo [s]','FontSize',sizeLabel,'interpreter','Latex');
ylabel('Velocidade angular[rad/s]','FontSize',sizeLabel,'interpreter','Latex');
xlim([0 time(end)]);
ylim([-1 1]);
grid on;
box on
subplot(224);
plot(time(1:end-5),P2.pSC.Ud(1:end-5,2),'r--','LineWidth',sizeLineDesired),hold on;
plot(time(1:end-5),P2.pSC.U(1:end-5,2),'b','LineWidth',sizeLineReal);
legend({'$\omega _{2d}$','$\omega_{2r}$'},'FontSize',sizeLegend,'Interpreter','latex');
grid on;
% title('Velocidade Angular','fontSize',st);
xlabel('Tempo [s]','FontSize',sizeLabel,'interpreter','Latex');
ylabel('Velocidade angular [rad/s]','FontSize',sizeLabel,'interpreter','Latex');
% legend({'Robot 1', 'Robot 2'},'Interpreter','latex');
xlim([0 time(end)]);
ylim([-1 1]);
box on

%% Erro da forma��o - posi��o
figure;
subplot(211)
plot(time(1:end-5),LF.pPos.Qtil(1:end-5,1),'--','LineWidth',sizeLineReal), hold on;
plot(time(1:end-5),LF.pPos.Qtil(1:end-5,2),'-.','LineWidth',sizeLineReal);
plot(time(1:end-5),LF.pPos.Qtil(1:end-5,3),'-','LineWidth',sizeLineReal);
% title('Erro de posi��o','fontSize',st);
xlabel('Tempo [s]','FontSize',sizeLabel,'interpreter','Latex');
ylabel('Erro [m]','FontSize',sizeLabel,'interpreter','Latex');
xlim([0 time(end)]);
grid on;
box on

lg3 = legend('$x_f$','$y_f$', '$\rho_f$');
% lg3 = legend('$x_f [m]$','$y_f [m]$', '$\rho_f [m]$');

lg3.FontSize = sizeLegend;
lg3.Location = 'NorthEast';
set(lg3,'Interpreter','latex');

%Angulo
% figure;
subplot(212)
plot(time(1:end-5),LF.pPos.Qtil(1:end-5,4),'LineWidth',sizeLineReal);
% title('Erro de posi��o','fontSize',st);
xlabel('Tempo [s]','FontSize',sizeLabel,'interpreter','Latex');
ylabel('Erro [rad]','FontSize',sizeLabel,'interpreter','Latex');
xlim([0 time(end)]);
grid on
box on
lg4 = legend('$\alpha_f$');

lg4.FontSize = sizeLegend;
lg4.Location = 'NorthEast';
set(lg4,'Interpreter','latex');


