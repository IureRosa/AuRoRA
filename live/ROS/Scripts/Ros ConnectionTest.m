%% Controle de Forma��o Baseado em Espa�o Nulo
% ICUAS 2019
% Mauro S�rgio Mafra e Sara Jorge e Silva

%% Refer�ncia de Modelo Convencional (Marcos)
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
    RI = RosInterface;
    
    disp('Load All Class...............');
    
catch ME
    disp(' ####   Load Class Issues   ####');
    disp('');
    disp(ME);
end


try
    while true
        send(pub1,msg1);
        %send(pub2,msg2);
        pause(0.1);
    end

catch
    % Fecha o cliente ROS
    rosshutdown;
end

% Fecha o programa
rosshutdown;