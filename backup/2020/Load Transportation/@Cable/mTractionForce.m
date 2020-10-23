function mTractionForce(cable,load,drone)


% Tens�o aplicada em fun��o do comprimento do cable
for nv = 1:size(drone,2)
    cable{nv}.pPos.Xa = cable{nv}.pPos.X;
    cable{nv}.pPos.X(4) = norm(drone{nv}.pPos.X(1:3)-load.pPos.X(1:3));
    cable{nv}.pPos.X(2) = abs(atan2(drone{nv}.pPos.X(1)-load.pPos.X(1),drone{nv}.pPos.X(3)-load.pPos.X(3)));
end

% Apenas para o caso de dois Ve�culos
if nv == 2
    if cable{1}.pPos.X(4) < cable{1}.pPar.l
        cable{1}.pPos.X(3) = 0;
    else
        cable{1}.pPos.X(3) = load.pPar.m*load.pPar.g*sin(cable{2}.pPos.X(2))/(cos(load.pPos.alpha)*sin(cable{1}.pPos.X(2)+cable{2}.pPos.X(2))) + 0.1*(cable{1}.pPos.X(4) - cable{1}.pPar.l) + 1*(cable{1}.pPos.X(4)-cable{1}.pPos.Xa(4))/load.pPar.Ts;
    end
    
    if cable{2}.pPos.X(4) < cable{2}.pPar.l
        cable{2}.pPos.X(3) = 0;
    else
        cable{2}.pPos.X(3) = load.pPar.m*load.pPar.g*sin(cable{1}.pPos.X(2))/(cos(load.pPos.alpha)*sin(cable{1}.pPos.X(2)+cable{2}.pPos.X(2))) + 0.1*(cable{2}.pPos.X(4) - cable{2}.pPar.l) + 1*(cable{2}.pPos.X(4)-cable{2}.pPos.Xa(4))/drone{1}.pTempo.Ts;
    end

    %% Postura carga
    
    % Integra��o num�rica da posi��o da carga
    load.pPos.Xa = load.pPos.X;
    load.pPos.X(1) = load.pPos.Xa(1) + load.pPar.Ts*(load.pPos.Xa(4) + load.pPar.Ts*(cable{1}.pPos.X(3)*sin(cable{1}.pPos.X(2))*cos(load.pPos.alpha) - cable{2}.pPos.X(3)*sin(cable{2}.pPos.X(2)*cos(load.pPos.alpha)) )/load.pPar.m);
    load.pPos.X(4) = (load.pPos.X(1)-load.pPos.Xa(1))/load.pPar.Ts;
    
    % Comportamento do �ngulo alpha
    load.pPos.ddalpha = -(cable{1}.pPos.X(3)+cable{2}.pPos.X(3))*sin(load.pPos.alpha)+1/(load.pPar.Iyy+load.pPar.m*load.pPar.l^2)*(load.pPar.m*load.pPar.l*(... % O sinal do (cable{1}.pPos.X(3)+cable{2}.pPos.X(3))*sin(load.pPos.alpha) causa intriga
        cos(load.pPos.alpha)*( drone{1}.pPos.dX(8) - 2*load.pPos.dalpha*drone{1}.pPos.X(9)) + ...
        sin(load.pPos.alpha)*(-drone{1}.pPos.dX(9) - 2*load.pPos.dalpha*drone{1}.pPos.X(8) - load.pPar.g)));
    load.pPos.dalpha = load.pPos.dalpha + load.pPos.ddalpha*load.pPar.Ts;
    load.pPos.alpha = load.pPos.alpha + load.pPos.dalpha*load.pPar.Ts;
    
    load.pPos.X(2) = tan(load.pPos.alpha)*(drone{1}.pPos.X(1)-load.pPos.X(1)) + drone{1}.pPos.X(2);
    load.pPos.X(5) = (load.pPos.X(2)-load.pPos.Xa(2))/load.pPar.Ts;
    
    load.pPos.X(3) = load.pPos.Xa(3) + load.pPar.Ts*(load.pPos.Xa(6) + load.pPar.Ts*(cable{1}.pPos.X(3)*cos(cable{1}.pPos.X(2))*cos(load.pPos.alpha) + cable{2}.pPos.X(3)*cos(cable{2}.pPos.X(2))*cos(load.pPos.alpha) - load.pPar.m*load.pPar.g)/load.pPar.m);
    if load.pPos.X(3) < 0; load.pPos.X(3) = 0;end
    load.pPos.X(6) = (load.pPos.X(3)-load.pPos.Xa(3))/load.pPar.Ts;
end


end
