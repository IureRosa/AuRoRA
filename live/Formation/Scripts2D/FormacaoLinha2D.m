clear
close all
clc

try
    fclose(instrfindall)
end

% Rotina para buscar pasta raiz
PastaAtual = pwd;
PastaRaiz = 'AuRoRA 2018';
cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
addpath(genpath(pwd))
cd(PastaAtual)

% Exibi��o do gr�fico
fig = figure(1);
axis([-5 8 -8 8])
pause(1)

A = Pioneer3DX(1);
B = Pioneer3DX(2);

% Posi��o inicial dos rob�s
A.pPos.X(1:2) = [-1 ; 0];
B.pPos.X(1:2) = [0 ; 1];

% Controle de Forma�ao
LF = LineFormation2D;
LF.pPos.Qd = [7 0 1 pi/2]';

% Cria��o da rede
Rede = NetDataShare;
Rede.mSendMsg(A);
Rede.mSendMsg(B);

U = [];

% Temporiza��o
t = tic;
tc = tic;
tp = tic;
while toc(t) < 30
    if toc(tc) > 0.1
        tcc = tic;
        
        % Informa��es da Rede
        Rede.mReceiveMsg;
        
        % Buscar SEMPRE rob� com ID+1 para forma��o
        % Vari�vel rob�s da rede       
        if A.pID < length(Rede.pMSG.getFrom)
            if ~isempty(Rede.pMSG.getFrom{A.pID+1})
                Xa = Rede.pMSG.getFrom{A.pID+1}(14+[1 2 7 8]);
            else
                Xa = A.pPos.X([1 2 7 8]);
            end
            Xb = B.pPos.X([1 2 7 8]); 
        end
           
        if B.pID < length(Rede.pMSG.getFrom)
            if ~isempty(Rede.pMSG.getFrom{1})
                Xb = Rede.pMSG.getFrom{1}(14+[1 2 7 8]);
            else
                Xb = B.pPos.X([1 2 7 8]);
            end
            Xa = A.pPos.X([1 2 7 8]);    % rob� 1
        end
        
        [Xda,Xdb] = mFormationControl(LF,Xa,Xb);
        
        % Atribuindo valores desejados do controle de forma��o
        A.pPos.Xd([1 2 7 8]) = Xda;
        B.pPos.Xd([1 2 7 8]) = Xdb;
        
        % Ler Sinais de Controle
        A.mLerDadosSensores;
        B.mLerDadosSensores;
        
        % Controle dos rob�s
        A = fControladorCinematico(A);
        B = fControladorCinematico(B);
        
        % Envia sinais de controel
        A.mEnviarSinaisControle;
        B.mEnviarSinaisControle;
        
        U = [U A.pSC.Ur];
        
        % Publicar mensagem na rede
        Rede.mSendMsg(A);
        Rede.mSendMsg(B);
    end
    if toc(tp) > 0.1
        tp = tic;
        
        A.mCADdel
        B.mCADdel
        
        A.mCADplot2D('b')
        B.mCADplot2D('r')
        grid on
        drawnow
    end
end