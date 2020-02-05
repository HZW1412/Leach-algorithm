% Tworzenie w�z��w sieci na podstawie parametr�w
function Nodes = CreateNodes(Network, number_of_nodes, init_energy)
    for i = 1:number_of_nodes
        Nodes(i).xd = rand()*Network.Surface.Width;    %losowanie wsp�rz�dnej x
        Nodes(i).yd = rand()*Network.Surface.Height;     %losowanie wsp�rz�dnej y
        Nodes(i).E = init_energy;
        Nodes(i).G = 0;
        plot(Nodes(i).xd,Nodes(i).yd,'bo');
        text(Nodes(i).xd+10, Nodes(i).yd-10, num2str(i));
        hold on;
    end
end