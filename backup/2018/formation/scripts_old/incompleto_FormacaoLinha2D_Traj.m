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
hold on; grid on; 
axis([-4 4 -4 4])
pause(1)

A = Pioneer3DX(1);
B = Pioneer3DX(2);

% Posi��o inicial dos rob�s
A.pPos.X(1:2) = [-1 ; 0];
B.pPos.X(1:2) = [0 ; 1];

% Controle de Forma�ao
F = LineFormation2D;
F.pPos.Qd = [0 0 1 pi/2]';

% Cria��o da rede
Rede = NetDataShare;
Rede.mSendMsg(A);
Rede.mSendMsg(B);

U = [];
XX = [];

% Dados da Trajet�ria
a = 3;
b = 2;
wrobo = 0.75; % Dados do rob�

wmax = wrobo/sqrt(a^2+4*b^2);

perc = 0.5;
w = perc*wmax;

nvoltas = 1;
tsim = 2*pi*nvoltas/w;

rastroMax = 1000;
rastroA = diag(A.pPos.X(1:2))*ones(2,rastroMax);
rastroB = diag(B.pPos.X(1:2))*ones(2,rastroMax);
rastroF = diag(F.pPos.Qd(1:2))*ones(2,rastroMax);

% Temporiza��o
t = tic;
tc = tic;
tp = tic;
while toc(t) < tsim
    if toc(tc) > 0.1
        tcc = tic;
        
        F.pPos.Qd(1)  = a*sin(w*toc(t));
        F.pPos.Qd(2)  = b*sin(2*w*toc(t));
        F.pPos.dQd(1) = a*w*cos(w*toc(t));
        F.pPos.dQd(2) = 2*b*w*cos(2*w*toc(t));
        
        % Informa��es da Rede
        Rede.mReceiveMsg;
        
        % Buscar SEMPRE rob� com ID+1 para forma��o
        % Vari�vel rob�s da rede       
        if A.pID < length(Rede.pMSG.getFrom)
            if ~isempty(Rede.pMSG.getFrom{A.pID+1})
                Xa = Rede.pMSG.getFrom{A.pID+1}(14+[1 2 7 8]);
            else
                disp('+++++++++++')
                Xa = A.pPos.X([1 2 7 8]);
            end
        end
           
        if A.pID < length(Rede.pMSG.getFrom)
            if ~isempty(Rede.pMSG.getFrom{1})
                Xb = Rede.pMSG.getFrom{1}(14+[1 2 7 8]);
            else
                disp('------------')
                Xb = B.pPos.X([1 2 7 8]);
            end
        end
        
        display([Xa Xb])
        
        [Xda,Xdb] = mFormationControl(F,Xa,Xb);
        
        % Atribuindo valores desejados do controle de forma��o
        A.pPos.Xd([1 2 7 8]) = Xda;
        B.pPos.Xd([1 2 7 8]) = Xdb;
        
        % Ler Sinais de Controle
        A.mLerDadosSensores;
        B.mLerDadosSensores;
        
        % Controle dos rob�s
        A = fControladorPosicao(A);
        B = fControladorPosicao(B);
        
        % Envia sinais de controel
        A.mEnviarSinaisControle;
        B.mEnviarSinaisControle;
        
        XX = [XX [Xa;Xb]];
        U = [U A.pSC.Ur];
        
        % Atualiza��o do rastro
        rastroA = [rastroA(:,2:end) A.pPos.X(1:2)];
        rastroB = [rastroB(:,2:end) B.pPos.Xd(1:2)];
        rastroF = [rastroF(:,2:end) F.pPos.Qd(1:2)];
        
        % Publicar mensagem na rede
        Rede.mSendMsg(A);
        Rede.mSendMsg(B);
    end
    if toc(tp) > 0.1
        tp = tic;
        
        A.mCADdel
        B.mCADdel
        
        try
            delete(rastrofig)
        end
        
        A.mCADplot2D('b')
        B.mCADplot2D('r')
        
        rastrofig(1) = plot(rastroA(1,:),rastroA(2,:),'b-');
        rastrofig(2) = plot(rastroB(1,:),rastroB(2,:),'r-');                
        rastrofig(3) = plot(rastroF(1,:),rastroF(2,:),'g--');                
        drawnow
    end
end