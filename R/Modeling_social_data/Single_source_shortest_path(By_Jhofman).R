# function to calculate distance from a single source to all other nodes via BFS
single_source_shortest_path <- function(G, source, plot=F) {
  # initialize all nodes to be inifinitely far away
  # and the source to be at zero
  dist <- rep(Inf, vcount(G))
  names(dist) <- V(G)$name
  dist[source] <- 0
  
  # initialize the current boundary to be the source node
  curr_boundary <- c(source)
  
  # explore boundary as long as it's not empty
  while (length(curr_boundary) > 0) {
    if (plot)
      plot_bfs(G, dist, curr_boundary)
    
    # create empty list for new boundary
    next_boundary <- c()
    
    # loop over nodes in current boundary
    for (node in curr_boundary)
      # loop over their undiscovered neighbors
      for (neighbor in neighbors(G, node))
        if (!is.finite(dist[neighbor])) {
          # set the neighbor's distance
          dist[neighbor] = dist[node] + 1
          # add the neighbor to the next boundary
          next_boundary <- c(next_boundary, neighbor)
        }
    
    # update the boundary
    curr_boundary <- unique(next_boundary)
  }
  
  if (plot)
    plot_bfs(G, dist, curr_boundary)
  
  dist
}

# helper function to plot bfs iteration
plot_bfs <- function(G, dist, curr_boundary) {
  set.seed(42)
  discovered <- which(is.finite(dist))
  colors <- rep('white', vcount(G))
  colors[discovered] <- 'black'
  colors[curr_boundary] <- 'grey'
  plot.igraph(G, vertex.color=colors)
  print(sprintf('bfs iteration %d', max(dist[discovered])))
  print(sprintf('discovered (black): %s', paste(discovered, collapse=" ")))
  print(sprintf('current boundary (grey): %s', paste(curr_boundary, collapse=" ")))
  line <- readline('hit enter to continue')
}
