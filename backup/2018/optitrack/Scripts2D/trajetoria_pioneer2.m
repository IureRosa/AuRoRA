%% CONTROLE DE TRAJET�RIA PARA PIONEER UTILIZANDO OPTITRACK
% Neste algoritmo, o rob� recebe os dados de posi��o do optitrack que est�
% localizado em outra m�quina e faz seu pr�prio processamento

% **Este c�digo � para o pc que ir� ficar sobre o rob�
% (Enquanto isso, o pc do optitrack dever� estar enviando dados de posi��o
% do rob� para rede)

clear
close all
clc
% Fecha todas poss�veis conex�es abertas
try
    fclose(instrfindall);
catch
end

%% Rotina para buscar pasta raiz
PastaAtual = pwd;
PastaRaiz = 'AuRoRA 2018';
cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))

%% Defini��o da janela do gr�fico
fig = figure(1);
axis([-5 5 -5 5])
% axis equal

%% Classes initialization
% Robot
P = Pioneer3DX;

% Network
Rede = NetDataShare;

% Joystick control
% J = JoyControl;

%% Connect with MobileSim || Pioneer3DX
P.rConnect;             % rob� ou mobilesim

%% Network communication

while isempty(Rede.pMSG.getFrom)
    
    Rede.mReceiveMsg;
    disp('Waiting for message......')
    
end
clc
disp('Data received......');

%% Robot initial position
if ~isempty(Rede.pMSG.getFrom)
    P.pPos.X  = Rede.pMSG.getFrom{1}(14+(1:12));
end

P.rSetPose(P.pPos.X([1 2 3 6]));         % define pose do rob�

%% Variables initialization
data = []; % simulation data (for graphics)
k = 0;     % package lost counter
X=[];      % sensor position data

%% Trajectory variables
a = 1.2;         % dist�ncia em x
b = 0.8;         % dist�ncia em y

w = 0.1;

nvoltas = 2.5;
tsim = 2*pi*nvoltas/w;

%% Simulation

% Temporiza��o
tap = .1;     % taxa de atualiza��o do pioneer
timeout = 200;   % tempo m�ximo de dura��o da simula��o
t = tic;
tc = tic;
tp = tic;

while toc(t) < tsim
    
    if toc(tc) > tap
        
        tc = tic;
        % ---------------------------------------------------------------
        % Data aquisition
        P.rGetSensorData;
        X = P.pPos.X;
        % Get network data
        Rede.mReceiveMsg;
        % If there is data from optitrack, overwrite position values
        if ~isempty(Rede.pMSG.getFrom)
            P.pPos.X  = Rede.pMSG.getFrom{1}(14+(1:12));
            %             X  = Rede.pMSG.getFrom{1}(14+(1:12));
        else
            k = k+1;
        end
        
        % Calculate robot center point position
        P.pPos.Xc([1 2 6]) = P.pPos.X([1 2 6]) - ...
            [P.pPar.a*cos(P.pPos.X(6)); P.pPar.a*sin(P.pPos.X(6)); 0];
        
    end
    % Trajectory -------------------------------------------------------
    % infinito (8')
    ta = toc(t);
    P.pPos.Xd(1)  = a*sin(w*ta);       % posi��o x
    P.pPos.Xd(2)  = b*sin(2*w*ta);     % posi��o y
    P.pPos.Xd(7) = a*w*cos(w*ta);     % velocidade em x
    P.pPos.Xd(8) = 2*b*w*cos(2*w*ta); % velocidade em y
    
    %         %
    %                % Desired Position
    %             if toc(t) > cont*10
    %
    %                 cont = cont + 1;
    %
    %             end
    %
    %             if cont<=length(Xd)
    %                 P.pPos.Xd(1) = Xd(cont,1);   % x
    %                 P.pPos.Xd(2) = Xd(cont,2);   % y
    %             end
    
    % --------------------------------------------------------------
    % Control
    %
    %     % Error calculation
    %     P.pPos.Xtil = P.pPos.Xd - P.pPos.X;
    %
    %     % Quadrant correction
    %     if abs(P.pPos.Xtil(6)) > pi
    %         if P.pPos.Xtil(6) > 0
    %             P.pPos.Xtil(6) = -2*pi + P.pPos.Xtil(6);
    %         else
    %             P.pPos.Xtil(6) =  2*pi + P.pPos.Xtil(6);
    %         end
    %     end
    %
    %     % Controller
    %     P.pPos.dXr(1:2) = P.pPos.Xd(7:8) + K1*tanh(K2*P.pPos.Xtil(1:2));
    %
    %     % Get control signal
    %     P.sInvKinematicModel(P.pPos.dXr(1:2));
    % Kinematic controller
    P = fControladorCinematico(P);
    % Dynamic compensation
    P = fCompensadorDinamico(P);
    
    % #####################################################
    % Descomentar quando estiver sem compensa��o din�mica
    %          P.pSC.Ud = P.pSC.Ur;
    % #####################################################
    % -------------------------------------------------------------

    % Send control to robot
    P.rSendControlSignals;
    
    % Save data for plot
    data = [data; P.pPos.Xd' P.pPos.X' X' P.pSC.Ud' P.pSC.U' toc(t)];
    
%     % Desenha os rob�s
%     if toc(tp) > tap
%         tp = tic;
%         P.mCADdel
%         delete(fig);
%         P.mCADplot(1,'k')
%         hold on
%         fig1 = plot(Rastro.Xd(:,1),Rastro.Xd(:,2),'k');
%         fig2 = plot(Rastro.X(:,1),Rastro.X(:,2),'g');
%         axis([-5 5 -5 5])
%         grid on
%         drawnow
%     end
    
end

%%  Stop robot
% Zera velocidades do rob�
P.pSC.Ud = [0 ; 0];
P.rSendControlSignals;

%% Results

% Control Signals
figure;
subplot(211)
plot(data(:,37)),hold on;
plot(data(:,39)), legend({'$v_d$','$v_{real}$'},'interpreter','Latex')
grid on
subplot(212)
plot(data(:,38)),hold on
plot(data(:,40)), legend('\omega_d','\omega_{real}')
grid on

% Trajectory
figure;
plot(data(:,1),data(:,2),'LineWidth',1),hold on
plot(data(:,13),data(:,14))
plot(data(:,25),data(:,26),'--')
legend('Desejado','Optitrack','Sensor')
grid on

% End of code xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
