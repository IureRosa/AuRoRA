close all
clear all
clc

try
    fclose(instrfindall);
catch
end
%% ADD TO PATH
% PastaAtual = pwd;
% PastaRaiz = 'AuRoRA 2018';
% cd(PastaAtual(1:(strfind(PastaAtual,PastaRaiz)+numel(PastaRaiz)-1)))
% addpath(genpath(pwd))

%% INICIO DO PROGRAMA
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -% 
% Vari�veis iniciais
phi = 0;
psi = rand*pi;
beta = pi/3*(rand + pi/4);
raio = 3;

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -% 
% Forma��o Inicial
Q = [0;              % x
     0;              % y
     0;              % z
     phi;            % phi
     0;              % tetha
     psi;            % psi
     beta;           % beta
     raio;           % p
     raio];          % q
    
Qd = Q;

% Posi��o dos Rob�s
X = FT_inversa(Q);

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -% 
% Esfera limite
E = 0:0.1:pi;

X_E = [raio*cos(psi)*cos(E);
       raio*sin(psi)*cos(E);
       raio*sin(E)];
   
% R rotaciona em rela��o ao eixo-z
R = [cos(pi/10)  -sin(pi/10)  0;
     sin(pi/10)  cos(pi/10)   0;
     0           0            1];
 
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -% 
% Figura da simula��o
figure
H(1) = plot3([X(1) X(4)],[X(2) X(5)],[X(3) X(6)],'b');
hold on
H(2) = plot3([X(1) X(7)],[X(2) X(8)],[X(3) X(9)],'b');
H(3) = plot3([X(4) X(7)],[X(5) X(8)],[X(6) X(9)],'r');
grid on

% for i=1:10
for i=1:(size(X_E,2)-1)
    plot3([X_E(1,i) X_E(1,i+1)],[X_E(2,i) X_E(2,i+1)],[X_E(3,i) X_E(3,i+1)],'k');
end
%     X_E = R*X_E;
% end

axis([-5 5 -5 5 0 5])
axis equal
view([-50 30])

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -% 
% Vari�veis iniciais
Tmax = 2;
ta = 0.1;
tp = 0.1;
t1 = tic;
t2 = tic;
% A.pPar.ti = tic;

pause
t = tic;
%% SIMULA��O
while toc(t) < Tmax
    if toc(t1) > ta
        t1 = tic;
        
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -% 
        % TRAJETORIA DA FORMA��O
        Qd = [0;              % x
            0;                % y
            0;                % z
            -beta*toc(t)/Tmax;% phi
            0;                % tetha
            psi;              % psi
            beta;             % beta
            raio;             % p
            raio];            % q
        
        Q = Qd;
        
        X = FT_inversa(Q);
        
        try
            delete(H);
        end
        
        H(1) = plot3([X(1) X(4)],[X(2) X(5)],[X(3) X(6)],'b');
        H(2) = plot3([X(1) X(7)],[X(2) X(8)],[X(3) X(9)],'b');
        H(3) = plot3([X(4) X(7)],[X(5) X(8)],[X(6) X(9)],'r');
        
        drawnow
    end
end
