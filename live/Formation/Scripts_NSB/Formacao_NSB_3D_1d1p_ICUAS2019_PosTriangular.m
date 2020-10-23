%% Controle de Forma��o Baseado em Espa�o Nulo
% ICUAS 2019
% Mauro S�rgio Mafra e Sara Jorge e Silva

%
% Refer�ncia da forma��o: Pionner
%
% Tarefa priorit�ria sendo controle de forma    (sub�ndice f) 
% Tarefa secund�ria sendo o controle de posi��o (sub�ndice p)
%
% Tarefa 1: qp = [rhof alphaf betaf]'   Jf(x): 3 �ltimas linhas
% Tarefa 2: qf = [xf yf zf]'            Jp(x): 3 primeiras linhas
% Proje��o no espa�o nulo da primeira tarefa: (I-(invJf*Jf))
% Sendo J(x) a Jacobiana da transforma��o direta e invJ sua pseudo inversa
% 
% Lei de Controle 1: qRefPontoi = qPontoi + Ki*qTili
% Lei de Controle 2: qRefPontoi = qPontoi + Li*tanh(pinv(Li)*Ki*qTili)
% Para forma��o desejada constante -> qPontoi = 0
%

% Resetar 
clear all;   
close all;
warning off; 
clc;

%% Look for root folder
PastaAtual = pwd;
PastaRaiz = 'AuRoRA 2018';
cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))

try
    fclose(instrfindall);
end

%% Load Class
try     
    % Load Classes
    P = Pioneer3DX(1);  % Pioneer Instance
    A = ArDrone(2);     % Ardrone Instance        
    NSBF = NullSpace3D;  % Null Space Object Instance
    
    disp('Load All Class...............');
    
catch ME
    disp(' ####   Load Class Issues   ####');
    disp('');
    disp(ME);
end

% Inicilize Drone Object Parameters
sampleTime = 1/30;
A.pPar.Ts = 1/30;
Xod = [1 1 1 0]';
A.pPos.X(1:4) = Xod;


% Inicialize Pioneer 3DX Object Parameters
% Robot/Simulator conection
%P.rConnect;

% Inicialize NSB Object Parameters
NSBF.pPos.X  = [4;-2;0;-4;-2;1];    % real pose [x1 y1 z1 x2 y2 z2]
%NSBF.pPos.Xr = [0;0;0;-2;1;0];    % reference pose [x1 y1 z1 x2 y2 z2]

% ganhos originais
% NSBF.pPar.K1 = 1*diag([0.8 0.8 0.5 0.02 0.015 0.03]);  % kinematic control gain  - controls amplitude
% NSBF.pPar.K2 = 1*diag([0.1 0.1 0.5 0.5 0.5 0.5]);      % kinematic control gain - control saturation

% Ajusted Gains
% NSBF.pPar.K1 = 1*diag([1 1 2 0.9 0.25 0.5]);            % kinematic control gain - controls amplitude
% NSBF.pPar.K2 = 1*diag([0.1 0.1 0.1 0.1 0.1 0.1]);       % kinematic control gain - control saturation

% NSBF.pPar.K1 = 2*diag([1.0 1.0 1.0 0.8 0.08 0.08]);       % kinematic control gain  - controls amplitude
% NSBF.pPar.K2 = 1*diag([0.1 0.1 0.025 0.1 0.01 0.01]);     % kinematic control gain - control saturation

% NSBF.pPar.K1 = 1*diag([1 1 2 1 0.25 0.5]);           % kinematic control gain  - controls amplitude
% NSBF.pPar.K2 = 1*diag([0.1 0.1 0.1 0.1 0.1 0.1]);     % kinematic control gain - control saturation

% Simulation Gain
NSBF.pPar.K1 =   1*diag([1 1 0 1 0.35 0.25]);
NSBF.pPar.K2 = 0.1*diag([2.5 1 1 1 2.0 2.5]);


% kx1 kx2 ky1 ky2 kz1 kz2 ; kPhi1 kPhi2 ktheta1 ktheta2 kPsi1 kPsi2
gains = [0.7 0.8 0.7 0.8 5 2; 1 12 1 12 1 4];   % teste  simulacao Referencia
pGains = [0.75 0.75 0.12 0.035];                % Ganhos do Compensador do Paioneer


% Joystick
J = JoyControl;

%% Open file to save data
NomeArq = datestr(now,30);
cd('DataFiles')
cd('Log_NSB')
Arq = fopen(['NSB_5Pos_' NomeArq '.txt'],'w');
cd(PastaAtual)


%% Variable initialization
data = [];
% Desired formation [xf yf zf rhof alfaf betaf]
% LF.pPos.Qd = [2 -1 0 2 deg2rad(0) deg2rad(90)]';
% Qd = [ 3   2   0   1.5   0   pi/3;
%        2  -2   0   2     pi/2   pi/3;
%       -2  -3   0   1.5   pi/4   pi/3;
%       -2   1   0   2     pi/4   pi/3;
%        0   0   0   1.5   0   pi/3];

% Artigo LARS2018
Qd = [ 2   0   0   1.0   0   pi/2 ];

Xop = [-3 -3 0 0];
P.rSetPose(Xop');

A.pPos.X(1) = 3;
A.pPos.X(2) = -3;
A.pPos.X(3) = 1;


%% Configure simulation window
fig = figure(1);

% plot robots initial positions
plot3(P.pPos.X(1),P.pPos.X(2),P.pPos.X(3),'r^','LineWidth',0.8); hold on;
plot3(A.pPos.X(1),A.pPos.X(2),A.pPos.X(3),'b^','LineWidth',0.8);


% Formation Weighted Error 
NSBF.mFormationWeightedError;


for kk = 1:size(Qd,1)
    % 
    NSBF.pPos.Qd = Qd(kk,:)';
    
    % Get Inverse Matrix 
    NSBF.mInvTrans;
    
    plot3(Qd(:,1),Qd(:,2),Qd(:,3),'r.','MarkerSize',20,'LineWidth',2),hold on;
    plot3(NSBF.pPos.Xd(4),NSBF.pPos.Xd(5),NSBF.pPos.Xd(6),'b.','MarkerSize',20,'LineWidth',2);
    
    % plot  formation line
    xl = [NSBF.pPos.Xd(1)   NSBF.pPos.Xd(4)];
    yl = [NSBF.pPos.Xd(2)   NSBF.pPos.Xd(5)];
    zl = [NSBF.pPos.Xd(3)   NSBF.pPos.Xd(6)];
    
    pl = line(xl,yl,zl);
    pl.Color = 'k';
    pl.LineStyle = '--';
    pl.LineWidth = 1;
    
    axis([-6 6 -6 6 0 4]);
    view(75,15)
    % Draw robot
    % P.mCADplot(1,'k');             % Pioneer
    % A.mCADplot                     % ArDrone
    grid on
    drawnow
end
% pause(3)

%% Formation initial error
% Formation initial pose
NSBF.pPos.X = [P.pPos.X(1:3); A.pPos.X(1:3)];

% Formation initial pose
NSBF.mDirTrans;

% Formation Error
NSBF.mFormationError;

% Formation Weighted Error 
NSBF.mFormationWeightedError;

%% First desired position
NSBF.pPos.Qd = Qd(1,:)';

% Robots desired pose
NSBF.mInvTrans;

% Formation Error
NSBF.pPos.Qtil = NSBF.pPos.Qd - NSBF.pPos.Q;

%% Simulation
% Maximum error permitted
% erroMax = [.1 .1 0 .1 deg2rad(5) deg2rad(5)];

% Time variables initialization
timeout = 150;   % maximum simulation duration
index   = 1;     % Index Counter
time    = 45;    % time to change desired positions [s]

% timeout = size(Qd,1)*time + 30;
t  = tic;
tc = tic;
tp = tic;
t1 = tic;        % pioneer cycle
t2 = tic;        % ardrone cycle


disp('Inicialize Simulation..............');
disp('');

% Loop while error > erroMax
while toc(t)< size(Qd,1)*(time)  %abs(NSB.pPos.Qtil(1))>erroMax(1) || abs(NSB.pPos.Qtil(2))>erroMax(2) || ...
%         abs(NSB.pPos.Qtil(4))>erroMax(4)|| abs(NSB.pPos.Qtil(5))>erroMax(5) ...
%         || abs(NSB.pPos.Qtil(6))>erroMax(6) % formation errors
    
    if toc(tc) > sampleTime        
        tc = tic;      
        
        % Formation Error
        NSBF.pPos.Qtil = NSBF.pPos.Qd - NSBF.pPos.Q;

        %% Acquire sensors data
        P.rGetSensorData;    % Pioneer
        A.rGetSensorData;    % ArDrone        
        
        %% Control
        % Formation Members Position        
        NSBF.mSetPose(P,A);
                
        % Formation Control
%          NSBF.mFormationControl;  % Forma��o Convencional 
        NSBF.mFormationPriorityControl;
%         NSBF.mPositionPriorityControl;
               
        % Desired position ...........................................
        NSBF.mInvTrans;
        
        % Pioneer
        P.pPos.Xd(1:3) = NSBF.pPos.Xr(1:3);         % desired position
        P.pPos.Xd(7:9) = NSBF.pPos.dXr(1:3);        % desired position
        
        % *Nota para Valentim: Para usar o fCompensadorDinamico tem que usar
        % a cinem�tica inversa abaixo para obter Ur. Eu acabei tirando isso
        % e usando o controlador din�mico porque ele faz essa convers�o.
        % Mas realmente o mais certo � usar o compensador. 
        sInvKinematicModel(P,NSBF.pPos.dXr(1:2));  % sem essa convers�o o compensador n�o tem o valor de pSC.Ur, por isso o pioneer estava ficando parado
        
        % Drone
        A.pPos.Xda = A.pPos.Xd;    % save previous posture
        A.pPos.Xd(1:3) = NSBF.pPos.Xd(4:6);
        A.pPos.Xd(7:9) = NSBF.pPos.dXr(4:6);
        
        A = cUnderActuatedController(A,gains);  % ArDrone
        A = J.mControl(A);                      % joystick command (priority)
        
        P = fCompensadorDinamico(P);
        
        % Get Performace Scores       
        NSBF.mFormationPerformace(sampleTime,toc(t),index);                                      
        
        % Save data (.txt file)
        fprintf(Arq,'%6.6f\t',[P.pPos.Xd' P.pPos.X' P.pSC.Ud(1:2)' P.pSC.U(1:2)' ...
            A.pPos.Xd' A.pPos.X' A.pSC.Ud' A.pSC.U' NSBF.pPos.Qd' NSBF.pPos.Qtil' toc(t)]);
        fprintf(Arq,'\n\r');
        
        % Variable to feed plotResults function
        data = [data; P.pPos.Xd' P.pPos.X' P.pSC.Ud(1:2)' P.pSC.U(1:2)' ...
            A.pPos.Xd' A.pPos.X' A.pSC.Ud' A.pSC.U' NSBF.pPos.Qd' NSBF.pPos.Qtil' toc(t)];
        
        % Send control signals to robots
        P.rSendControlSignals;
        A.rSendControlSignals;
        
        % Increment Counter
        index = index + 1;   
                
    end
    
    
    % Draw robot
    %if toc(tp) > inf
    if toc(tp) > 0.5
        tp = tic;
        try
            delete(fig1);
            delete(fig2);
        catch
        end
        P.mCADdel                      % Pioneer
        P.mCADplot(1,'k');             % Pioneer modelo bonit�o
        A.mCADplot;                    % ArDrone
        
        % Percourse made
        fig1 = plot3(data(:,13),data(:,14),data(:,15),'r-','LineWidth',0.8); hold on;
        fig2 = plot3(data(:,41),data(:,42),data(:,43),'b-','LineWidth',0.8);
        
%       view(75,30)
        axis([-6 6 -6 6 0 4]);
        grid on
        drawnow
        view(-21,30)
    end
    
    % Simulation timeout
    if toc(t)> size(Qd,1)*timeout
        disp('Timeout man!');
        break
    end
        
end

%% Close file and stop robot
fclose(Arq);

% Send control signals
P.pSC.Ud = [0; 0];
P.rSendControlSignals;    % Pioneer

%% Plot results
% figure;
%plotResults(data);

% figure;
NSB_PlotResults(data,1,"Conventional");
NSBF.mDisplayFormationPerformace("Conventional");
 
 
% End of code xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




