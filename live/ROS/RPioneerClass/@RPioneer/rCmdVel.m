%    ***************************************************************
%    *    Univeridade Federal do Esp�rito Santo - UFES             *                          
%    *    Course:  Master of Science                               *
%    *    Student: Mauro Sergio Mafra Moreira                      *
%    *    Email:   mauromafra@gmail.com                            *
%    *    Revision: 01                           Data 00/00/2019   *
%    ***************************************************************

% Description:


function rCmdVel(obj)

%   Detailed explanation goes here
%     obj.pSC.Ud(1) % Frente/Tras [-1,1] (+) Avan�a, Move frente para baixo
%     obj.pSC.Ud(2) % Esquerda/Direita [-1,1] (+) Move rover para Esquerda                        
%     obj.pSC.Ud(3) % Velocidade Vertical [-1,1] (+) Eleva o rover

%     # Regra da M�o Direita
%     obj.pSC.Ud(4) % Angulo do rover [-1,1] (+) rotaciona para  em torno do Eixo 
%     obj.pSC.Ud(5) % Angulo do rover [-1,1] (+) rotaciona para  em torno do Eixo 
%     obj.pSC.Ud(6) % Angulo do rover [-1,1] (+) rotaciona para Positivo em torno do Eixo Z 

    % Linear Variable
    obj.pVel.Linear.X = obj.pSC.Ud(1);
    obj.pVel.Linear.Y = obj.pSC.Ud(2);
    obj.pVel.Linear.Z = obj.pSC.Ud(3);
    
    % Angular Variable
    obj.pVel.Angular.X = obj.pSC.Ud(4);
    obj.pVel.Angular.Y = obj.pSC.Ud(5);
    obj.pVel.Angular.Z = obj.pSC.Ud(6);   

    send(obj.pubCmdVel,obj.pVel);
end
