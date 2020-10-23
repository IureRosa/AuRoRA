function [C_desvio,ind_caminho_obs_final] = gera_caminho_desvio(C_normal,obs_ativo,dist_min_obs,inc_desvio,ind)

% La�o respons�vel por descobrir qual �ndice do caminho normal est� na
% dist�ncia considerada para o Desvio. Este ponto ser� o ponto inicial do
% arco de circunfer�ncia
i = 1;
dist_desvio_inicio = 1000;
while dist_desvio_inicio > dist_min_obs
    dist_desvio_inicio = norm(C_normal(1:2,ind+i)-obs_ativo(1:2));
    i = i + 1;
end
ind_desvio_inicio = ind+i;

% Esta fun��o descobre o �ndice do caminho normal mais perto do obst�culo.
% Tal �ndice ser� usado para come�ar o la�o para se descobrir o �ndice do
% final do desvio
[dist_caminho_obs, ind_caminho_obs] = calcula_ponto_proximo(C_normal(1:2,:),obs_ativo(1:2));

% Este la�o utiliza o �ndice mais pr�ximo do obst�culo, para
% descobrir o primeiro �ndice depois desse onde a dist�ncia ao
% obst�culo � maior que o limiar de desvio
i = 1;
dist_caminho_obs_final = 0;
while dist_caminho_obs_final < dist_min_obs
    dist_caminho_obs_final = norm(C_normal(1:2,ind_caminho_obs+i)-obs_ativo(1:2));
    i = i + 1;
end
ind_caminho_obs_final = ind_caminho_obs+i;

C_desvio = gera_abcissa_curvilinea_desvio_curto_TH(C_normal(:,ind_desvio_inicio),C_normal(:,ind_caminho_obs_final),obs_ativo,inc_desvio,dist_min_obs);

