# function to count triangles
count_triangles <- function(G) {
  num_nodes <- vcount(G)
  
  # initialize a counter for the number of triangles at each node
  triangles <- rep(0, num_nodes)
  
  # loop over each node
  for (node in 1:num_nodes) {
    # get this node's list of friends
    friends <- neighbors(G, node)
    
    # add a count of 1 for each pair of the node's friends that are connected
    for (i in friends)
      for (j in friends)
        if (are.connected(G, i, j))
          triangles[node] = triangles[node] + 1
  }
  
  # make the output readable with column names
  names(triangles) <- V(G)$name
  triangles / 2.0
}