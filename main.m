%Micha� Kochma�ski
%Damian Ko�odziej

clc;
clear all;
close all;

initial_energy = 0.5;       % Pocz�tkowa energia wszystkich w�z��w
rounds_number = 100;        % Liczba rund

nodes_number = 200;         % Liczba w�z��w
p = 0.1;                    % Procent w�z��w g��wnych
%m = 0.1;                   % Procent w�z��w o wy�szej energii pocz�tkowej
%alpha = 2;                 % Wsp�czynnik zwi�kszania energii pocz�tkowej
height = 1000;              % Wysoko�� obszaru(macierzy) rozmieszczenia w�z��w
width = 1000;               % Szeroko�� obszaru(macierzy) rozmieszczenia w�z��w
Sink.X = 500;               % Wsp�rz�dne x y w�z�a nadrz�dnego(sink)
Sink.Y = 500;

%Eelec=Etx=Erx Eelec
ETX=50*0.000000001; %energia zwi�zana z transmisj� bitu danych
ERX=50*0.000000001; %energia zwi�zana z odbiorem bitu danych

%Typy wzmacniaczy transmisji (Transmit Amplifier Types), zwi�zane z odleg�o�ci� od odbiornika
Efs=    10  *0.000000000001;
Emp=0.0013  *0.000000000001;

%Data Aggregation Energy - energia zwi�zana z agregacj� danych przez g��wny w�ze� w ka�dym klastrze
EDA=5*0.000000001;

%obliczanie sta�ej d0 zgodnie z wzorem 
do=sqrt(Efs/Emp);

%Tworzenie przestrzeni do rozmieszczenia w�z��w
Network = CreateNetwork(height, width, Sink.X, Sink.Y);

%Tworzenie w�z��w
Nodes = CreateNodes(Network, nodes_number, initial_energy);
%Nodes = CreateNodesForHeterogenity(Network, nodes_number, initial_energy,m,alpha);

%Pytanie czy u�ytkownik chce wybra� pocz�tkowe w�z�y g��wne?
inpt = input("Czy chcesz wybra� pocz�tkowe w�z�y g��wne? [t/n]",'s');
if isempty(inpt)
    inpt = 'n';
end
users_initial_nodes = false;
if inpt == 't'
    users_initial_nodes = true;
   i = 1;
    next = true;
    while next
        x = input("Prosz� poda� numer w�z�a:");
        initial_nodes(i) = x;
        next_node = input("Kolejny w�ze�? [t/n]",'s');
        if isempty(inpt)
            next_node = 'n';
        end
        if next_node == 'n'
            next = false;
        end
        i=i+1;
    end
end


% p�tla g��wna
for r=1:rounds_number
    dead_nodes_number(r) = 0;
    total_network_energy(r) = 0;
    
    %wypisz aktualn� runde
    runda = sprintf('%d',r)
    %operacja dla epoki
    if(mod(r, round(1/p) )==0) %wykonuj co 1/p runde
        for i=1:1:nodes_number
            Nodes(i).G=0; 
        end
    end
    
    %wybieranie w�z��w g��wnych
    %je�eli u�ytkownik wybra� w�z�y
    if users_initial_nodes
        clusters_number = 1;
        for i=1:1:length(Nodes)
            if any(initial_nodes(:) == i)
                        Clusters(clusters_number).xd = Nodes(i).xd;
                        Clusters(clusters_number).yd = Nodes(i).yd;
                        distanceToSink = sqrt( (Nodes(i).xd-Sink.X )^2 + (Nodes(i).yd-Sink.Y)^2 );
                        Clusters(clusters_number).distanceToSink=distanceToSink;
                        Clusters(clusters_number).id=i;
                        Clusters(clusters_number).color=abs(rand(1,3)-0.2);
                        clusters_number=clusters_number+1;
            end
        end
        users_initial_nodes = false;
    %je�eli u�ytkownik nie wybra� w�z��w
    else
        clusters_number = 1;
        for i=1:1:length(Nodes)
            if(Nodes(i).E>0)
                total_network_energy(r) = total_network_energy(r)+ Nodes(i).E;
                temp_rand=rand;
                if ( (Nodes(i).G)<=0)
                %Wyb�r w�z��w g��wych
                    if(temp_rand <= (p/(1-p*mod(r,round(1/p)))))     %treshold(pr�g zostania g��wnym w�z�em)
                        Nodes(i).G = round(1/p)-1;
                        Clusters(clusters_number).xd = Nodes(i).xd;
                        Clusters(clusters_number).yd = Nodes(i).yd;

                        distanceToSink = sqrt( (Nodes(i).xd-Sink.X )^2 + (Nodes(i).yd-Sink.Y)^2 );
                        Clusters(clusters_number).distanceToSink=distanceToSink;
                        Clusters(clusters_number).id=i;
                        Clusters(clusters_number).color=abs(rand(1,3)-0.2);
                        clusters_number=clusters_number+1;

                    end     
                end
            end 
            %zliczanie martwych w�z��w
            if(Nodes(i).E<=0)
                dead_nodes_number(r) = dead_nodes_number(r)+1;
            end
        end
    end
    
    
    %Obliczanie energii rozpraszanej 
    %Na podstawie artyku�u i tych wzor�w
    %4000 - wielko�� pakiet�w w bitach
    for c=1:1:length(Clusters)
        if (Clusters(c).distanceToSink > do)
            Nodes(Clusters(c).id).E = Nodes(Clusters(c).id).E - ( (ETX+EDA)*(4000) + Emp*4000*( Clusters(c).distanceToSink ^4)); 
        end
        if (Clusters(c).distanceToSink <= do)
            Nodes(Clusters(c).id).E = Nodes(Clusters(c).id).E - ( (ETX+EDA)*(4000) + Efs*4000*( Clusters(c).distanceToSink ^2 )); 
        end
        
    end
    
    %rysowanie je�li istnieje jaki� klaster
    hold off;
    figure(1);
    if(clusters_number-1 >= 1)
        plot(Sink.X,Sink.Y,'rs','MarkerSize',18); %rysowanie sink'a
        text(Sink.X-19,Sink.Y,'BS'); %rysowanie sink'a
        hold on;    
        for i=1:1:nodes_number
            %Sprawdzanie, czy w�ze� jest matrwy
            if (Nodes(i).E<=0)
                plot(Nodes(i).xd,Nodes(i).yd,'black .','MarkerSize',12);%rysowanie dead node
                hold on;    
            end
            if Nodes(i).E>0
                plot(Nodes(i).xd,Nodes(i).yd,'bo'); %oznaczenie "o" dla zwyk�ych nodes
                hold on;
            end
        end
            
        %rysowanie w�z��w g��wnych
        for c=1:1:clusters_number-1
            plot(Clusters(c).xd, Clusters(c).yd,'*','Color',Clusters(c).color,'MarkerSize',12); %rysowanie klastra  
            text(Clusters(c).xd+10, Clusters(c).yd-10, num2str(Clusters(c).id));
            hold on;
        end
    end
    
    %Wybieranie w�z�a g��wnego dla w�z��w na podstawie odleg�o�ci 
    for i=1:1:nodes_number
        if (Nodes(i).E>0 )
            min_dis_cluster = 0;
            node_range = (Nodes(i).E / initial_energy) * (height/2);    %zasi�g w�z�a = (aktualna energia / pocz�tkowa energia) * po�owa wysoko�ci przestrzeni
            if(clusters_number-1 >= 1) %je�li istnieje jakikolwiek klaster
                %wybieranie najbli�szego g��wnego w�z�a
                min_dis = inf;
                for c=1:1:clusters_number-1
                   c_dis = min(min_dis,sqrt( (Nodes(i).xd-Clusters(c).xd)^2 + (Nodes(i).yd-Clusters(c).yd)^2 ) );
                   if ( c_dis < min_dis && c_dis < node_range)     %uwzgl�dniony zasi�g w�z�a
                       min_dis = c_dis;
                       min_dis_cluster = c;
                   end
                end
                if(min_dis_cluster ~= 0)
                    %Zmniejszenie energii w�z�a
                    if (min_dis > do)
                        Nodes(i).E = Nodes(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                    end
                    if (min_dis <= do)
                        Nodes(i).E = Nodes(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                    end

                    %Zmniejszenie energii w�z�a g��wnego do kt�rego jest po��czony w�ze� "i"
                    if(min_dis>0)
                        Nodes(Clusters(min_dis_cluster).id).E = Nodes(Clusters(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
                    end

                    %rysowanie po��cze� mi�dzy w�z�ami a w�z�ami g��wnymi
                    line([Nodes(i).xd, Nodes(Clusters(min_dis_cluster).id).xd],[Nodes(i).yd, Nodes(Clusters(min_dis_cluster).id).yd],'Color',Clusters(min_dis_cluster).color);
                end
            end
        end
    hold on;
    end
end

%rysowanie wykresu wynikowego
r=1:rounds_number;
figure;
plot(r,dead_nodes_number,'k.','LineWidth',2);
xlabel('Czas(Runda)');
ylabel('Liczba martwych w�z��w');
title('Liczba martwych w�z��w po czasie');

figure;
plot(r,total_network_energy,'k.','LineWidth',2);
xlabel('Czas(Runda)');
ylabel('Ilo�� energii w sieci');
title('Ilo�� energii w sieci po czasie');


    