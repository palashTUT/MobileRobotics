%% building the provided map
%rng(1)

start_pt = [5, 29];
end_pt = [29, 20];
Npoly=13;
maxpoly=12;
pgx=NaN*ones(Npoly,maxpoly);
pgy=NaN*ones(Npoly,maxpoly);
pgx(1,1:11)=[2 8.5 8.5 4 2 2 1 1 2 4 2];
pgy(1,1:11)=[8 10 1 3 3 1 1 6 6 5 8];
pgx(2,1:9)=[2 8 2 15 2 1 1 2 2];
pgy(2,1:9)=[10 16 22 15.5 9 10 16 16 10];
pgx(3,1:4)=[0 0 5 0];
pgy(3,1:4)=[25 30 30 25];
pgx(4,1:8)=[7 7 10 10 13 13 11 7];
pgy(4,1:8)=[23 26 29 25 26 23 21 23];
pgx(5,1:4)=[13 17 15 13];
pgy(5,1:4)=[30 30 25  30];
pgx(6,1:5)=[17 17 30 30 17];
pgy(6,1:5)=[23 27 27 23 23];
pgx(7,1:9)=[12 14 15 16 29 23 27 19 12];
pgy(7,1:9)=[20 21 23 21.3 22 10 21.3 14 20];
pgx(8,1:5)=[10 15 17.5 10 10];
pgy(8,1:5)=[8 14 10 0 8];
pgx(9,1:4)=[19 24 19 19];
pgy(9,1:4)=[12.5 17 1 12.5];
pgx(10,1:4)=[21 30 26 21];
pgy(10,1:4)=[3 16 1 3];
pgx(11,1:9)=[4 7 8 6 5 10 7 4 4];
pgy(11,1:9)=[25 30 30 26 23 20 21 23 25];
pgx(12,1:8)=[0 0 4 5 4 3 3 0];
pgy(12,1:8)=[17 18 18 16 14 14 17 17];
pgx(13,1:5)=[3 3 4 4 3];
pgy(13,1:5)=[0 2 2 0 0];

close all

plot([0 30 30 0 0],[0 0 30 30 0]);
hold

excluded_area=0;


for ii=1:Npoly
    inds=find(isnan(pgx(ii,:))==0);
    excluded_area=excluded_area+polyarea(pgx(ii,inds),pgy(ii,inds));
    fill(pgx(ii,inds),pgy(ii,inds),'g')
end
%% finding the nodes (integer value of coordinates taken only) 
amountofnodes =102;

L = zeros(amountofnodes,2); %matrix for nodes
L(1,:) = start_pt;
L(amountofnodes,:) = end_pt;

plot(L(1,1),L(1,2),'b*');%plots nodes in map
hold on
plot(L(amountofnodes,1), L(amountofnodes, 2), 'b*');
%plots 100 random nodes
for i=2:amountofnodes-1
    isinside = 0; %keept track on if node is inside exluded area
    node = randi([0 30],1,2);
    %check if in excluded_area
    while(true)
        for ii=1:Npoly
            inds=find(isnan(pgx(ii,:))==0);
            %checks if node is inside restricted area or on restricted area
            %edges
            [xa,ya]=polyxpoly(node(1),node(2),pgx(ii,inds),pgy(ii,inds));
            if(isempty(L)==0)
                %if L is not empty it checks if the node is already in L
                [xb,yb]=polyxpoly(node(1),node(2),L(:,1)',L(:,2)');
            else
                %otherwise the vectors indicating if node is already
                %included are empty
                xb=[];
                yb=[];
            end
            
            
            if inpolygon(node(1),node(2),pgx(ii,inds),pgy(ii,inds))==1 ...
                || isempty(xa)==0 && isempty(ya)==0|| isempty(xb)==0 && isempty(yb)==0
                isinside = 1; %isinside value is 1 if node is in excluded area
                %or if it is already generated
            end
        end
        
        %continues search with a new node or accepts a node
        if isinside == 1
            node = randi([0 30],1,2);
            isinside = 0; %new node, initialize
        else
%             isinside = 0; %initialize
            break %accepted node was found
        end
    end
    
    plot(node(1),node(2),'b*');%plots nodes in map
    title('obstruction and random nodes')
    L(i,1) = node(1); %adds node in coordinate list
    L(i,2) = node(2);
end

%% finding the edges connecting the nodes
% amountofnodes =100;

E= [];
isinside=0;

j1=1;
%checking nodes
for i=1:amountofnodes
     j1=j1+1; %edges are bidirectional, therefore same index doesn't need 
     %be checked twice (e.g first time i= 1 and j=2 checked so i=2 j=1 
     %doesn't need to be checked anymore, also j=i is not a possible edge)
     
     
%     selected_node = [selected_node;i];
%check node and another node until all nodes are connected
    for j=j1:amountofnodes
        if j==i
            continue
        end
      
        edgex =[L(i,1),L(j,1)];
        edgey =[L(i,2),L(j,2)];
%         edgex =[L(1,1),L(60,1)];
%         edgey =[L(1,2),L(60,2)];
        
        %add all other nodes into matrix
        othernodes = L;
        othernodes(i,:) = []; %remove current node i
        if i < j
            othernodes(j-1,:) = []; %remove current node j
        else
           othernodes(j,:) = []; 
        end
        
        %check there is no node between nodes j and i by using the matrix
        %inlcuding other nodes
        for ind=1:size(othernodes,1)
            
            
            [xnode,ynode] = polyxpoly(othernodes(ind,1),...
                othernodes(ind,2),edgex,edgey);
            if isempty(ynode) ==0|isempty(xnode) ==0
               isinside =1;
               break
            end
        end
        
        %don't add edge if it cuts via another edge
        if isinside == 1
            %do nothing
            isinside = 0;
        else
            %otherwise check if edge goes via excluded area
            for ii=1:Npoly
                inds=find(isnan(pgx(ii,:))==0);
                [in,on]=inpolygon(edgex,edgey,pgx(ii,inds),pgy(ii,inds));
                [xt,yt] = polyxpoly(edgex,edgey,pgx(ii,inds),pgy(ii,inds));
                if all(in) || all(on) || ~isempty(xt) || ~isempty(yt)
                    isinside = 1;
                    break
                end
            end
        
            if isinside == 1
                %do nothing
                isinside = 0; %initialize for next edge
%               selected_node = [selected_node;i,j];
            else
                %edge doesn't go via excluded area
                %new edge was found
%               selected_node = [selected_node;i,j];
%               fprintf('%d %d\n', i, j);
                E = [E;i,j]; %edge from i to j added to list
                plot(edgex,edgey, 'b-');
                isinside = 0; %initialize      
            end
        end
%         label
    end
%    
end


%% directed graph from sini
 [Na,Aa] = convert2digraph(L,E);
 Ga=digraph(Aa);
 figure
 plot(Ga)
 
 %% Dijkstra & dynamic programming

n0= [5, 29, 0] 
ng= [29, 20, 0]

%dynamic programming
[route,route_found] = dynamicp(ng,n0,L,E);

%dijkstra
if route_found ~= 0
    [min_cost, route, route_found] = dijkstra(n0, ng, Na, Aa);
    disp('route found:djikstra');
else
    disp('route not found:djikstra')
end

%% A* star (creating database)
node_edge_map = zeros(2*size(E,1),2);
node_edge_map(1:size(E,1),1:2) = E;
node_edge_map((size(E,1)+1):size(node_edge_map,1),1:2) = fliplr(E);
node_edge_map = sortrows(node_edge_map);
[route_found, route] = AStar(L, node_edge_map);
if route_found == 1
    disp('route found:A*');
%     disp(route);
    figure
    plot(route(:,1),route(:,2),'r*-')
    title('A* programming algorithm')
else
    disp('route not found:A*');
end



 




