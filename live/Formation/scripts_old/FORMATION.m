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
PastaRaiz = 'AuRoRA 2018';
cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))
cd(PastaAtual)

%% Inicializa��o das classes
Rede = InfoSharing;    % classe para troca de dados entre os rob�s
% n = 2; %Numero de rob�s
ID = input('Digite o ID do robo: ');

P{ID} = Pioneer3DX(ID);
P{ID}.pID = ID;

F = Formation_2Robots(ID);

%% Posi��o inicial dos rob�s
% x = input('Digite a posi��o x do robo: ');
% y = input('Digite a posi��o y do robo: ');
% P{ID}.pPos.X = [x y 0 0 0 0 0 0 0 0 0 0]';  % robo
P{ID}.pPos.X = [0 0 0 0 0 0 0 0 0 0 0 0]';  % robo

%% Inicializa��o da comunica��o

F.mIniciaComunicacao(P{ID},Rede);
n = length(Rede.pMSG.getFrom);  % verifica n�mero de rob�s

%% Inicializa vari�veis para armazenar dados

% for ii = 1:n
%     RastrosR(ii).X = [];
%     RastrosR(ii).Xd = [];
%     RastrosR(ii).U = [];
% end

RastrosR.X = [];
RastrosR.Xd = [];
RastrosR.U = [];

% Rastros da forma��o
RastrosF.q = [];
RastrosF.qTil = [];
RastrosF.vC = [];

%% Crit�rio para inicializar o programa
if length(Rede.pMSG.getFrom)>1
    
    try
        % Povoa vari�veis do robo
        for ii = 1:n
            F.pPos.tempX{ii} = Rede.pMSG.getFrom{ii}(15:26);  % captura postura X de cada rob�
        end
        %    Postura dos rob�s da forma��o: [x1 y1 z1 rho1 theta1 psi1 x2 y2 z2 rho2 theta2 psi2]
        F.pPos.X = [F.pPos.tempX{1}(1:6);F.pPos.tempX{2}(1:6)];
    catch
        disp('Dados da rede incompletos.');
    end
    %% Forma��o
    % Vari�veis de forma��o desejadas
    F.pPos.Qd = [3; 5; 1; 0];        % [xf,yf,rof,alfaf]
    
    % C�lculo das Vari�veis da forma��o
    F.mCalculaFormacao;
    
    
    %% Par�metros dos controladores
    % Cinem�tico
    % ganhos do controlador cinem�tico
    F.pPar.l = [.7 .7 .7 .07];     %
    % l = ones(1,4);
    F.pPar.k = [.05 .05 .15 .0175];
    
    % Din�mico
    % par�metros din�micos do pioneer 3dx (tese Felipe Martins)
    
    P{ID}.pPar.th = [0.2604 0.2509 0.000499 0.9965 0.00263 1.0768]; % theta
    
    P{ID}.pPar.H = [P{ID}.pPar.th(1), 0 ; 0, P{ID}.pPar.th(2)];    % matriz do modelo din�mico do rob�
    P{ID}.pPar.I = 1;                        % fator para ajuste (?)
    
    
    % ganhos do controlador din�mico
    P{ID}.pPar.Lu = 1;
    P{ID}.pPar.Lw = 1;
    P{ID}.pPar.ku = 1;
    P{ID}.pPar.kw = 1;
    
    %% Simula��o
    
    parar = 0;         % flag de parada da simula��o
    figure
    axis([-3,10,-2,15])
    hold on
    
    t_experimento = tic;
    t_plot = tic;
    t_controle = tic;
    
    RastroControle = [];
    RastroSimulacao = toc(t_experimento);
    
    %% In�cio do loop
    while parar == 0
        
        P{ID}.mLerDadosSensores;    % Obt�m dados dos sensores do rob�
        
        if toc(t_controle)>0.1
            %             disp('entrou no if');
            RastroControle = [RastroControle; toc(t_controle)];
            t_controle = tic;
            RastroSimulacao = [RastroSimulacao; toc(t_experimento)]; % salva tempo de simula��o
            
            %% Calculo das vari�veis da forma��o
            try
                % Povoa vari�veis do robo
                for ii = 1:n
                    F.pPos.tempX{ii} = Rede.pMSG.getFrom{ii}(15:26);  % captura postura X de cada rob�
                end
                %    Postura dos rob�s da forma��o: [x1 y1 z1 rho1 theta1 psi1 x2 y2 z2 rho2 theta2 psi2]
                F.pPos.X = [F.pPos.tempX{1}(1:6);F.pPos.tempX{2}(1:6)];
                disp('Dados recebidos.');
            catch
                disp('Dados da rede incompletos.');
            end
            
            
            F.mCalculaFormacao;
            
            %             % Tratamento de �ngulo (?)
            %             if( abs(F.q(4))>pi)
            %                 if(F.q(4)>=0)
            %                     F.q(4) = -2*pi + F.q(4);
            %                 else
            %                     F.q(4) = 2*pi + F.q(4);
            %                 end
            %             end
            
            %% Calculo da velocidade cinem�tica
            F.mCalculaVcin;
            
            % Atribui velocidade cinem�tica ao robo
            P{ID}.pSC.Uc = F.pSC.tempVc{ID};
            
            P{ID}.pSC.Ur = P{ID}.pSC.Uc; % Caso n�o inclua controle
            %             din�mico
            %
            
            %% Troca de informa��o com a rede
            %             Rede.mSendMsg(P{ID});       % envia dados para rede
            %             Rede.mReceiveMsg;           % le dados da rede
            %
            F.mIniciaComunicacao(P{ID},Rede);
            
            %% CONTROLE DIN�MICO  ------------------------------
            
            % C�lculo da acelera��o
            obj.pSC.Ua = obj.pSC.U(1:2);                % salva velocidade anterior para c�lculo de acelera��o
            obj.mLerDadosSensores;                      % l� dados dos sensores do rob�
            obj.pSC.dU = (obj.pSC.Ua - obj.pSC.U)/.1;   % calcula acelera��o (a=dV/dt)
            
%             % Compensa��o din�mica
%             A.mCompensadorDinamico;
            
        end
        %% Envia sinal de controle ao rob�
        P{ID}.mEnviarSinaisControle;
        
        %% Salva dados
        RastrosF.q = [RastrosF.q;  F.pPos.Q'];
        RastrosF.qTil = [RastrosF.qTil; F.pPos.Qtil'];
        RastrosF.vC = [RastrosF.vC; F.pSC.Vc'];
        %                 for ii=1:n
        %
        %         RastrosR(ii).X = [RastrosR(ii).X; P{ii}.pPos.X(1:6)'];
        %         RastrosR(ii).Xd = [RastrosR(ii).Xd; P{ii}.pPos.Xd(1:6)'];
        %         RastrosR(ii).U = [RastrosR(ii).U; P{ii}.pSC.U(1:2)'];
        %                 end
        %
        
        RastrosR.X = [RastrosR.X; P{ID}.pPos.X(1:6)'];
        RastrosR.Xd = [RastrosR.Xd; P{ID}.pPos.Xd(1:6)'];
        RastrosR.U = [RastrosR.U; P{ID}.pSC.U(1:2)'];
        
        %         %% Troca de informa��o com a rede
        %         Rede.mSendMsg(P{ID});       % envia dados para rede
        %         Rede.mReceiveMsg;           % le dados da rede
        F.mIniciaComunicacao(P{ID},Rede);
        
        %% Desenha trajet�ria em tempo real
        if toc(t_plot)>0.5
            t_plot = tic;
            try
                %             delete(fig(1));
                %             delete(fig(2));
                delete(fig(3));
                delete(fig(4));
                %
            catch
            end
            % Obt�m dados do outro rob� da forma��o para plotar gr�ficos
            %             for ii = 1:n
            %                 if ii~=ID
            %                     P{ID}.pPos.X = Rede.pMSG.getFrom{ID}(15:26);  % captura postura X de cada rob�
            %                 end
            %
            %             end
            
            %         fig(1) = plot(P{1}.pPos.X(1),P{1}.pPos.X(2),'s');
            %         fig(2) = plot(P{2}.pPos.X(1),P{2}.pPos.X(2),'s');
            %             fig(3) = plot([P{1}.pPos.X(1),P{2}.pPos.X(1)],[P{1}.pPos.X(2),P{2}.pPos.X(2)]);
            fig(4) = plot(F.pPos.Q(1),F.pPos.Q(2),'x');
            fig(5) = plot(F.pPos.Qd(1),F.pPos.Qd(2),'x');
            %
            
            P{ID}.mCADplot2D([1 0 0]);  % plota modelo do rob�
            %             P{2}.mCADplot2D([0 1 0]);  % plota modelo do rob�
            drawnow
            
        end
        
        % Crit�rio de parada da simula��o
        if (abs(F.pPos.Qtil(1))<0.5 && abs(F.pPos.Qtil(2))<0.05 && ...
                abs(F.pPos.Qtil(3))<0.1 && abs(F.pPos.Qtil(4))<pi/18)
            parar = 1;
        end
    end
    %% Fim do loop
    
    
    %% Envia sinal de parada para cada rob�
    % if parar == 1
    %     for nmsg=1:20
    %         %enviar mensagem parar
    %         for ii=1:n
    %             P{ii}.mParar;
    %         end
    %     end
    
    
    %% Plota Resultados
    figure
    hold on
    plot(RastrosF.vC(:,1)),title('Velocidade Linear');
    plot(RastrosF.vC(:,3));
    figure
    hold on
    plot(RastrosF.vC(:,2));
    plot(RastrosF.vC(:,4)),title('Velocidade Angular');
    figure;
    
    plot(RastrosF.qTil(:,[1 2 3])),title('Erro Posi��o'),legend('X','Y','\rho');
    figure;
    plot(RastrosF.qTil(:,4)),title('Erro Angulo da forma��o');
end