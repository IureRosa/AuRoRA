function Sucessor = mapaSucessorAdj(No,Adjacencia,Vertices)
%mapaSucessor entrega os n�s resultantes da expans�o do n� desejado
Sucessor = find(Adjacencia(No(1),:)==1);
% Sucessor = Sucessor(Sucessor>No(1));
Sucessor = Vertices(Sucessor,:);
end

