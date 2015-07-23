# function to count the number of mutual friends between every pair of nodes
mutual_friends <- function(G) {
  # initialize an emptry matrix to store number of mutual friends between pairs of nodes
  num_nodes <- vcount(G)
  mutual_friends <- matrix(0, nrow=num_nodes, ncol=num_nodes)
  
  # loop over each node
  for (node in 1:num_nodes) {
    # get this node's list of friends
    friends <- neighbors(G, node)
    
    # add a count of 1 between all pairs of the node's friends
    for (i in friends)
      for (j in friends)
        mutual_friends[i, j] = mutual_friends[i, j] + 1
  }
  
  # make the output readable with column names
  dimnames(mutual_friends) <- list(row=V(G)$name, col=V(G)$name)
  diag(mutual_friends) <- NA
  mutual_friends
}

# function to get "people you might know" based on mutual friend counts
people_you_might_know <- function(M, node) {
  recs <- c(which(M[node,] == max(M[node,], na.rm=T)))
  sprintf('node %d might know node(s) %s', node, paste(recs, collapse=" and "))
}