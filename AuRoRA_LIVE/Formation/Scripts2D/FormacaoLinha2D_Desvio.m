clear
close all
clc

try
    fclose(instrfindall)
end

%% Rotina para buscar pasta raiz
PastaAtual = pwd;
PastaRaiz = 'AuRoRA 2018';
cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))

%% Gravar arquivos de txt (ou excel)
NomeArq = datestr(now,30);
cd('DataFiles')
cd('Log_FormacaoLinha2D')
Arq = fopen(['FL2dDesvio_' NomeArq '.txt'],'w');
cd(PastaAtual)

%% Exibi��o do gr�fico
fig = figure(1);
axis([-5 10 -5 5])
pause(1)

%% Cria��o dos rob�s
nRobos = 2;

ID = input('Digite o ID do rob�: ');
A = Pioneer3DX(ID);
B = Pioneer3DX;

A.mJoystick;  % Verifica se joystick est� conectado

%% Posi��o inicial dos rob�s
Xo = input('Digite a posi��o inicial do rob� ([x y psi]): ');
% Xo = [0 -1.25 0];
% A.pPos.X([1 2 6]) = [X(1) ; X(2); X(3)];

%% Conex�o com rob�/simulador
A.mConectar;            % rob�||simulador
A.mDefinirPosturaInicial(Xo');
shg
pause(3)
disp('In�cio..............')

%% Controle de Forma�ao
LF = LineFormation2DCompensador('center');
xsq = .89;%1.2;
ysq = .89;%1.24;
LF.pPos.Qd = [9*xsq 0*ysq xsq pi/2]';
% LF.pPos.Qd = [4 2 1 deg2rad(0)]';

%% Cria��o da rede
Rede = NetDataShare;
tm = tic;
% Verifica se alguma informa��o da rede foi recebida
while isempty(Rede.pMSG.getFrom)
    Rede.mSendMsg(A);
    if toc(tm) > 0.1
        tm = tic;
        Rede.mReceiveMsg;
        
    end
end
disp('Envio com sucesso.....');

%% Inicializa��o de vari�veis
Xa = A.pPos.X(1:6);

U = [];
ke = 0;
kr = 0;
acc = [];   % salva acelera��o calculada

% Temporiza��o
t = tic;
tc = tic;
tp = tic;
timeout = 120;   % tempo m�ximo de dura��o da simula��o

%% C�lculo do erro inicial da forma��o

if length(Rede.pMSG.getFrom) >= 1
    if A.pID > 1       % Caso robo seja ID = 2
        
        % pegar primeiro robo
        if ~isempty(Rede.pMSG.getFrom{1})
            
            Xa = Rede.pMSG.getFrom{1}(14+(1:6)); % rob� 1
            Xb = A.pPos.X((1:6));                % rob� 2
            
            % Posi��o inicial dos rob�s
            LF.pPos.X = [Xa; Xb];
            
        end
    else    % Caso o rob� seja o ID = 1
        
        if length(Rede.pMSG.getFrom) == A.pID+1   % caso haja dados dos dois rob�s na rede
            
            Xa = A.pPos.X(1:6);                       % rob� 1
            Xb = Rede.pMSG.getFrom{A.pID+1}(14+(1:6));  % rob� 2
            
            % Posi��o inicial dos rob�s
            LF.pPos.X = [Xa; Xb];
            
        end
    end
end

% Posi��o inicial da forma��o
LF.mDirTrans;

% Erro da forma��o
LF.pPos.Qtil = LF.pPos.Qd - LF.pPos.Q;
% Tratamento de quadrante
if abs(LF.pPos.Qtil(4)) > pi
    if LF.pPos.Qtil(4) > 0
        LF.pPos.Qtil(4) = -2*pi + LF.pPos.Qtil(4);
    else
        LF.pPos.Qtil(4) =  2*pi + LF.pPos.Qtil(4);
    end
end


%% Simula��o

erroMax = [.05 .05 .05 deg2rad(3)]; % vetor do erro de forma��o

while abs(LF.pPos.Qtil(1))>erroMax(1) || abs(LF.pPos.Qtil(2))>erroMax(2) || ...
        abs(LF.pPos.Qtil(3))>erroMax(3) || abs(LF.pPos.Qtil(4))>erroMax(4)  % erros de forma��o
      
    %% Desvio
    % Mudan�a do �ngulo da forma��o para desvio de obst�culo
    if LF.pPos.Q(1)>=LF.pPos.Qd(1)*.65  % obst�culo a X% do caminho
        
        LF.pPos.Qd(4) = -pi/2;
        
    elseif LF.pPos.Q(1)>=LF.pPos.Qd(1)*.25 % 
        
        LF.pPos.Qd(4) = 0;    
        
    end
    %%
    
    if toc(tc) > 0.1
        
        tcc = tic;

        % Ler Sinais de Controle
        A.mLerDadosSensores;
        
        % Informa��es da Rede
        Rede.mReceiveMsg;
        
        % Buscar SEMPRE rob� com ID+1 para forma��o
        % Vari�vel rob�s da rede
        % Verifica se h� mensagem
        %% Controle de forma��o
        if length(Rede.pMSG.getFrom) >= 1
            % Caso robo seja ID = 2 .....................................
            if A.pID > 1
                
                % pegar primeiro robo
                if ~isempty(Rede.pMSG.getFrom{1})
                    %                     kr = kr + 1;
                    %                     disp([ke kr])
                    
                    Xa = Rede.pMSG.getFrom{1}(14+(1:6));    % rob� 1
                    Xb = A.pPos.X(1:6);                     % rob� 2
                    
                    % Posi��o dos rob�s
                    LF.pPos.X = [Xa; Xb];
                    
                    % Controlador da forma��o
                    LF.mFormationControl;
                    
                    % Posi��o desejada
                    A.pPos.Xd(1:2) = LF.pPos.Xr(3:4);
                    
                    % Atribui sinal de controle ao rob�                                     
                    A.pSC.Ud = LF.pSC.Ud(3:4);
                    
                    % Atribuindo valores desejados do controle de forma��o
                    B.pPos.Xd = Rede.pMSG.getFrom{1}(2+(1:12));
                    B.pPos.X  = Rede.pMSG.getFrom{1}(14+(1:12));
                    B.pSC.Ur  = Rede.pMSG.getFrom{1}(26+(1:2));
                    B.pSC.U   = Rede.pMSG.getFrom{1}(28+(1:2));
                    
                    % Postura do centro do rob�
                    B.pPos.Xc([1 2 6]) = B.pPos.X([1 2 6]) + ...
                        [B.pPar.a*cos(B.pPos.X(6)); B.pPar.a*sin(B.pPos.X(6)); 0];
                    
                    % Armazenar dados no arquivo de texto
                    fprintf(Arq,'%6.6f\t',[A.pPos.Xd' A.pPos.X' A.pSC.Ur' A.pSC.U' ...
                        B.pPos.Xd' B.pPos.X' B.pSC.Ur' B.pSC.U' toc(t)]);
                    fprintf(Arq,'\n\r');
                end
                
                % Caso o rob� seja o ID = 1 ..................................
            else
                
                if length(Rede.pMSG.getFrom) == A.pID+1   % caso haja dados dos dois rob�s na rede
                    
                    Xa = A.pPos.X(1:6);                         % rob� 1
                    Xb = Rede.pMSG.getFrom{A.pID+1}(14+(1:6));  % rob� 2
                    
                    % Posi��o dos rob�s
                    LF.pPos.X = [Xa; Xb];
                    
                    % Controlador da forma��o
                    LF.mFormationControl;
                    
                    % Posi��o desejada
                    A.pPos.Xd(1:2) = LF.pPos.Xr(1:2);
                   
                    % Atribui sinal de controle                 
                    A.pSC.Ud = LF.pSC.Ud(1:2);     
                    
                    % Atribuindo valores desejados do controle de forma��o                    
                    B.pPos.Xd = Rede.pMSG.getFrom{A.pID+1}(2+(1:12));
                    B.pPos.X  = Rede.pMSG.getFrom{A.pID+1}(14+(1:12));
                    B.pSC.Ur  = Rede.pMSG.getFrom{A.pID+1}(26+(1:2));
                    B.pSC.U   = Rede.pMSG.getFrom{A.pID+1}(28+(1:2));
                    
                    % Postura do centro do rob�
                    B.pPos.Xc([1 2 6]) = B.pPos.X([1 2 6]) + ...
                        [B.pPar.a*cos(B.pPos.X(6)); B.pPar.a*sin(B.pPos.X(6)); 0];
                    
                    % Armazenar dados no arquivo de texto
                    fprintf(Arq,'%6.6f\t',[A.pPos.Xd' A.pPos.X' A.pSC.Ur' A.pSC.U' ...
                        B.pPos.Xd' B.pPos.X' B.pSC.Ur' B.pSC.U' toc(t)]);
                    fprintf(Arq,'\n\r');
                end
            end
        end
        
        U = [U [A.pSC.U; B.pSC.U]];  % velocidade dos rob�s
        
        disp('UrA');
        display(A.pSC.Ur);
        
        disp('UrB');
        display(B.pSC.Ur);
        
        
        %% Compensa��o din�mica
        % C�lculo da acelera��o
        %         A.pSC.Ua = A.pSC.U(1:2);                % salva velocidade anterior para c�lculo de acelera��o
        %         A.mLerDadosSensores;                      % l� dados dos sensores do rob�
%         A.pSC.dU = (A.pSC.Ua - A.pSC.U)/.1;   % calcula acelera��o (a=dV/dt)       %
                
        acc = [acc, A.pSC.dU];   % acelera��o
       
        % Compensador din�mico
        A = fCompensadorDinamico(A);
        
        
        %% Envia sinais de controle
      
        A.mEnviarSinaisControle;
      
        % Publicar mensagem na rede
        Rede.mSendMsg(A);
        %         ke = ke + 1;
        
    end
    % Desenha os rob�s
    if toc(tp) > 0.1
        tp = tic;
        
        A.mCADdel
        B.mCADdel
        
        A.mCADplot2D('b')
        B.mCADplot2D('r')
        
        grid on
        drawnow
    end
    
    % Limita tempo de simula��o
    if toc(t)> timeout
        disp('Tempo limite atingido.');
        break
    end
    
end

%% Fechar e Parar
fclose(Arq);

% Envia velocidades 0 para o rob�
A.pSC.Ur = [0 ; 0];
A.mEnviarSinaisControle;
% A.mDesconectar;
% pause

% Para retornar pioneer pelo controle (evitar a fadiga)
A.mJoystick;  % Verifica se joystick est� conectado
while button(A.pSC.Joystick.J,8)==0  
 
    A.mEnviarSinaisControleTeste       
   
end
