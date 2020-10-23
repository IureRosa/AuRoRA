%%% ALGORITMO AplicaZonaSeguranca 
%%% AUMENTA AS AREAS EM TORNO DE CELULAS DO GRID QUE ESTAO OCUPADAS. PARA CADA CELULA
%%% COM VALOR = 1 , AS 8 CELULAS ADJACENTES SER�O DEFINIDAS COMO OCUPADAS
%%% PARAMETROS 
%%%     grid : matriz com valores biarios (0 = espa�o livre, 1 = obst�culo) 
%%%     k  : NUMERO DE VEZES QUE CADA CELULA OCUPADA SER� AUMENTADA  

function g = AplicaZonaSeguranca( grid , k )
    t = size(grid);
    for i=1:t(1)
        for j=1:t(2)
            if grid(i,j)==1                                
                grid(i,j)=3;
                grid = IncrementaZonaCelula(grid,i,j,t(1),t(2),k);
            end
        end
    end
    g = floor(grid/2);
end