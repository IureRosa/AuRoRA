classdef LineFormation2D < handle
% Establish a Line Formation in 2D
% FORMATION DESIGN ................................................
%  [Superior view]         
%                     
%                        __    
%                       /  \   
%                     ||    || Robot 2 (x2,y2)
%                      .`--� 
%                    .�       
%        {Rho_f}   .�
%                .�       
%              .�
%       __   .�  ) {Alpha_f}
%      /  \    ----------------    
%    ||    || Robot 1 (x1,y1) 
%      `--� 
% 
%  The center of formation can be: 
%  I  = robot 1                  >> LineFormation2D('robot')  
%  II = middle of formation line >> LineFormation2D('center')   [default]
% .................................................................
    properties
        pPos   % posturas dos robos
        pPar   % par�metros do rob�
        pSC    % sinal de controle
    end
    
    methods
        
        % Define tipo de forma��o:
        % 'center' = refer�ncia da forma��o � o ponto m�dio dos dois rob�s
        % 'robot'  = refer�ncia da forma��o � o rob� 1        
        function obj = LineFormation2D(type)
        % Caso n�o seja especificado o tipo, considera refer�ncia no ponto
        % m�dio dos rob�s
            if nargin < 1
                type = 'center';
            elseif nargin>1
                disp('Defina apenas um tipo de forma��o ["center" ou "robot"].');
            end
            
            obj.pPar.Type = type;       % salva tipo de forma��o
            mInit(obj);                 % inicializa vari�veis
        end
        
        mInit(obj)                      % Inicializa vari�veis
        mFormationControl(obj);         % Controla forma��o
        mDirTrans(obj)                  % obt�m vari�veis de forma��o    
        mInvTrans(obj,par)              % obt�m posi��o dos rob�s 1 e 2 
        
    end
end