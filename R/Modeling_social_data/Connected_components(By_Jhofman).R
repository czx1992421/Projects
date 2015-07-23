# function to compute connected components of a graph via BFS
connected_components <- function(G) {
  components <- rep(NA, vcount(G))
  
  label <- 1
  
  # loop until all nodes are assigned to a component
  while (any(is.na(components))) {
    # sample an unassigned node
    source <- sample(which(is.na(components)), 1)
    
    # do a bfs from this source
    dist <- single_source_shortest_path(G, source)
    
    # label reachable nodes
    components[is.finite(dist)] <- label
    
    # increment label
    label <- label + 1
  }
  components
}