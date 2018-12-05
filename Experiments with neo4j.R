# Experiments with neo4j.R
# Scott Akenhead scott@s4s.com 240.210.4410 2017 July 18
	library(RNeo4j)  # note capital letters
	library(igraph)
	setwd("/Users/Scott/Documents/Projects/DFO Salmon Net/DFO Net R")
# start neo4j manually via Applications.  
# location is /Users/Scott2/Documents/Neo4j/default.graphdb
# I had to remove authentication to get a graph started in R:
# 		find file: /Users/Scott2/Documents/Neo4j/.neo4j.conf 
# 		find line: dbms.security.auth_enabled=true and edit to be "false"
	
	graph = startGraph("http://localhost:7474/db/data/", username="neo4j", password="GaB-EX8-Rbx-Ny7")
	clear(graph) # else old graph persists. answer with capital Y
	a=scan(sep=",",what=list("a","a","a"),strip.white=T); # a list of lists 
CentralAndArctic,Karen Dunmall,Karen.Dunmall@dfo-mpo.gc.ca
Gulf,Patricia Edwards,Patricia.Edwards@dfo-mpo.gc.ca
Maritimes,Marc Trudel,Marc.Trudel@dfo-mpo.gc.ca
Ottawa,Roger Wysocki,Roger.Wysocki@dfo-mpo.gc.ca
Newfoundland,Erin Dunne,Erin.Dunne@dfo-mpo.gc.ca 
BC,Jim Irvine, James.Irvine@dfo-mpo.gc.ca
Yukon, Joel Harding,Joel.Harding@dfo-mpo.gc.ca
Quebec,Michael Scarratt,Michael.Scarratt@dfo-mpo.gc.ca
BC,Diana Dobson,Dobson.Diana@dfo-mpo.gc.ca
BC,Sue Grant,Sue.Grant@dfo-mpo.gc.ca
BC,Ann-Marie Huang,Ann-Marie.Huang@dfo-mpo.gc.ca
BC,Scott Akenhead,Scott.Akenhead@dfo-mpo.gc.ca

	a
	id=gsub(" ","",a[[2]])  # names without blanks, see trimws(x, which = c("both", "left", "right"))
	for(j in 1:length(a[[1]]) ){
		createNode(graph,"PERSON",name=a[[2]][j], email=a[[3]][j] )
    }
    for(j in 1:length(a[[1]]) ){
		query = "MATCH (:PERSON {name=a[[2]][j]} ) 
    }
CentralAndArctic = createNode(graph, "LOCATION", Type="Region",   name="Central and Arctic Region");
BC = createNode(graph, "LOCATION", Type="Region",   name="Pacific (BC) Region");
Yukon = createNode(graph, "LOCATION", Type="Region",   name="Pacific (Yukon) Region");
Gulf = createNode(graph, "LOCATION", Type="Region",   name="Gulf Region");
Maritimes = createNode(graph, "LOCATION", Type="Region",   name="Maritimes Region");
Ottawa  = createNode(graph, "LOCATION", Type="Region",   name="National Capital Region");
Quebec = createNode(graph, "LOCATION", Type="Region",   name="Quebec Region");
Newfoundland = createNode(graph, "LOCATION", Type="Region",   name="Newfoundland and Labrador Region");

PBS = 
    createNode(graph, "LOCATION", Type="Building", name="Pacific Biological Station");
FreshwaterInstitute =
    createNode(graph, "LOCATION", Type="Building", name="Freshwater Institute");

	createRel(ScottAkenhead,       "WorksAt",   PBS);
	createRel(JimIrvine,           "WorksAt",   PBS)
	createRel(KarenDunmall,        "WorksAt",   FreshwaterInstitute)
	createRel(PBS,                 "LocatedIn", Pacific)
	createRel(FreshwaterInstitute, "LocatedIn", CentralAndArctic)


	b=cypher(graph, "MATCH (n) RETURN n.name"); # formal names for all nodes
	b
	query="MATCH (p)-[:WorksAt]->(q:LOCATION) WHERE q.TYPE = {Region} RETURN p.name, q.name"
 	cypher(graph, query)
	         n.name
1     Jim Irvine
2 Scott Akenhead
3  Karen Dunmall

	query = "MATCH (n)-->(m)
			 RETURN n.name, m.name"
	edgelist = cypher(graph, query)
	
	
	
# First, pull out a node and the data in that node. Plot that.	

	query = "MATCH (n:CU)
			 RETURN n.name, n.productivity,n.capacity"
	a=cypher(graph,query); # creates a data.frame (a table)
	names(a) <- substr(names(a),3,3); a=a[1,];a
#        n  p  c
#1  Chilko  7  2
	
# Second, pull out a habitat that has an effect on the preceding node
	
	query = "MATCH (h:Habitat)-[r:Affects]->(n:CU) WHERE r.effect > 1.0
			 RETURN h.name, r.effect, n.name, n.productivity,n.capacity"
	b=cypher(graph,query); 
	names(b) <- substr(names(b),3,3); b=b[1,];b
#            n   e      n  p   c
#1  Fertilizer 1.1 Chilko 15 2.4

# Do it again!  Different criterion.

	query = "MATCH (h:Habitat)-[r:Affects]->(n:CU) WHERE r.effect < 1.0
			 RETURN h.name, r.effect, n.name, n.productivity,n.capacity"
	b=cypher(graph,query); 
	names(b) <- substr(names(b),3,3); b=b[1,];b
#                  n   e      n p c
# 1 Spawning Channel 0.5 Chilko 7 2
