#By implementing association rule and graph analysis algorithm, we present strategies to increase 
#composers' earnings by analyzing the connection between producers and composers in Hollywood.
#In this code, I used four functions written by my instructor Jake Hofman in order to minimize the workload,
#which I have listed out seperately. 

library(network)
library(igraph)
library(ggplot2)
library(bipartite)
library(dplyr)
library(rgl)
library(arules)
library(arulesViz)
library(stringr)

#Two-mode graph analysis
#Read data
setwd('D:/Columbia/Spring 2015/APMA Modeling Social Data/Final Project')
Movies <- read.paj('Movies.paj')

#get the edges
test <- readLines("Movies.paj")
arclist_raw = (test[107:298])

inilist = vector()
endlist = vector()
numberlist = vector()
for (i in 1:length(arclist_raw)){
  test.number = str_extract_all(arclist_raw[i],"\\(?[0-9,.]+\\)?")[[1]]
  ini = test.number[1]
  end = test.number[2]
  number = test.number[3]
  inilist = append(inilist,ini)
  endlist = append(endlist,end)
  numberlist = append(numberlist,number)
}

myedges <- data.frame(inilist,endlist,numberlist)

network <- myedges

#network <-read.csv('network.csv',header=FALSE)
#Seperate network and partition
partition <- Movies$partitions
network <- na.omit(network)

#Plot two-mode graph
rownames(network) <- seq(1,192,1)
network_graph <- graph.data.frame(network)
#Create and add "type" attribute to each one of the nodes
bipartite.map <- bipartite.mapping(network_graph)
type.net <- bipartite.map$type
V(network_graph)$type <- type.net
#Set colors and width
E(network_graph)$width = .3
E(network_graph)$color = rgb(.5,.5,0,.4)
E(network_graph)$numberlist
#Sphere
layout.sphere <- layout.sphere(network_graph)
plot.igraph(network_graph,vertex.color=c("lightblue","red")[V(network_graph)$type+1],layout = layout.sphere)
#Transfer matrix into web
network_matrix <- matrix(0,40,62)
colnames(network_matrix) <- seq(1,62,1)
rownames(network_matrix) <- seq(63,102,1)
for (i in 1:62){
  for (j in 63:102){
    for (p in 1:192){
      if (network[p,1]==i&&network[p,2]==j) network_matrix[(j-62),i] <- network[p,3]
    }
  }
}
#Plot web
plotweb(network_matrix)
#Plot graph and web of top composers 
index_top <- which(partition == 1)
index <- which(network[,2]=='63'|network[,2]=='79'|network[,2]=='80'|network[,2]=='81'|network[,2]=='92')
network_top <- network[index,]
network_top_graph <- graph.data.frame(network_top)
bipartite.map <- bipartite.mapping(network_top_graph)
type.net <- bipartite.map$type
V(network_top_graph)$type <- type.net
E(network_top_graph)$width = .3
E(network_top_graph)$color = rgb(.5,.5,0,.4)
E(network_top_graph)$label = E(network_top_graph)$numberlist
plot.igraph(network_top_graph, vertex.color=c("lightblue","red")[V(network_top_graph)$type+1])
network_matrix_top <- network_matrix[(index_top)-62,]
plotweb(network_matrix_top)
#Count number of connections
vertexlist <- V(network_top_graph)
connections_list = vector()
for (i in 1:(length(vertexlist)) ) {
  vertex = as.numeric(vertexlist[i])
  connections_vertex = neighborhood.size(network_top_graph, order = 1, vertexlist[i], mode="in")
  connections_list = append(connections_list, connections_vertex)
}
connections_list = connections_list-1
connections <- data.frame((vertexlist$name),(connections_list))
names(connections) <- c("Composer","Connections")
connections$Composer <- as.numeric(levels(connections$Composer))[connections$Composer]
connections <- connections[order(-connections$Connections),]  
connections_top <- connections[ (connections$Composer > 62),]
connections_top

#Not succesful:
network_not_succesful_ordered <- network[-index,]
temp <- network_not_succesful_ordered[order(-(as.numeric(network_not_succesful_ordered$numberlist))),]
not_sucessful_moreMovies = unique(temp[(as.numeric(temp$numberlist)>0),]$endlist)
network_not_succesful_ordered <- network[(network$endlist %in% not_sucessful_moreMovies),]
network_not_succesful_graph <- graph.data.frame(network_not_succesful_ordered)

network_not_succesful_ordered_filtered <- network[-index,]
temp <- network_not_succesful_ordered_filtered[order(-(as.numeric(network_not_succesful_ordered_filtered$numberlist))),]
not_sucessful_moreMovies_2 = unique(temp[(as.numeric(temp$numberlist)>2),]$endlist)
network_not_succesful_ordered_filtered <- network[(network$endlist %in% not_sucessful_moreMovies_2),]
network_not_succesful_graph_filtered <- graph.data.frame(network_not_succesful_ordered_filtered)


#Count number of connections
vertexlist <- V(network_not_succesful_graph)
connections_list = vector()
for (i in 1:(length(vertexlist)) ) {
  vertex = as.numeric(vertexlist[i])
  connections_vertex = neighborhood.size(network_not_succesful_graph, order = 1, vertexlist[i], mode="in")
  connections_list = append(connections_list, connections_vertex)
}
connections_list = connections_list-1
connections <- data.frame((vertexlist$name),(connections_list))
names(connections) <- c("Composer","Connections")
connections$Composer <- as.numeric(levels(connections$Composer))[connections$Composer]
connections <- connections[order(-connections$Connections),]  
connections_not_succesful <- connections[ (connections$Composer > 62),]
connections_not_succesful

#Plot graph for not succesful composers
bipartite.map <- bipartite.mapping(network_not_succesful_graph_filtered)
type.net <- bipartite.map$type
V(network_not_succesful_graph_filtered)$type <- type.net
E(network_not_succesful_graph_filtered)$width = .3
E(network_not_succesful_graph_filtered)$color = rgb(.5,.5,0,.4)
E(network_not_succesful_graph_filtered)$label = E(network_not_succesful_graph_filtered)$numberlist
plot.igraph(network_not_succesful_graph_filtered, vertex.color=c("lightblue","yellow")[V(network_not_succesful_graph_filtered)$type+1])

#Recommedation system
#Create one-mode graph of composers
network_composer_matrix <- as.one.mode(network_matrix,fill=0,project="lower",weighted=TRUE)
#Transfer web into matrix
network_composer <- cbind(expand.grid(dimnames(network_composer_matrix))[2:1],as.vector(network_composer_matrix))
network_composer <- network_composer[which(network_composer[,3] != 0),]
#Plot one-mode graph
network_composer_graph <- graph.data.frame(network_composer)
E(network_composer_graph)$width = .3
E(network_composer_graph)$color = rgb(.5,.5,0,.4)
plot.igraph(network_composer_graph, layout = layout.sphere )
#Association rule for the most successful composers
network_matrix_arule_top = data.frame(network_matrix_top)
col_names_top <- names(network_matrix_arule_top)
network_matrix_arule_top[,col_names_top] <- lapply(network_matrix_arule_top[,col_names_top],as.logical)
colnames(network_matrix_arule_top) <- seq(1,62,1)
str(network_matrix_arule_top)
rules_arule_top <- apriori(network_matrix_arule_top,parameter=list(maxlen=2,supp=0.4,conf=0.8))
summary(rules_arule_top)
inspect(rules_arule_top)
plot(rules_arule_top,method='graph')

#One-mode graph analysis of composers 
#Compute degree distribution
colnames(network_composer) <- c('src','dst','w')
composer_degree <- network_composer[,c(1,2)] %>%
  group_by(src) %>%
  summarize(degree=n()) %>%
  group_by(degree) %>%
  summarize(num_nodes=n())
qplot(x=degree,y=num_nodes,data=composer_degree,geom="line",xlab="Degree",ylab="Number of nodes")
#Compute the percentage of composers whose degree is no less than 7
degree1 <- nrow(network[network[,2]==63,])
degree2 <- nrow(network[network[,2]==79,])
degree3 <- nrow(network[network[,2]==80,])
degree4 <- nrow(network[network[,2]==81,])
degree5 <- nrow(network[network[,2]==92,])
degree <- min(degree1,degree2,degree3,degree4,degree5)
p_degree <- sum(composer_degree[composer_degree$degree>(degree-1),]$num_nodes)/sum(composer_degree$num_nodes)
#Plot distribution of path lengths
path_lengths <- path.length.hist(network_composer_graph)$res
qplot(x=1:length(path_lengths),y=path_lengths,xlab="Length of shortest path",ylab="Number of routes")
#Compute the percentage of composers whose path length is no more than 2
p_length <- sum(path_lengths[1]+path_lengths[2])/sum(path_lengths)
#Compute mean path length
sum(1:length(path_lengths)*path_lengths)/sum(path_lengths)
#Single source shortest path
network_composer <- network_composer[,c(1,2)]
network_composer1 <- data.frame()
for (i in 1:438){
  for (j in 1:2){
    network_composer1[i,j] <- as.numeric(as.character(network_composer[i,j]))
  }
}
network_composer_vector1 <- as.vector(t(as.matrix(network_composer1)))-62
network_composer_graph1 <- graph(network_composer_vector1,directed=T)
sp1 <- single_source_shortest_path(network_composer_graph1,1,T)
sp1_index <- which(sp1==1)+62
sp2 <- single_source_shortest_path(network_composer_graph1,17,T)
sp2_index <- which(sp2==1)+62
sp3 <- single_source_shortest_path(network_composer_graph1,18,T)
sp3_index <- which(sp3==1)+62
sp4 <- single_source_shortest_path(network_composer_graph1,19,T)
sp4_index <- which(sp4==1)+62
sp5 <- single_source_shortest_path(network_composer_graph1,30,T)
sp5_index <- which(sp5==1)+62

#Mutual friends
network_composer_graph2 <- graph(network_composer_vector1,directed=F)
network_composer2 <- get.data.frame(network_composer_graph2)
network_composer2 <- unique(network_composer2)
network_composer_vector2 <- as.vector(t(as.matrix(network_composer2)))
network_composer_graph2 <- graph(network_composer_vector2,directed=F)
M <- mutual_friends(network_composer_graph2)
M
people_you_might_know(M,1)
people_you_might_know(M,17)
people_you_might_know(M,18)
people_you_might_know(M,19)
people_you_might_know(M,30)
#Plot and count triangles
plot(network_composer_graph2)
triangles <- count_triangles(network_composer_graph2)
(order(triangles,decreasing=T)+62)[1:6]



