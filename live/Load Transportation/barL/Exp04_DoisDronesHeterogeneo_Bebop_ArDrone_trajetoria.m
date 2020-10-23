
clear; close all; clc;
try
    fclose(instrfindall);
catch
end

%
% % Look for root folder
% PastaAtual = pwd;
% PastaRaiz = 'AuRoRA 2018';
% cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
% addpath(genpath(pwd))

%% Load Classes

%% Load Class
try
    % Load Classes
        A = ArDrone(1);
        A.pPar.Ts = 1/30;
        A.pPar.Model_simp = [ 14.72 0.2766 6.233 0.53 2.6504 2.576 .3788 1.5216 ]';

    RI = RosInterface;
    RI.rConnect('192.168.0.144');
    
    % Create OptiTrack object and initialize
    OPT = OptiTrack;
    OPT.Initialize;
    
    % Initiate classes
    B = Bebop(1,'B1');
    
%     L{1} = Load;
%     L{2} = Load;
%     idL{1} = getID(OPT,Load,3);
%     idL{2} = getID(OPT,Load,4);
    
    % Valores: exposure 330 threshold 150
    idA = getID(OPT,ArDrone);
    rb = OPT.RigidBody;
    if rb(idA).isTracked
    A = getOptData(rb(idA),A);
    end
%     if rb(idL{1}).isTracked
%         L{1} = getOptData(rb(idL{1}),L{1});
%     end
%     
%     if rb(idL{2}).isTracked
%         L{2} = getOptData(rb(idL{2}),L{2});
%     end
    
    
    % Joystick
    J = JoyControl;
    
  
    disp('################### Load Class Success #######################');
    
catch ME
    disp(' ');
    disp(' ################### Load Class Issues #######################');
    disp(' ');
    disp(' ');
    disp(ME);
    
    RI.rDisconnect;
    rosshutdown;
    return;
    
end



%%%%%%%%%%%%%%%%%%%%%% Bot�o de Emergencia %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nLandMsg = 3;
btnEmergencia = 0;
ButtonHandle = uicontrol('Style', 'PushButton', ...
    'String', 'land', ...
    'Callback', 'btnEmergencia=1', ...
    'Position', [50 50 400 300]);


%% Variable initialization
data = [];

rX = 1;           % [m]
rY = 1;           % [m]
T = 20;             % [s]
Tf = T*2;            % [s]
w = 2*pi/T;         % [rad/s]

% Time variables initialization

Xd = [0 0 0 0];
dXd = [0 0 0 0];

fprintf('\nStart..............\n\n');

pause(3)
%% Formation Variables Initialization
barL.pPos.X = zeros(6,1);
barL.pPos.Xd = zeros(6,1);
barL.pPos.Xr = zeros(6,1);

barL.pPos.dXr = zeros(6,1);
barL.pPos.dXd = zeros(6,1);

barL.pPos.X_load = zeros(6,1);

barL.pPos.Qd = zeros(6,1);
barL.pPos.dQd = zeros(6,1);
barL.pPos.Q = zeros(6,1);
barL.pPos.Qtil = zeros(6,1);
barL.pPos.alpha = 0;
barL.pPos.beta = 0;
barL.pPos.rho = 0;
L1 = diag([2 2 3 1 1 1]);
L2 = diag([1 1 1 1 1 1]);

%% Par�metros da Carga barL 
% Comprimento dos cabos
barL.pPar.l1 = 1.05;
barL.pPar.l2 = .99;

% Comprimento da barL
barL.pPar.L = 1.45;  

% Massa da barL
barL.pPar.m = .155;      %Kg

barL.pPar.K1 = .5*diag([1 1 1 1 1 1]);    % kinematic control gain  - controls amplitude
barL.pPar.K2 = 1*diag([0.2 0.2 0.5 0.2 0.2 0.5]);        % kinematic control gain - control saturation

% Beboop
disp('Start Take Off Timming....');
B.rTakeOff;
A.pPar.ip = '192.168.1.61';
A.rConnect;
A.rTakeOff;

pause(5);
disp('Taking Off End Time....');

%% TAREFA: Posi��o desejada nas vari�veis generalizadas Q = (xc,yc,zc,alpha,gamma,L)
barL.pPos.Qd = [0 0 .5 deg2rad(0) deg2rad(0) barL.pPar.L]';

% Transforma��o inversa Q -> X, i.e., (xc,yc,zc,alpha,gamma,L)_d-> (x1,y1,z1,x2,y2,z2)_d
barL.pPos.Xd(1) = barL.pPos.Qd(1) - cos(barL.pPos.Qd(5))*sin(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(2) = barL.pPos.Qd(2) - cos(barL.pPos.Qd(5))*cos(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(3) = barL.pPos.Qd(3) - sin(barL.pPos.Qd(5))*barL.pPos.Qd(6)/2 + barL.pPar.l1;
barL.pPos.Xd(4) = barL.pPos.Qd(1) + cos(barL.pPos.Qd(5))*sin(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(5) = barL.pPos.Qd(2) + cos(barL.pPos.Qd(5))*cos(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(6) = barL.pPos.Qd(3) + sin(barL.pPos.Qd(5))*barL.pPos.Qd(6)/2 + barL.pPar.l2;
barL.pPos.dXd = zeros(6,1);  % Como � tarefa de posi��o, n�o h� dXd. 

% Povoando a vari�vel X e X_load da classe
barL.pPos.X = [B.pPos.X(1:3); A.pPos.X(1:3)];
% barL.pPos.X_load = [L{1}.pPos.X(1) L{1}.pPos.X(2) L{1}.pPos.X(3) L{2}.pPos.X(1) L{2}.pPos.X(2) L{2}.pPos.X(3)]';

% C�lculo do erro nos drones
barL.pPos.Xtil = barL.pPos.Xd - barL.pPos.X;

% timers
T_exp = 120; % tempo de experimento
T_run = 1/30; % per�odo de amostragem do experimento
t_run = tic;
t_total = tic; % tempo que o experimento est� rodando (running)
t_plot = tic; % 
T_plot = .3; % per�odo de plotagem
t_task = tic;
T_task = 13;
i_task = 0;
t_exp = tic;
t  = tic;
A.pSC.Kinematics_control = 1;
B.pSC.Kinematics_control = 1;
 

B.pPar.ti = tic;
A.pPar.ti = tic;
try
    while toc(t) < T_exp
        
        if toc(t_run) > T_run
            
            t_run = tic;
%% LEITURA: Obtendo dados dos sensores
      
%  ---BEBOP---
        B.rGetSensorDataOpt;

% ---ARDRONE---
        A.pPos.Xda = A.pPos.Xd;
        rb = OPT.RigidBody;
        if rb(idA).isTracked
            A = getOptData(rb(idA),A);
        end
        
%         if rb(idL{1}).isTracked
%             L{1} = getOptData(rb(idL{1}),L{1});
%         end
%         
%         if rb(idL{2}).isTracked
%             L{2} = getOptData(rb(idL{2}),L{2});
%         end
        
       


%% TAREFA: Posi��o desejada nas vari�veis generalizadas Q = (xc,yc,zc,alpha,gamma,L)
% Trajet�ria            
%                 Xd = [rX*sin(w*toc(t));
%                     rY*cos(0.5*w*toc(t));
%                     0.5 + 0.5*sin(w*toc(t));
%                     0];
% 
% 
%                 dXd = [w*rX*cos(w*toc(t));
%                     -0.5*w*rY*sin(0.5*w*toc(t));
%                     w*0.5*cos(w*toc(t));
%                     0];

                % Posi��o
                                Xd = [0;
                                      0;
                                      0.5;
                                      0];
                
                
                            dXd = [0;
                                   0;
                                   0;
                                   0];

                barL.pPos.Qd = [Xd(1) Xd(2) Xd(3) deg2rad(0) deg2rad(0) barL.pPar.L]';
                barL.pPos.dQd = [dXd(1) dXd(2) dXd(3) 0 0 0]';

%% FORMA��O                
                barL.pPos.alpha = atan2(A.pPos.X(2) - B.pPos.X(2),A.pPos.X(1) - B.pPos.X(1));
                barL.pPos.beta = atan2(A.pPos.X(3) - B.pPos.X(3),norm(A.pPos.X(1:2) - B.pPos.X(1:2)));
                barL.pPos.rho = norm(A.pPos.X(1:3) - B.pPos.X(1:3));

                barL.pPos.Q = [B.pPos.X(1:3); barL.pPos.alpha; barL.pPos.beta; barL.pPos.rho];
                barL.pPos.Qtil = barL.pPos.Qd - barL.pPos.Q;
                
%% CONTROLE CINEM�TICO DA FORMA��O (VERIFICAR SE pSC.Kinematics_control = 1)
                barL.pPos.Qr = barL.pPos.dQd + L1*tanh(L2*barL.pPos.Qtil);
                
J_inv = [1 0 0           0                       0                          0          ;...
         0 1 0           0                       0                          0          ;...
         0 0 1           0                       0                          0          ;...
         1 0 0 cos(barL.pPos.alpha)*cos(barL.pPos.beta) -barL.pPos.rho*sin(barL.pPos.alpha)*cos(barL.pPos.beta) -barL.pPos.rho*cos(barL.pPos.alpha)*sin(barL.pPos.beta);...
         0 1 0 sin(barL.pPos.alpha)*cos(barL.pPos.beta)  barL.pPos.rho*cos(barL.pPos.alpha)*cos(barL.pPos.beta) -barL.pPos.rho*sin(barL.pPos.alpha)*sin(barL.pPos.beta);...
         0 0 1       sin(barL.pPos.beta)                   0                    barL.pPos.rho*cos(barL.pPos.beta)    ];
                
                barL.pPos.Xr = J_inv*barL.pPos.Qr;
                B.pPar.Xr([1 2 3 6]) = [barL.pPos.Xr(1:3); 0];
                A.pPar.Xr([1 2 3 6]) = [barL.pPos.Xr(4:6); 0];


%% CONTROLE DIN�MICO DOS ROB�S                
%         B.cInverseDynamicController_Compensador;
%         A = cInverseDynamicController_Compensador_ArDrone(A);
        A = cInverseDynamicController_Adaptativo_ArDrone(A);
        B.cInverseDynamicController_Adaptativo;

        B.pPar.ti = tic;
        A.pPar.ti = tic;
        
%         B = J.mControl(B);                    % joystick command (priority)
%         B.rCommand;
        A = J.mControl(A);                       % joystick command (priority)
        A.rSendControlSignals;
            
%% DATA
            
            % Variable to feed plotResults function
            data = [  data  ; B.pPos.Xd(1:3)'     B.pPos.X(1:3)' ...
                              A.pPos.Xd(1:3)'     A.pPos.X(1:3)' ...
                              B.pPar.Model_simp'  A.pPar.Model_simp' toc(t)];
            
            % %         %   1 -- 3      4 -- 6     
            % %         B{1}.pPos.Xd'  B{1}.pPos.X' 
            % %
            % %         %   7 -- 9     10 -- 12        13 -- 18
            % %         B{2}.pPos.Xd'  B{2}.pPos.X' barL.pPos.X_load'
            % %
            % %         %  19 -- 26             27 -- 34          35
            % %      B{1}.pPar.Model_simp  B{2}.pPar.Model_simp  toc(t) ];
            
           
%% SEGURAN�A            
            
            % If push Emergency or ROS Emergency Stop On or Not Rigid Body tracked Stop loop
            if btnEmergencia ~= 0 || B.pFlag.EmergencyStop ~= 0 || B.pFlag.isTracked ~= 1
                disp('Bebop Landing through Emergency Command ');

                % Send 3 times Commands 1 second delay to Drone Land
                for i=1:nLandMsg
                    disp("End Land Command");
                    B.rCmdStop;
                    B.rLand;
                end
                break;
            end
            
            
         
        end
    end
catch ME
    
    disp('Bebop Landing through Try/Catch Loop Command');
    B.rCmdStop;
    disp('');
    disp(ME);
    disp('');
    B.rLand
    
    disp('Bebop Landing through Try/Catch Loop Command');
    A.rLand
    
    end


% Send 3 times Commands 1 second delay to Drone Land
for i=1:nLandMsg
    disp("End Land Command");
    B.rCmdStop;
    B.rLand
    
    disp("End Land Command");
    A.rLand
end


% Close ROS Interface
RI.rDisconnect;
rosshutdown;

disp("Ros Shutdown completed...");

% Plot results
B1_Xtil = data(:,1:3) - data(:,4:6);
B2_Xtil = data(:,7:9) - data(:,10:12);
Load_Xtil = [data(:,1:3) - data(:,13:15) data(:,7:9) - data(:,16:18)];
Load_Xtil(:,[3 6]) = Load_Xtil(:,[3 6]) - barL.pPar.l1;


% 
figure();
hold on;
grid on;
plot(data(:,29),B1_Xtil(:,1));
plot(data(:,29),B1_Xtil(:,2));
plot(data(:,29),B1_Xtil(:,3));
title('Erro de Posi��o Q1');
legend('Pos X','Pos Y','Pos Z');
xlabel('Tempo[s]');
ylabel('Erro [m]');

figure();
hold on;
grid on;
plot(data(:,29),B2_Xtil(:,1));
plot(data(:,29),B2_Xtil(:,2));
plot(data(:,29),B2_Xtil(:,3));
title('Erro de Posi��o Q2');
legend('Pos X','Pos Y','Pos Z');
xlabel('Tempo[s]');
ylabel('Erro [m]');

% figure();
% hold on;
% grid on;
% plot(data(:,35),Load_Xtil(:,1));
% plot(data(:,35),Load_Xtil(:,2));
% plot(data(:,35),Load_Xtil(:,3));
% title('Erro de Posi��o L1');
% legend('Pos X','Pos Y','Pos Z');
% xlabel('Tempo[s]');
% ylabel('Erro [m]');
% 
% figure();
% hold on;
% grid on;
% plot(data(:,35),Load_Xtil(:,4));
% plot(data(:,35),Load_Xtil(:,5));
% plot(data(:,35),Load_Xtil(:,6));
% title('Erro de Posi��o L2');
% legend('Pos X','Pos Y','Pos Z');
% xlabel('Tempo[s]');
% ylabel('Erro [m]');


% % 
% % figure();
% % hold on;
% % grid on;
% % plot(data(:,1),data(:,2));
% % plot(data(:,13),data(:,14));
% % title('XY');
% % xlabel('X [m]');
% % ylabel('Y [m]');
% % 
% % figure();
% % subplot(411)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,19));
% % plot(data(:,35),data(:,7));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [m/s]');
% % legend('dX', 'dXd');
% % 
% % subplot(412)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,20));
% % plot(data(:,35),data(:,8));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [m/s]');
% % legend('dY', 'dYd');
% % 
% % subplot(413)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,21));
% % plot(data(:,35),data(:,9));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [m/s]');
% % legend('dZ', 'dZd');
% % 
% % subplot(414)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,24));
% % plot(data(:,35),data(:,12));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [rad/s]');
% % legend('phi', 'dphi');
% % 
% % 
% % figure();
% % subplot(311)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,13));
% % plot(data(:,35),data(:,1));
% % xlabel('Tempo[s]');
% % ylabel('Erro posi��o [m]');
% % legend('X', 'Xd');
% % 
% % subplot(312)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,14));
% % plot(data(:,35),data(:,2));
% % xlabel('Tempo[s]');
% % ylabel('Erro posi��o [m]');
% % legend('Y', 'Yd');
% % 
% % subplot(313)
% % hold on;
% % grid on;
% % plot(data(:,35),data(:,15));
% % plot(data(:,35),data(:,3));
% % axis([0,70,1,2])
% % xlabel('Tempo[s]');
% % ylabel('Erro posi��o [m]');
% % legend('Z', 'Zd');
% % 
% % 
figure();
subplot(421)
grid on;
plot(data(:,35),data(:,19));
xlabel('Tempo[s]');
ylabel('$K_1$','interpreter','latex')
legend(['$K_1 = $' num2str(data(end,19))],'interpreter','latex')

subplot(422)
grid on;
plot(data(:,35),data(:,20));
xlabel('Tempo[s]');
ylabel('$K_2$','interpreter','latex')
legend(['$K_2 = $' num2str(data(end,20))],'interpreter','latex')

subplot(423)
grid on;
plot(data(:,35),data(:,21));label('Tempo[s]');
ylabel('$K_3$','interpreter','latex')
legend(['$K_3 = $' num2str(data(end,21))],'interpreter','latex')

subplot(424)
grid on;
plot(data(:,35),data(:,22));
xlabel('Tempo[s]');
ylabel('$K_4$','interpreter','latex')
legend(['$K_4 = $' num2str(data(end,22))],'interpreter','latex')

subplot(425)
grid on;
plot(data(:,35),data(:,23));
xlabel('Tempo[s]');
ylabel('$K_5$','interpreter','latex')
legend(['$K_5 = $' num2str(data(end,23))],'interpreter','latex')

subplot(426)
hold on;
grid on;
plot(data(:,35),data(:,24));
xlabel('Tempo[s]');
ylabel('$K_6$','interpreter','latex')
legend(['$K_6 = $' num2str(data(end,24))],'interpreter','latex')

subplot(427)
hold on;
grid on;
plot(data(:,35),data(:,25));
xlabel('Tempo[s]');
ylabel('$K_7$','interpreter','latex')
legend(['$K_7 = $' num2str(data(end,25))],'interpreter','latex')

subplot(428)
hold on;
grid on;
plot(data(:,35),data(:,26));
xlabel('Tempo[s]');
ylabel('$K_8$','interpreter','latex')
legend(['$K_8 = $' num2str(data(end,26))],'interpreter','latex')

figure();
subplot(421)
grid on;
plot(data(:,35),data(:,27));
xlabel('Tempo[s]');
ylabel('$K_1$','interpreter','latex')
legend(['$K_1 = $' num2str(data(end,27))],'interpreter','latex')

subplot(422)
grid on;
plot(data(:,35),data(:,28));
xlabel('Tempo[s]');
ylabel('$K_2$','interpreter','latex')
legend(['$K_2 = $' num2str(data(end,28))],'interpreter','latex')

subplot(423)
grid on;
plot(data(:,35),data(:,29));
xlabel('Tempo[s]');
ylabel('$K_3$','interpreter','latex')
legend(['$K_3 = $' num2str(data(end,29))],'interpreter','latex')

subplot(424)
grid on;
plot(data(:,35),data(:,30));
xlabel('Tempo[s]');
ylabel('$K_4$','interpreter','latex')
legend(['$K_4 = $' num2str(data(end,30))],'interpreter','latex')

subplot(425)
grid on;
plot(data(:,35),data(:,31));
xlabel('Tempo[s]');
ylabel('$K_5$','interpreter','latex')
legend(['$K_5 = $' num2str(data(end,31))],'interpreter','latex')

subplot(426)
hold on;
grid on;
plot(data(:,35),data(:,32));
xlabel('Tempo[s]');
ylabel('$K_6$','interpreter','latex')
legend(['$K_6 = $' num2str(data(end,32))],'interpreter','latex')

subplot(427)
hold on;
grid on;
plot(data(:,35),data(:,33));
xlabel('Tempo[s]');
ylabel('$K_7$','interpreter','latex')
legend(['$K_7 = $' num2str(data(end,33))],'interpreter','latex')

subplot(428)
hold on;
grid on;
plot(data(:,35),data(:,34));
xlabel('Tempo[s]');
ylabel('$K_8$','interpreter','latex')
legend(['$K_8 = $' num2str(data(end,34))],'interpreter','latex')
