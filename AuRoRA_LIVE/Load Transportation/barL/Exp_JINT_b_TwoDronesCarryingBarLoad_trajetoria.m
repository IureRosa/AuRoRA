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
    RI = RosInterface;
    RI.rConnect('192.168.0.144');
    
    % Create OptiTrack object and initialize
    OPT = OptiTrack;
    OPT.Initialize;
    
    % Initiate classes
    B{1} = Bebop(1,'B1');
    B{2} = Bebop(2,'B2');
    L = Load;
    idB1 = getID(OPT,B{1},1); % ID do Bebop
    idB2 = getID(OPT,B{2},2); % ID do Bebop
    idL = getID(OPT,Load);

    
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
T = 15;             % [s]
w = 2*pi/T;         % [rad/s]

% Time variables initialization
Xd = [0 0 0 0];
dXd = [0 0 0 0];

fprintf('\nStart..............\n\n');

pause(3)

B{1}.pPar.Model_simp = [ 0.8417 0.18227 0.8354 0.17095 3.966 4.001 9.8524 4.7295  ]';
B{2}.pPar.Model_simp = [ 0.8417 0.18227 0.8354 0.17095 3.966 4.001 9.8524 4.7295  ]';
%% Variable Initialization
barL.pPos.X = zeros(6,1);
barL.pPos.Xd = zeros(6,1);
barL.pPos.Xr = zeros(6,1);

barL.pPos.dXr = zeros(6,1);
barL.pPos.dXd = zeros(6,1);

barL.pPos.X_load = zeros(6,1);

barL.pPos.Qd = zeros(6,1);

%% Par�metros da Carga barL 
% Comprimento dos cabos
barL.pPar.l1 = 1.236;
barL.pPar.l2 = 1.254;

% Comprimento da barL
barL.pPar.L = 1.45;  

% Massa da barL
barL.pPar.m = .155;      %Kg

% Beboop
disp('Start Take Off Timming....');
B{1}.rTakeOff;
B{2}.rTakeOff;
pause(5);
disp('Taking Off End Time....');

%% TAREFA: Posi��o desejada nas vari�veis generalizadas Q = (xc,yc,zc,alpha,gamma,L)
barL.pPos.Qd = [0 .5 .45 deg2rad(0) deg2rad(0) barL.pPar.L]';

% Transforma��o inversa Q -> X, i.e., (xc,yc,zc,alpha,gamma,L)_d-> (x1,y1,z1,x2,y2,z2)_d
barL.pPos.Xd(1) = barL.pPos.Qd(1) - cos(barL.pPos.Qd(5))*sin(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(2) = barL.pPos.Qd(2) - cos(barL.pPos.Qd(5))*cos(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(3) = barL.pPos.Qd(3) - sin(barL.pPos.Qd(5))*barL.pPos.Qd(6)/2 + barL.pPar.l1;
barL.pPos.Xd(4) = barL.pPos.Qd(1) + cos(barL.pPos.Qd(5))*sin(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(5) = barL.pPos.Qd(2) + cos(barL.pPos.Qd(5))*cos(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
barL.pPos.Xd(6) = barL.pPos.Qd(3) + sin(barL.pPos.Qd(5))*barL.pPos.Qd(6)/2 + barL.pPar.l2;
barL.pPos.dXd = [dXd(1) dXd(2) dXd(3) dXd(1) dXd(2) dXd(3)]';

% Povoando a vari�vel X e X_load da classe
barL.pPos.X = [B{1}.pPos.X(1:3); B{2}.pPos.X(1:3)];
% barL.pPos.X_load = [L{1}.pPos.X(1) L{1}.pPos.X(2) L{1}.pPos.X(3) L{2}.pPos.X(1) L{2}.pPos.X(2) L{2}.pPos.X(3)]';

% C�lculo do erro nos drones
barL.pPos.Xtil = barL.pPos.Xd - barL.pPos.X;

% timers
T_exp1 = 5; % tempo estabiliza��o
T_exp2 = 30; % tempo trajet�ria leminiscata T = 30, 1 volta
T_exp3 = 5; % tempo pausa
T_exp4 = 32; % tempo trajet�ria leminiscata T = 16, 2 voltas
T_exp5 = 10; % tempo pausa
T_exp = T_exp1 + T_exp2 + T_exp3 + T_exp4 + T_exp5; % tempo de experimento
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

B{1}.pPar.ti = tic;
B{2}.pPar.ti = tic;
L.pPar.ti = tic;
B{1}.pPar.Ts = 1/30;
B{2}.pPar.Ts = 1/30;
L.pPar.Ts = 1/30;

try
    while toc(t) < T_exp
        
        if toc(t_run) > T_run
            
            t_run = tic;
            t_atual = toc(t);

            
% %Trajet�ria           
%% Ciclo 1
            if t_atual < T_exp1

                
                Xd = [0;
                    0;
                    .35;
                    0];

                dXd = [0;
                    0;
                    0;
                    0];
                

            end

            if t_atual > T_exp1 && t_atual < (T_exp1 + T_exp2)
                
                T = 15;             % [s]
                w = 2*pi/T;         % [rad/s]
                
                Xd = [rX*sin(w*(t_atual - T/2 - T_exp1));
                    rY*cos(0.5*w*(t_atual - T/2 - T_exp1));
                    .35 + 0.35*sin(w*(t_atual - T/2 - T_exp1));
                    0];

                dXd = [w*rX*cos(w*(t_atual - T/2 - T_exp1));
                    -0.5*w*rY*sin(0.5*w*(t_atual - T/2 - T_exp1));
                    w*0.35*cos(w*(t_atual - T/2 - T_exp1));
                    0];
            end
%% Ciclo 2
            if t_atual > (T_exp1 + T_exp2) && t_atual < (T_exp1 + T_exp2 + T_exp3)
                Xd = [0;
                    0;
                    .35;
                    0];

                dXd = [0;
                    0;
                    0;
                    0];
            end
            
                
            if t_atual > (T_exp1 + T_exp2 + T_exp3) && t_atual < (T_exp1 + T_exp2 + T_exp3 + T_exp4)
                 
                T = 8;             % [s]
                w = 2*pi/T;         % [rad/s]
                
                Xd = [rX*sin(w*(t_atual - T/2 - (T_exp1 + T_exp2 + T_exp3)));
                    rY*cos(0.5*w*(t_atual - T/2 - (T_exp1 + T_exp2 + T_exp3)));
                    .35 + 0.35*sin(w*(t_atual - T/2 - (T_exp1 + T_exp2 + T_exp3)));
                    0];

                dXd = [w*rX*cos(w*(t_atual - T/2 - (T_exp1 + T_exp2 + T_exp3)));
                    -0.5*w*rY*sin(0.5*w*(t_atual - T/2 - (T_exp1 + T_exp2 + T_exp3)));
                    w*0.35*cos(w*(t_atual - T/2 - (T_exp1 + T_exp2 + T_exp3)));
                    0];
            end
            
              if t_atual > (T_exp1 + T_exp2 + T_exp3 + T_exp4) && t_atual < T_exp
               Xd = [0;
                    0;
                    .35;
                    0];

                dXd = [0;
                    0;
                    0;
                    0];
              
              end


             
                
                %% TAREFA: Posi��o desejada nas vari�veis generalizadas Q = (xc,yc,zc,alpha,gamma,L)
                barL.pPos.Qd = [Xd(1) Xd(2) Xd(3) deg2rad(0) deg2rad(0) barL.pPar.L]';
                
                % Transforma��o inversa Q -> X, i.e., (xc,yc,zc,alpha,gamma,L)_d-> (x1,y1,z1,x2,y2,z2)_d
                barL.pPos.Xd(1) = barL.pPos.Qd(1) - cos(barL.pPos.Qd(5))*sin(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
                barL.pPos.Xd(2) = barL.pPos.Qd(2) - cos(barL.pPos.Qd(5))*cos(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
                barL.pPos.Xd(3) = barL.pPos.Qd(3) - sin(barL.pPos.Qd(5))*barL.pPos.Qd(6)/2 + barL.pPar.l1;
                barL.pPos.Xd(4) = barL.pPos.Qd(1) + cos(barL.pPos.Qd(5))*sin(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
                barL.pPos.Xd(5) = barL.pPos.Qd(2) + cos(barL.pPos.Qd(5))*cos(barL.pPos.Qd(4))*barL.pPos.Qd(6)/2;
                barL.pPos.Xd(6) = barL.pPos.Qd(3) + sin(barL.pPos.Qd(5))*barL.pPos.Qd(6)/2 + barL.pPar.l2;
                barL.pPos.dXd = [dXd(1) dXd(2) dXd(3) dXd(1) dXd(2) dXd(3)]';
                

        % Povoando a vari�vel X e X_load da classe
        barL.pPos.X = [B{1}.pPos.X(1:3); B{2}.pPos.X(1:3)];
%         barL.pPos.X_load = [L{1}.pPos.X(1) L{1}.pPos.X(2) L{1}.pPos.X(3) L{2}.pPos.X(1) L{2}.pPos.X(2) L{2}.pPos.X(3)]';

        % C�lculo do erro nos drones
        barL.pPos.Xtil = barL.pPos.Xd - barL.pPos.X;
    
        %% Atribuindo miss�o
        %% Obter os dados dos sensores
        
        % OPTITRACK
        rb = OPT.RigidBody;
        if rb(idB1).isTracked
            B{1} = getOptData(rb(idB1),B{1});
        end
%         
        if rb(idB2).isTracked
            B{2} = getOptData(rb(idB2),B{2});
        end
       
        if rb(idL).isTracked
            L = getOptData(rb(idL),L);
        end
        % OPTITRACK - ROS
%         B{1}.rGetSensorDataOpt;
%         B{2}.rGetSensorDataOpt;
%         
        % Atribuindo trajet�ria
        B{1}.pPos.Xd(1:3) = barL.pPos.Xd(1:3);
        B{2}.pPos.Xd(1:3) = barL.pPos.Xd(4:6);
        
        B{1}.pPos.Xd(7:9) = barL.pPos.dXd(1:3);
        B{2}.pPos.Xd(7:9) = barL.pPos.dXd(4:6);
        


        % Controle
        if size(data,1) > 90 && B{1}.pSC.Control_flag == 0 
            B{1}.pSC.Control_flag = 1;
            B{2}.pSC.Control_flag = 1;
        end
           
%         B{1}.cInverseDynamicController_Compensador;
        B{1}.cInverseDynamicController_Adaptativo;

%           B{2}.cInverseDynamicController_Compensador;
        B{2}.cInverseDynamicController_Adaptativo;

          
        B{1}.pPar.ti = tic;
        B{2}.pPar.ti = tic;
        L.pPar.ti = tic;
            
            %% Save data
            
%             % Variable to feed plotResults function
            data = [  data  ; B{1}.pPos.Xd(1:3)'     B{1}.pPos.X(1:3)' ...
                              B{2}.pPos.Xd(1:3)'     B{2}.pPos.X(1:3)' L.pPos.X(1:6)'  ...
                              B{1}.pPar.Model_simp'  B{2}.pPar.Model_simp' barL.pPos.Qd' t_atual];
            
            %         %   1 -- 3      4 -- 6     
            %         B{1}.pPos.Xd'  B{1}.pPos.X' 
            %
            %         %   7 -- 9     10 -- 12        13 -- 18
            %         B{2}.pPos.Xd'  B{2}.pPos.X' L.pPos.X_load'
            %
            %         %  19 -- 26             27 -- 34        35 -- 40          41
            %      B{1}.pPar.Model_simp  B{2}.pPar.Model_simp  barL.pPos.Qd   t_atual ];
            
            
            % Beboop
            % Joystick Command Priority
            B{1} = J.mControl(B{1});                    % joystick command (priority)
            B{1}.rCommand;
            B{2} = J.mControl(B{2});                    % joystick command (priority)
            B{2}.rCommand;
            
            
            
            % If push Emergency or ROS Emergency Stop On or Not Rigid Body tracked Stop loop
            if btnEmergencia ~= 0 || B{1}.pFlag.EmergencyStop ~= 0 || B{1}.pFlag.isTracked ~= 1
                disp('Bebop Landing through Emergency Command ');

                % Send 3 times Commands 1 second delay to Drone Land
                for i=1:nLandMsg
                    disp('End Land Command');
                    B{1}.rCmdStop;
                    B{1}.rLand;
                end
                break;
            end
            
            
            % If push Emergency or ROS Emergency Stop On or Not Rigid Body tracked Stop loop
            if btnEmergencia ~= 0 || B{2}.pFlag.EmergencyStop ~= 0 || B{2}.pFlag.isTracked ~= 1
                disp('Bebop Landing through Emergency Command ');

                % Send 3 times Commands 1 second delay to Drone Land
                for i=1:nLandMsg
                    disp('End Land Command');
                    B{2}.rCmdStop;
                    B{2}.rLand;
                end
                break;
            end
        end
    end
catch ME
    
    disp('Bebop Landing through Try/Catch Loop Command');
    B{1}.rCmdStop;
    disp('');
    disp(ME);
    disp('');
    B{1}.rLand
    
    disp('Bebop Landing through Try/Catch Loop Command');
    B{2}.rCmdStop;
    disp('');
    disp(ME);
    disp('');
    B{2}.rLand
    
end

% Send 3 times Commands 1 second delay to Drone Land
for i=1:nLandMsg
    disp('End Land Command');
    B{1}.rCmdStop;
    B{1}.rLand
    
    disp('End Land Command');
    B{2}.rCmdStop;
    B{2}.rLand
end


% Close ROS Interface
RI.rDisconnect;
rosshutdown;

disp('"Ros Shutdown completed..."');

% %% PLOT
B1_Xtil = data(:,1:3) - data(:,4:6);
B2_Xtil = data(:,7:9) - data(:,10:12);
Load_Xtil = [data(:,35:37)-data(:,13:15) data(:,38)-data(:,18) data(:,39)-data(:,16)];

Load_Xtil(:,1) = Load_Xtil(:,1) + .05;
Load_Xtil(:,2) = Load_Xtil(:,2) + .08;
Load_Xtil(:,3) = Load_Xtil(:,3) + .12;


% 
figure();
hold on;
grid on;
plot(data(:,end),B1_Xtil(:,1));
plot(data(:,end),B1_Xtil(:,2));
plot(data(:,end),B1_Xtil(:,3));
title('Q1 position error');
legend('$\tilde{x}$','$\tilde{y}$','$\tilde{z}$','interpreter','latex');
xlabel('Time [s]');
ylabel('Error [m]');

figure();
hold on;
grid on;
plot(data(:,end),B2_Xtil(:,1));
plot(data(:,end),B2_Xtil(:,2));
plot(data(:,end),B2_Xtil(:,3));
title('Q2 position error');
legend('$\tilde{x}$','$\tilde{y}$','$\tilde{z}$','interpreter','latex');
xlabel('Time [s]');
ylabel('Error [m]');

figure();
hold on;
grid on;
plot(data(:,end),Load_Xtil(:,1));
plot(data(:,end),Load_Xtil(:,2));
plot(data(:,end),Load_Xtil(:,3));
% plot(data(:,end),rad2deg(Load_Xtil(:,4))+2.5-90);
% plot(data(:,end),rad2deg(Load_Xtil(:,5))-17);
title('Load Position error');
legend('$\tilde{x}$','$\tilde{y}$','$\tilde{z}$','$\alpha$','$\beta$','interpreter','latex');
xlabel('Time [s]');
ylabel('Error [m]');

figure();
hold on;
grid on;
plot(data(:,end),rad2deg(Load_Xtil(:,4))+2.5-90);
plot(data(:,end),rad2deg(Load_Xtil(:,5))-17);
title('Load orientation error');
legend('$\alpha$','$\beta$','interpreter','latex');
xlabel('Time [s]');
ylabel('Error [�]');


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
% % plot(data(:,end),data(:,19));
% % plot(data(:,end),data(:,7));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [m/s]');
% % legend('dX', 'dXd');
% % 
% % subplot(412)
% % hold on;
% % grid on;
% % plot(data(:,end),data(:,20));
% % plot(data(:,end),data(:,8));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [m/s]');
% % legend('dY', 'dYd');
% % 
% % subplot(413)
% % hold on;
% % grid on;
% % plot(data(:,end),data(:,21));
% % plot(data(:,end),data(:,9));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [m/s]');
% % legend('dZ', 'dZd');
% % 
% % subplot(414)
% % hold on;
% % grid on;
% % plot(data(:,end),data(:,24));
% % plot(data(:,end),data(:,12));
% % xlabel('Tempo[s]');
% % ylabel('Velocidade [rad/s]');
% % legend('phi', 'dphi');
% % 
% % 
%% LOAD POSITION %%
figure();
sgtitle('LOAD')
subplot(311)
hold on;
grid on;
plot(data(:,end),data(:,35));
plot(data(:,end),data(:,13)-.05);
legend('$x$','$x_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(312)
hold on;
grid on;
plot(data(:,end),data(:,36));
plot(data(:,end),data(:,14)-.08);
legend('$y$','$y_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(313)
hold on;
grid on;
plot(data(:,end),data(:,37));
plot(data(:,end),data(:,15)-.12);
legend('$z$','$z_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

%% LOAD VELOCITY %%
figure();
sgtitle('LOAD VEL')
subplot(311)
hold on;
grid on;
plot(data(2:5:end,end),vel_load(:,1));
plot(data(2:5:end,end),vel(:,1));
axis([0 data(end,end) -.5 .5])
legend('$x$','$x_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(312)
hold on;
grid on;
plot(data(2:5:end,end),vel_load(:,2));
plot(data(2:5:end,end),vel(:,2));
axis([0 data(end,end) -.5 .5])
legend('$y$','$y_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(313)
hold on;
grid on;
plot(data(2:5:end,end),vel_load(:,3));
plot(data(2:5:end,end),vel(:,3));
axis([0 data(end,end) -.5 .5])
legend('$z$','$z_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');
%% POSITION Q1 %%
figure();
sgtitle('Q1')
subplot(311)
hold on;
grid on;
plot(data(:,end),data(:,4));
plot(data(:,end),data(:,1));
legend('$x$','$x_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(312)
hold on;
grid on;
plot(data(:,end),data(:,5));
plot(data(:,end),data(:,2));
legend('$y$','$y_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(313)
hold on;
grid on;
plot(data(:,end),data(:,6));
plot(data(:,end),data(:,3));
legend('$z$','$z_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

%% VELOCITY Q1 %%

figure();
sgtitle('Q1')
subplot(311)
hold on;
grid on;
plot(data(2:5:end,end),vel(:,4));
plot(data(2:5:end,end),vel(:,1));
axis([0 data(end,end) -.5 .5])
legend('$x$','$x_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('vel [m/s]');

subplot(312)
hold on;
grid on;
plot(data(2:5:end,end),vel(:,5));
plot(data(2:5:end,end),vel(:,2));
axis([0 data(end,end) -.5 .5])
legend('$y$','$y_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('vel [m/s]');

subplot(313)
hold on;
grid on;
plot(data(2:5:end,end),vel(:,6));
plot(data(2:5:end,end),vel(:,3));
axis([0 data(end,end) -.5 .5])
legend('$z$','$z_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('vel [m/s]');

%% ACCELERATION Q1 %%
figure();
sgtitle('Q1')
subplot(311)
hold on;
grid on;
plot(data(3:5:end,end),acc(:,4));
plot(data(3:5:end,end),acc(:,1));
axis([0 data(end,end) -.5 .5])
legend('$x$','$x_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('acc [m/s]');

subplot(312)
hold on;
grid on;
plot(data(3:5:end,end),acc(:,5));
plot(data(3:5:end,end),acc(:,2));
axis([0 data(end,end) -.5 .5])
legend('$y$','$y_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('acc [m/s]');

subplot(313)
hold on;
grid on;
plot(data(3:5:end,end),acc(:,6));
plot(data(3:5:end,end),acc(:,3));
axis([0 data(end,end) -.5 .5])
legend('$z$','$z_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('acc [m/s]');

%% POSITION Q2 %%
figure();
sgtitle('Q2')
subplot(311)
hold on;
grid on;
plot(data(:,end),data(:,10));
plot(data(:,end),data(:,7));
legend('$x$','$x_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(312)
hold on;
grid on;
plot(data(:,end),data(:,11));
plot(data(:,end),data(:,8));
legend('$y$','$y_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

subplot(313)
hold on;
grid on;
plot(data(:,end),data(:,12));
plot(data(:,end),data(:,9));
legend('$z$','$z_d$','interpreter','latex');
xlabel('Time [s]');
ylabel('Position [m]');

%% PARAMETERS Q1 %%
figure();
subplot(421)
grid on;
plot(data(:,end),data(:,19));
xlabel('Time [s]');
ylabel('$K_1$','interpreter','latex');
legend(['$K_1 = $' num2str(data(end,19))],'interpreter','latex')

subplot(422)
grid on;
plot(data(:,end),data(:,20));
xlabel('Time [s]');
ylabel('$K_2$','interpreter','latex');
legend(['$K_2 = $' num2str(data(end,20))],'interpreter','latex')

subplot(423)
grid on;
plot(data(:,end),data(:,21));
xlabel('Time [s]');
ylabel('$K_3$','interpreter','latex');
legend(['$K_3 = $' num2str(data(end,21))],'interpreter','latex')

subplot(424)
grid on;
plot(data(:,end),data(:,22));
xlabel('Time [s]');
ylabel('$K_4$','interpreter','latex');
legend(['$K_4 = $' num2str(data(end,22))],'interpreter','latex')

subplot(425)
grid on;
plot(data(:,end),data(:,23));
xlabel('Time [s]');
ylabel('$K_5$','interpreter','latex');
legend(['$K_5 = $' num2str(data(end,23))],'interpreter','latex')

subplot(426)
hold on;
grid on;
plot(data(:,end),data(:,24));
xlabel('Time [s]');
ylabel('$K_6$','interpreter','latex');
legend(['$K_6 = $' num2str(data(end,24))],'interpreter','latex')

subplot(427)
hold on;
grid on;
plot(data(:,end),data(:,25));
xlabel('Time [s]');
ylabel('$K_7$','interpreter','latex');
legend(['$K_7 = $' num2str(data(end,25))],'interpreter','latex')

subplot(428)
hold on;
grid on;
plot(data(:,end),data(:,26));
xlabel('Time [s]');
ylabel('$K_8$','interpreter','latex');
legend(['$K_8 = $' num2str(data(end,26))],'interpreter','latex')

%% PARAMETERS Q2 %%
figure();
subplot(421)
grid on;
plot(data(:,end),data(:,27));
xlabel('Time [s]');
ylabel('$K_1$','interpreter','latex');
legend(['$K_1 = $' num2str(data(end,27))],'interpreter','latex')

subplot(422)
grid on;
plot(data(:,end),data(:,28));
xlabel('Time [s]');
ylabel('$K_2$','interpreter','latex');
legend(['$K_2 = $' num2str(data(end,28))],'interpreter','latex')

subplot(423)
grid on;
plot(data(:,end),data(:,29));
xlabel('Time [s]');
ylabel('$K_3$','interpreter','latex');
legend(['$K_3 = $' num2str(data(end,29))],'interpreter','latex')

subplot(424)
grid on;
plot(data(:,end),data(:,30));
xlabel('Time [s]');
ylabel('$K_4$','interpreter','latex');
legend(['$K_4 = $' num2str(data(end,30))],'interpreter','latex')

subplot(425)
grid on;
plot(data(:,end),data(:,31));
xlabel('Time [s]');
ylabel('$K_5$','interpreter','latex');
legend(['$K_5 = $' num2str(data(end,31))],'interpreter','latex')

subplot(426)
hold on;
grid on;
plot(data(:,end),data(:,32));
xlabel('Time [s]');
ylabel('$K_6$','interpreter','latex');
legend(['$K_6 = $' num2str(data(end,32))],'interpreter','latex')

subplot(427)
hold on;
grid on;
plot(data(:,end),data(:,33));
xlabel('Time [s]');
ylabel('$K_7$','interpreter','latex');
legend(['$K_7 = $' num2str(data(end,33))],'interpreter','latex')

subplot(428)
hold on;
grid on;
plot(data(:,end),data(:,34));
xlabel('Time [s]');
ylabel('$K_8$','interpreter','latex');
legend(['$K_8 = $' num2str(data(end,34))],'interpreter','latex')



