clear vars; close all; clc;

%% Caso 1 - Drone exatamente acima do Pioneer

DadosAng = [];
DadosPol = [];

Xd = [ 0 ; 0 ; 0 ; 0 ; 0 ; 1.5 ];
XAng = Xd;
XPol = Xd;
QdAng = TransDirAngular(Xd);
QdPol = TransDirPolar(Xd);
LyapAng = zeros(3,1);
LyapPol = zeros(3,1);

for x2 = -0.25:0.025:0.25
    for y2 = -0.25:0.025:0.25
        for z2 = 1.25:0.025:1.75
            X = [ 0 ; 0 ; 0 ; x2 ; y2 ; z2 ];
            QAng = TransDirAngular(X);
            QPol = TransDirPolar(X);
            QtilAng = QAng - QdAng;
            QtilPol = QPol - QdPol;
            for i = 1:3
                LyapAng(i) = LyapAng(i) + QtilAng(i+3)^2;
                LyapPol(i) = LyapPol(i) + QtilPol(i+3)^2;
            end

            DadosAng = [ DadosAng; QAng(4:6)' QtilAng(4:6)' LyapAng' ];
            DadosPol = [ DadosPol; QPol(4:6)' QtilPol(4:6)' LyapPol' ];
        end
    end
end

% Plotando os Resultados
try
    sl = 1.5;
    figure;
    subplot(3,1,1);
    plot(DadosAng(:,4),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,4),'LineWidth',sl);
    legend('Angular','Polar');
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\rho}$ [m]','interpreter','Latex');


    subplot(3,1,2);
    plot(rad2deg(DadosAng(:,5)),'LineWidth',sl);
    hold on;
    grid on;
    plot(rad2deg(DadosPol(:,5)),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\alpha}$ [degrees]','interpreter','Latex');

    subplot(3,1,3);
    plot(rad2deg(DadosAng(:,6)),'LineWidth',sl);
    hold on;
    grid on;
    plot(rad2deg(DadosPol(:,6)),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\beta}$ [degrees]','interpreter','Latex');

    figure;
    subplot(3,1,1);
    plot(DadosAng(:,7),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,7),'LineWidth',sl);
    legend('Angular','Polar');
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\rho})$','interpreter','Latex');

    subplot(3,1,2);
    plot(DadosAng(:,8),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,8),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\alpha})$','interpreter','Latex');

    subplot(3,1,3);
    plot(DadosAng(:,9),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,9),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\beta})$','interpreter','Latex');
catch
end

%% Caso 2 - Drone no meio do quadrante

DadosAng = [];
DadosPol = [];

Xd = [ 0 ; 0 ; 0 ; 1.5 ; 1.5 ; 1.5 ];
XAng = Xd;
XPol = Xd;
QdAng = TransDirAngular(Xd);
QdPol = TransDirPolar(Xd);
LyapAng = zeros(3,1);
LyapPol = zeros(3,1);

for x2 = 1.25:0.025:1.75
    for y2 = 1.25:0.025:1.75
        for z2 = 1.25:0.025:1.75
            X = [ 0 ; 0 ; 0 ; x2 ; y2 ; z2 ];
            QAng = TransDirAngular(X);
            QPol = TransDirPolar(X);
            QtilAng = QAng - QdAng;
            QtilPol = QPol - QdPol;
            for i = 1:3
                LyapAng(i) = LyapAng(i) + QtilAng(i+3)^2;
                LyapPol(i) = LyapPol(i) + QtilPol(i+3)^2;
            end

            DadosAng = [ DadosAng; QAng(4:6)' QtilAng(4:6)' LyapAng' ];
            DadosPol = [ DadosPol; QPol(4:6)' QtilPol(4:6)' LyapPol' ];
        end
    end
end

% Plotando os Resultados
try
    sl = 1.5;
    figure;
    subplot(3,1,1);
    plot(DadosAng(:,4),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,4),'LineWidth',sl);
    legend('Angular','Polar');
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\rho}$ [m]','interpreter','Latex');


    subplot(3,1,2);
    plot(rad2deg(DadosAng(:,5)),'LineWidth',sl);
    hold on;
    grid on;
    plot(rad2deg(DadosPol(:,5)),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\alpha}$ [degrees]','interpreter','Latex');

    subplot(3,1,3);
    plot(rad2deg(DadosAng(:,6)),'LineWidth',sl);
    hold on;
    grid on;
    plot(rad2deg(DadosPol(:,6)),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\beta}$ [degrees]','interpreter','Latex');

    figure;
    subplot(3,1,1);
    plot(DadosAng(:,7),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,7),'LineWidth',sl);
    legend('Angular','Polar');
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\rho})$','interpreter','Latex');

    subplot(3,1,2);
    plot(DadosAng(:,8),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,8),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\alpha})$','interpreter','Latex');

    subplot(3,1,3);
    plot(DadosAng(:,9),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,9),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\beta})$','interpreter','Latex');
catch
end


%% Caso 3 - Rob�s com a mesma altura no eixo Z

DadosAng = [];
DadosPol = [];

Xd = [ 0 ; 0 ; 0 ; 1.5 ; 0 ; 0 ];
XAng = Xd;
XPol = Xd;
QdAng = TransDirAngular(Xd);
QdPol = TransDirPolar(Xd);
LyapAng = zeros(3,1);
LyapPol = zeros(3,1);

for x2 = 1.25:0.025:1.75
    for y2 = -0.25:0.025:0.25
        for z2 = 0:0.025:0.25
            X = [ 0 ; 0 ; 0 ; x2 ; y2 ; z2 ];
            QAng = TransDirAngular(X);
            QPol = TransDirPolar(X);
            QtilAng = QAng - QdAng;
            QtilPol = QPol - QdPol;
            for i = 1:3
                LyapAng(i) = LyapAng(i) + QtilAng(i+3)^2;
                LyapPol(i) = LyapPol(i) + QtilPol(i+3)^2;
            end

            DadosAng = [ DadosAng; QAng(4:6)' QtilAng(4:6)' LyapAng' ];
            DadosPol = [ DadosPol; QPol(4:6)' QtilPol(4:6)' LyapPol' ];
        end
    end
end

% Plotando os Resultados
try
    sl = 1.5;
    figure;
    subplot(3,1,1);
    plot(DadosAng(:,4),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,4),'LineWidth',sl);
    legend('Angular','Polar');
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\rho}$ [m]','interpreter','Latex');


    subplot(3,1,2);
    plot(rad2deg(DadosAng(:,5)),'LineWidth',sl);
    hold on;
    grid on;
    plot(rad2deg(DadosPol(:,5)),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\alpha}$ [degrees]','interpreter','Latex');

    subplot(3,1,3);
    plot(rad2deg(DadosAng(:,6)),'LineWidth',sl);
    hold on;
    grid on;
    plot(rad2deg(DadosPol(:,6)),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$\tilde{\beta}$ [degrees]','interpreter','Latex');

    figure;
    subplot(3,1,1);
    plot(DadosAng(:,7),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,7),'LineWidth',sl);
    legend('Angular','Polar');
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\rho})$','interpreter','Latex');

    subplot(3,1,2);
    plot(DadosAng(:,8),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,8),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\alpha})$','interpreter','Latex');

    subplot(3,1,3);
    plot(DadosAng(:,9),'LineWidth',sl);
    hold on;
    grid on;
    plot(DadosPol(:,9),'LineWidth',sl);
    xlabel('Time [s]','interpreter','Latex');
    ylabel('$V(\tilde{\beta})$','interpreter','Latex');
catch
end


%% Fun��es Usadas

function Q = TransDirAngular(X)
    x1 = X(1);   
    y1 = X(2);
    z1 = X(3);
    x2 = X(4);
    y2 = X(5);
    z2 = X(6);
    
    Q = zeros(6,1);
    
    Q(1) = x1;                                             % xF
    Q(2) = y1;                                             % yF
    Q(3) = z1;                                             % zF
    Q(4) = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2);        % rho
    Q(5) = asin((x2-x1)/Q(4)) ;                            % alpha
    Q(6) = asin((y2-y1)/Q(4));                             % beta
end

function Q = TransDirPolar(X)
    x1 = X(1);   
    y1 = X(2);
    z1 = X(3);
    x2 = X(4);
    y2 = X(5);
    z2 = X(6);
    
    Q = zeros(6,1);

    Q(1) = x1;                                             % xf
    Q(2) = y1;                                             % yf
    Q(3) = z1;                                             % zf
    Q(4) = sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2);  % rho_f
    Q(5) = atan2((y2 - y1),(x2 - x1)) ;                    % alpha_f
    Q(6) = atan2((z2-z1),sqrt((x2-x1)^2 + (y2-y1)^2));     % beta_f
end 