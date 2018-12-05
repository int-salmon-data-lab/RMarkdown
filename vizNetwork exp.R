# gvizNeo4j.R
# Use a Cypher query that returns an edgelist and plot with Google Viz
MATCH (u:User)-->(r:Repo)
query="MATCH (u:User)-->(r:Repo) RETURN u.name AS from, r.name AS to"
edges = cypher(neo4j, query)
nodes = data.frame(id=unique(c(edges$from, edges$to)))
nodes$label = nodes$id
visNetwork(nodes, edges)
