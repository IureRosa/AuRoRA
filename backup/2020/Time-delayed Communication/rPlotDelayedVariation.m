function [] = rPlotDelayedVariation(tmax)
%****** Fun��o para plotar os principais gr�ficos ******%

for j = (1:2)

%     filename = sprintf('C:%cUsers%cleo_j%cDropbox%cDropbox%cAuRoRA 2018%cTime-delayed Communication%cDados Simu%cPosition%csimu_atraso_variavel%d.mat', '\', '\', '\', '\', '\', '\', '\', '\', '\',j);

    if j == 1
        filename = sprintf('C:%cUsers%cleo_j%cDropbox%cDropbox%cAuRoRA 2018%cTime-delayed Communication%cDados Simu%cTrajectory Tracking%csimu_atraso_variavel(Circunfer�ncia).mat', '\', '\', '\', '\', '\', '\', '\', '\', '\');
        name_fig = sprintf('C:%cUsers%cleo_j%cDropbox%cDropbox%cAuRoRA 2018%cTime-delayed Communication%cFigs%cfigTaj Atraso_Vari�velVariationDelay(Circunfer�ncia)', '\', '\', '\', '\', '\', '\', '\', '\');

    else
        name_fig = sprintf('C:%cUsers%cleo_j%cDropbox%cDropbox%cAuRoRA 2018%cTime-delayed Communication%cFigs%cfigTraj Atraso_Vari�velVariationDelay(Lemniscata)', '\', '\', '\', '\', '\', '\', '\', '\');
        filename = sprintf('C:%cUsers%cleo_j%cDropbox%cDropbox%cAuRoRA 2018%cTime-delayed Communication%cDados Simu%cTrajectory Tracking%csimu_atraso_variavel(Lemniscata).mat', '\', '\', '\', '\', '\', '\', '\', '\', '\');
    end
    
    Arq = load(filename,'Hist');
    % whos('-file','Hist.mat')

    fAtrasoVar = figure('Name','Posicionamento ArDrone','NumberTitle','off');
    fAtrasoVar.Position = [488 2 875 618]; 
    figure(fAtrasoVar);

    plot(Arq.Hist(:,end),Arq.Hist(:,[end-4]), 'LineWidth', 1)
%     if j == 1
%         legend({'$x_{d}$','$x_{Actu}$','$x_{delayed}$'},'FontSize',13,'interpreter','latex','Position',[0.83 0.87 0.091 0.092])
%     else
%         legend({'$x_{d}$','$x_{delayed}$'},'FontSize',13,'interpreter','latex','Position',[0.83 0.87 0.091 0.092])
%     end
    grid on
    axis([0 tmax round(min(Arq.Hist(:,end-4))-5) round(max(Arq.Hist(:,end-4))+5)])
    title({'\textbf{Delay}'; 'Variation'},'FontSize',14,'FontWeight','bold','Interpreter','latex')
    xlabel('$t$[$s$]','FontSize',15,'FontWeight','bold','interpreter','Latex')
    ylabel('$t_{Atraso}$[$s$]','FontSize',15,'FontWeight','bold','interpreter','Latex')

%     name_fig = sprintf('C:%cUsers%cleo_j%cDropbox%cDropbox%cAuRoRA 2018%cTime-delayed Communication%cFigs%cfigPos Atraso_Vari�vel%d (VariationDelay)', '\', '\', '\', '\', '\', '\', '\', '\', j);
    saveFigure(fAtrasoVar, name_fig);     % Salva a figura .fig
    saveas(fAtrasoVar, name_fig, 'epsc'); % Salva a figura .eps
    saveas(fAtrasoVar, name_fig, 'pdf');  % Salva a figura .pdf
    saveas(fAtrasoVar, name_fig, 'png');  % Salva a figura .png
end
%-------------------------------------------------------------------------
% Gr�ficos de An�lise da Circunfer�ncia
% Hist_Circun = [];
% for i = 1:size(Hist,1)
%     if Hist(i,22) == 0.5515
%         Hist_Circun = [Hist_Circun; Hist(i,:)];
%     end
% end
% 
% % - Vari��o da posi��o em X em rela��o ao tempo (OK):
% figure(11)
% plot(Hist_Circun(:,end),Hist_Circun(:,1),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Circun(:,end),Hist_Circun(:,3),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de X'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Vari��o da posi��o em Y em rela��o ao tempo (OK):
% figure(12)
% plot(Hist_Circun(:,end),Hist_Circun(:,2),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Circun(:,end),Hist_Circun(:,4),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de Y'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Varia��o do Erro em X e em Y (OK):
% X_til = Hist_Circun(:,1) - Hist_Circun(:,3);
% Y_til = Hist_Circun(:,2) - Hist_Circun(:,4);
% figure(13)
% plot(Hist_Circun(:,end),X_til,':',Hist_Circun(:,end),Y_til,'-.','LineWidth',2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Erro','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Varia��o do Erro em X','Varia��o do Erro em Y');
% axis tight
% 
% % - Trajet�ria Percorrida pelo Rob� (OK):
% figure(14)
% plot(Hist_Circun(:,1),Hist_Circun(:,2),Hist_Circun(:,3),Hist_Circun(:,4), 'LineWidth',2);
% xlabel('Eixo X [m]','FontSize',12,'FontWeight','bold');
% ylabel('Eixo Y [m]','FontSize',12,'FontWeight','bold');
% grid on;
% axis tight
% 
% % - Velocidade Linear real e sinal de controle (n�o-OK):
% figure(15)
% Vel = Hist_Circun(:,16);
% SC_Vel = Hist_Circun(:,15);
% plot(Hist_Circun(:,end),Vel,Hist_Circun(:,end),SC_Vel,'--', 'linewidth',1.2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Velocidades [m/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% % - Velocidade Angular real e sinal de controle (nao-OK):
% figure(16)
% Vel_Ang = Hist_Circun(:,18);
% SC_Vel_Ang = Hist_Circun(:,17);
% plot(Hist_Circun(:,end),Vel_Ang,Hist_Circun(:,end),SC_Vel_Ang,'--', 'linewidth',1.5);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); ylabel('Velocidade Angular [rad/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% %-------------------------------------------------------------------------
% % Gr�ficos de An�lise da Elips�ide
% Hist_Elips = [];
% for i = 1:size(Hist,1)
%     if Hist(i,22) == 0.6875
%         Hist_Elips = [Hist_Elips; Hist(i,:)];
%     end
% end
% 
% % - Vari��o da posi��o em X em rela��o ao tempo (OK):
% figure(17)
% plot(Hist_Elips(:,end),Hist_Elips(:,1),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Elips(:,end),Hist_Elips(:,3),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de X'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Vari��o da posi��o em Y em rela��o ao tempo (OK):
% figure(18)
% plot(Hist_Elips(:,end),Hist_Elips(:,2),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Elips(:,end),Hist_Elips(:,4),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de Y'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Varia��o do Erro em X e em Y (OK):
% X_til = Hist_Elips(:,1) - Hist_Elips(:,3);
% Y_til = Hist_Elips(:,2) - Hist_Elips(:,4);
% figure(19)
% plot(Hist_Elips(:,end),X_til,':',Hist_Elips(:,end),Y_til,'-.','LineWidth',2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Erro','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Varia��o do Erro em X','Varia��o do Erro em Y');
% axis tight
% 
% % - Trajet�ria Percorrida pelo Rob� (OK):
% figure(20)
% plot(Hist_Elips(:,1),Hist_Elips(:,2),Hist_Elips(:,3),Hist_Elips(:,4), 'LineWidth',2);
% xlabel('Eixo X [m]','FontSize',12,'FontWeight','bold');
% ylabel('Eixo Y [m]','FontSize',12,'FontWeight','bold');
% grid on;
% axis tight
% 
% % - Velocidade Linear real e sinal de controle (n�o-OK):
% figure(21)
% Vel = Hist_Elips(:,16);
% SC_Vel = Hist_Elips(:,15);
% plot(Hist_Elips(:,end),Vel,Hist_Elips(:,end),SC_Vel,'--', 'linewidth',1.2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Velocidades [m/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% % - Velocidade Angular real e sinal de controle (nao-OK):
% figure(22)
% Vel_Ang = Hist_Elips(:,18);
% SC_Vel_Ang = Hist_Elips(:,17);
% plot(Hist_Elips(:,end),Vel_Ang,Hist_Elips(:,end),SC_Vel_Ang,'--', 'linewidth',1.5);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); ylabel('Velocidade Angular [rad/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% %-------------------------------------------------------------------------
% % Gr�ficos de An�lise da Leminiscata de Bernoulli
% Hist_Lemin = [];
% for i = 1:size(Hist,1)
%     if Hist(i,22) == 0.8800
%         Hist_Lemin = [Hist_Lemin; Hist(i,:)];
%     end
% end
% 
% % - Vari��o da posi��o em X em rela��o ao tempo (OK):
% figure(23)
% plot(Hist_Lemin(:,end),Hist_Lemin(:,1),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Lemin(:,end),Hist_Lemin(:,3),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de X'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Vari��o da posi��o em Y em rela��o ao tempo (OK):
% figure(24)
% plot(Hist_Lemin(:,end),Hist_Lemin(:,2),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Lemin(:,end),Hist_Lemin(:,4),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de Y'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Varia��o do Erro em X e em Y (OK):
% X_til = Hist_Lemin(:,1) - Hist_Lemin(:,3);
% Y_til =Hist_Lemin(:,2) - Hist_Lemin(:,4);
% figure(25)
% plot(Hist_Lemin(:,end),X_til,':',Hist_Lemin(:,end),Y_til,'-.','LineWidth',2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Erro','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Varia��o do Erro em X','Varia��o do Erro em Y');
% axis tight
% 
% % - Trajet�ria Percorrida pelo Rob� (OK):
% figure(26)
% plot(Hist_Lemin(:,1),Hist_Lemin(:,2),Hist_Lemin(:,3),Hist_Lemin(:,4), 'LineWidth',2);
% xlabel('Eixo X [m]','FontSize',12,'FontWeight','bold');
% ylabel('Eixo Y [m]','FontSize',12,'FontWeight','bold');
% grid on;
% axis tight
% 
% % - Velocidade Linear real e sinal de controle (n�o-OK):
% figure(27)
% Vel = Hist_Lemin(:,16);
% SC_Vel = Hist_Lemin(:,15);
% plot(Hist_Lemin(:,end),Vel,Hist_Lemin(:,end),SC_Vel,'--', 'linewidth',1.2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Velocidades [m/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% % - Velocidade Angular real e sinal de controle (nao-OK):
% figure(28)
% Vel_Ang = Hist_Lemin(:,18);
% SC_Vel_Ang = Hist_Lemin(:,17);
% plot(Hist_Lemin(:,end),Vel_Ang,Hist_Lemin(:,end),SC_Vel_Ang,'--', 'linewidth',1.5);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); ylabel('Velocidade Angular [rad/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% %-------------------------------------------------------------------------
% % Gr�ficos de An�lise da Reta parametrizada no tempo
% Hist_Reta = [];
% for i = 1:size(Hist,1)
%     if Hist(i,22) == 1.200
%         Hist_Reta = [Hist_Reta; Hist(i,:)];
%     end
% end
% 
% % - Vari��o da posi��o em X em rela��o ao tempo (OK):
% figure(29)
% plot(Hist_Reta(:,end),Hist_Reta(:,1),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Reta(:,end),Hist_Reta(:,3),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de X'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Vari��o da posi��o em Y em rela��o ao tempo (OK):
% figure(30)
% plot(Hist_Reta(:,end),Hist_Reta(:,2),'--r', 'LineWidth',1.5);
% hold on
% plot(Hist_Reta(:,end),Hist_Reta(:,4),':','LineWidth',2);
% hold off, grid on;
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold');
% ylabel('Posi��o [m]','FontSize',12,'FontWeight','bold');
% legend('Refer�ncia','Varia��o de Y'); 
% legend('Location','southeast'); legend('boxoff');
% % axis 'auto y'
% % axis([0 tempo 0 (max(Hist(:,4))+0.1)])
% axis tight
% 
% % - Varia��o do Erro em X e em Y (OK):
% X_til = Hist_Reta(:,1) - Hist_Reta(:,3);
% Y_til = Hist_Reta(:,2) - Hist_Reta(:,4);
% figure(31)
% plot(Hist_Reta(:,end),X_til,':',Hist_Reta(:,end),Y_til,'-.','LineWidth',2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Erro','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Varia��o do Erro em X','Varia��o do Erro em Y');
% axis tight
% 
% % - Trajet�ria Percorrida pelo Rob� (OK):
% figure(32)
% plot(Hist_Reta(:,1),Hist_Reta(:,2),Hist_Reta(:,3),Hist_Reta(:,4), 'LineWidth',2);
% xlabel('Eixo X [m]','FontSize',12,'FontWeight','bold');
% ylabel('Eixo Y [m]','FontSize',12,'FontWeight','bold');
% grid on;
% axis tight
% 
% % - Velocidade Linear real e sinal de controle (n�o-OK):
% figure(33)
% Vel = Hist_Reta(:,16);
% SC_Vel = Hist_Reta(:,15);
% plot(Hist_Reta(:,end),Vel,Hist_Reta(:,end),SC_Vel,'--', 'linewidth',1.2);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); 
% ylabel('Velocidades [m/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight
% 
% % - Velocidade Angular real e sinal de controle (nao-OK):
% figure(34)
% Vel_Ang = Hist_Reta(:,18);
% SC_Vel_Ang = Hist_Reta(:,17);
% plot(Hist_Reta(:,end),Vel_Ang,Hist_Reta(:,end),SC_Vel_Ang,'--', 'linewidth',1.5);
% xlabel('Tempo [s]','FontSize',12,'FontWeight','bold'); ylabel('Velocidade Angular [rad/s]','FontSize',12,'FontWeight','bold');
% grid on;
% legend('Velocidade Real do Rob�','Sinal de Controle');
% axis tight

end