# Experiments with neo4j.R
# Scott Akenhead scott@s4s.com 240.210.4410 2017 July 18
	library(RNeo4j)  # note capital letters
	library(visNetwork)
	options(stringsAsFactors =F)
	setwd("/Users/Scott/Documents/Projects/DFO_Salmon_Net")
	source("DFO Net R/List2Rows.R") # multiplies rows to uwind a list in a cell
	source("DFO Net R/Correspond.R") # matches two columns with scattered repeats

	col=c("skyblue","peachpuff","chartreuse", "seagreen")

# note: gsub(" ","",a[[2]]) will remove all blanks, see trimws(x,which="both")
graph = startGraph("http://localhost:7474/db/data/",
    username="neo4j", password="GaB-EX8-Rbx-Ny7")
# or start neo4j manually via Applications.
# location is /Users/Scott2/Documents/Neo4j/default.graphdb
# One may remove authentication to start a graph in R:
# 		find file: /Users/Scott2/Documents/Neo4j/.neo4j.conf
# 		find line: dbms.security.auth_enabled=true and edit to be "false"
#--------------------------------

# Ideas
# create generalizations of ideas from survey: lists of work and "needs support"
	survey=read.csv("Data/SurveyMonkey2017January23trimmed.csv") # 51 rows
	names(survey)
# "person"  "email" "PosTitle" "place" "org1" "org2" "org3" "telephone"
#	"work" "colleague" "needsSupport"

	a2=List2Rows(survey[,c("person","needsSupport")]); # 91 rows
	j=is.na(a2[,2]) | (a2[,2] ==""); sum(j) # 29 without a needs support idea
	a2=a2[!j,] # 62
	a=rbind(a1,a2);dim(a) #130
	write.csv(a,"Data/idea.csv",row.names = F) # this is Person hasIdeaTag

# hand edit the generalizations of these ideas to create idea_general.csv
# delete person in idea_general, so this is IdeaTags for IdeaTags.
	b=read.csv("Data/idea_general.csv") # 121 rows
# new ideas added?
	b1=List2Rows(b); # 182 after expanding multiple parent ideas
	j=unique(b1[,2]) %in% b1[,1]; sum(j); # 9 UNIQUE parent ideas are in original child ideas
	unique(b1[,2])[!j] # but these 24 are new
	# [1] "tagging"                     ""
	# [3] "Yukon River Salmon"          "Arctic Salmon"
	# [5] "data management"             "collaboration"
	# [7] "fisheries management"        "freshwater survival"
	# [9] "modeling and statistics"     "management"
	# [11] "climate change"              "population status"
	# [13] "genetics"                    "surveys"
	# [15] "innovation"                  "toxins"
	# [17] "fish disease"                "hatcheries"
	# [19] "population identification"   "climate"
	# [21] "Atlantic Salmon"             "salmon status"
	# [23] "international collaboration" "energetics"
# I will ignore parents for these 24 new ideas.
	write.csv(b1[b1[,2]=="",1],"Data/newIdea.csv",row.names = F) # no parent
	write.csv(b1[b1[,2]!="",],"Data/Idea_hasIdea.csv",row.names = F) #

# again for Person with multiple colleagues
	a=List2Rows(survey[,c("person","colleague")]);dim(a) # 80 rows
	j=unique(a[,2]) %in% a[,1]; sum(j); # 30 old names
	unique(a[!j,2]) # three: "", "Mark Shrimpton", "Jeff Grout"
    a1=a[ a[,2]!="", ];dim(a1)[1]; # 43
    write.csv(a1,"Data/Person_hasPerson.csv",row.names = F)

#---------------------
    clear(graph) # else old graph persists. answer with capital Y
#--------------------
# start building graph with hand-edited spreadsheet of survey
    a = cypher(graph,
'LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/SurveyMonkey2017January23trimmed.csv" AS survey
CREATE (:Person{name:survey.person}) -[:hasContactService]-> (:ContactService {email:survey.email, phone:survey.telephone})
MERGE  (at:Place{name:survey.place})
MERGE (org3:Organization{name:survey.org3,type:"org3"})
MERGE (org2:Organization{name:survey.org2,type:"org2"})
MERGE (org1:Organization{name:survey.org1,type:"org1"})
RETURN at.name, org2.name' );

    a = cypher(graph,
'MATCH (org:Organization {type:"org3"}) RETURN org.name'); a;
    # "Ecosystem Science and Management Program"
    # "Arctic Aquatic Research Division"
    # "FWI Genetics lab"
    # "FWI Stock Assessment;"
    # etc. total 30
    a = cypher(graph,
'MATCH (at:Place) RETURN at.name'); a;
    # at.name
    # 1  University of Northern British Columbia
    # 2                     Freshwater Institute
    # 3                    Gulf Fisheries Centre
    # etc. total 16

# link Person to Work ideas without duplicating nodes
    a1=List2Rows(survey[,c("person","work")]); # 94 rows
    for (j in 3:nrow(a1)) { # repeated Person to match each IdeaTag
        if(a1[j,2] =="") next;
        query=paste0(
'MATCH (who:Person{name:"', a1[j,1], '"})
 MERGE  (it:IdeaTag{name:"', a1[j,2], '"})
 CREATE (who)-[:hasIdeaTag{type:"work"}]-> (it)
 RETURN who.name, it.name' );
    a = cypher(graph, query); print(a);
    }

    a = cypher(graph,
'MATCH (who:Person{name:"Mark Saunders"}) -[:hasIdeaTag]-> (t)
RETURN t.name'); print(a);
    #                          t.name
    # 1       partnerships for salmon
    # 2            strategic planning
    # 3 Development of IYS initiative
    # 4                           IYS
    # check for duplicates
    a = cypher(graph,
'MATCH (t:IdeaTag)
 WITH t.name as tag, count(t) as tot
 WHERE tot > 1 RETURN tag, tot'   ); print(a) # NULL

# link Person to IdeaTags from needsSupport without creating duplicates
    a1=List2Rows(survey[,c("person","needsSupport")]); # nrow = 91
    for (j in 1:nrow(a1)) { # repeated Person to match each IdeaTag
        if(a1[j,2] =="") next; # no IdeaTag
        query=paste0(
'MATCH (who:Person{name:"', a1[j,1], '"})
 MERGE (it:IdeaTag{name:"', a1[j,2], '"})
 CREATE (who) -[:hasIdeaTag {type:"needs"}]-> (it)
 RETURN who.name, it.name' );
        a = cypher(graph, query); print(a);
    }
# check for duplicates

# check for new ideas
    a = cypher(graph,
'MATCH (who:Person{name:"Mark Saunders"}) -[:hasIdeaTag {type:"needs"}]-> (t)
 RETURN t.name'); print(a);
    # t.name
    # 1 DFO priorities re IYS
    # 2              planning
#-----------

# add IdeaTag has IdeaTag including tags that generalize those from the survey
    it2=read.csv("Data/Idea_hasIdea.csv") # 166 row by 2 cols
    for (j in 2:nrow(it2)) { # has repeated children for one parent
        if(it2[j,2] =="") next; # no parent IdeaTag
        query=paste0(
'MATCH (child:IdeaTag {name:"', it2[j,1], '"})
 MERGE (parent:IdeaTag{name:"', it2[j,2], '"})
 CREATE (child) -[:hasIdeaTag {type:"parent"}]-> (parent)
 RETURN child.name, parent.name' );
        a = cypher(graph,query); print(a);
    }
#







    j=is.na(a2[,2]) | (a2[,2] ==""); sum(j) # 29 without a needs support idea
    a2=a2[!j,] # 62
    a=rbind(a1,a2);dim(a) #130
    write.csv(a,"Data/idea.csv",row.names = F) # this is Person hasIdeaTag

    #-------
    for (j in 3:length(a1)){
        if(a1[[j]]$has =="") next; # no IdeaTag re work
        b1=a1[[j]]$id ; b2=a1[[j]]$has
        for(l in 1:length(b2))
        query=paste(
'MATCH (who:Person{type:"',b1,'"})
CREATE (who)-[:hasIdeaTag]-> (:IdeaTag{name="'a1[j,1],'"})
RETURN org.name');
	a = cypher(graph, query); print(a);
    }

MERGE (who) -[:hasPlace]-> (at:Place{name:survey.place})
MATCH (p:Place{name:"PBS"})
CREATE (:Person{name:"Kim Hyatt"}) -[:hasPlace]-> (p)


:Place{name:survey.place})
MERGE (who)  -[:hasOrg{type:"worksFor"}]->  (org3:Organization{name:survey.org3,type:"org3"})
MERGE (org3) -[:hasOrg{type:"hasParent"}]-> (org2:Organization{name:survey.org2,type:"org2"})
MERGE (org2) -[:hasOrg{type:"hasParent"}]-> (org1:Organization{name:survey.org1,type:"org1"})
RETURN who.name, at.name, org3.name,org2.name,org1.name'
    )

    p1=cypher(graph,
'MATCH (:Place{name:"Kamloops"})<-[]-(who:Person) RETURN who.name'); p1;
    who.name
# 1    Keri Benner
# 2 Richard Bailey
# 3   Chuck Parken
    who.name=cypher(graph,
'MATCH (:Organization{name:"Aquatic Resources and Assessment"}) -- (who:Person) RETURN who.name');
    who.name
# 1       Jim Reist
# 2     Kendra Holt
# 3      Dan Selbie
# 4 Arlene Tompkins
# 5     Carrie Holt
# 6    Lyse Godbout
# 7    Bruce Patten


    p1=cypher(graph,
'LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/Person_hasPerson.csv" AS php
MERGE (p:Person{name:php.id}) -[:hasPerson]-> (c:Person{name:php.char})
RETURN count(p), count(c)'); p1
# count(p) count(c)
# 1       43       43

# Who named Marl Trudel as colleague?
    cypher(graph,
'MATCH (n)-[:hasPerson]-> (:Person {name:"Marc Trudel"})
RETURN n.name' );
    #                   n.name
    # 1 Kristi Miller-Saunders
    # 2         Rusty Sweeting
    # 3        Stewart Johnson
    p1=cypher(graph,
'LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/idea.csv" AS rows
MERGE (p:Person{name:rows.id}) -[:hasIdeaTag]-> (c:IdeaTag{name:rows.char})
RETURN count(p), count(c)'); p1
#   count(p) count(c)
# 1      130      130

# who has IdeaTag salmon tagging?
   p1= cypher(graph,
'MATCH (n)-[:hasIdeaTag]-> (:IdeaTag {name:"salmon tagging"})
RETURN n.name
   '); p1
    # n.name
    # 1       Jim Irvine
    # 2 Michael Scarratt

    p1=cypher(graph,
'LOAD CSV WITH HEADERS FROM
"file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/NewIdea.csv" AS rows
MERGE (n:IdeaTag {name:rows.x})
RETURN count(n), n.name
    '); p1   # 22, expected 17 (?)


     p1=cypher(graph,
'LOAD CSV WITH HEADERS FROM
"file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/Idea_hasIdea.csv" AS rows
MERGE (from:IdeaTag {name:rows.id}) -[:hasIdeaTag]-> (to:IdeaTag {name:rows.char})
RETURN count(from), count(to)
    '); p1  # 166 166 perfect


     p1=cypher(graph,
'MATCH  (p:IdeaTag) -[:hasIdeaTag]-> (:IdeaTag {name:"tagging"})
RETURN p.name
    '); p1
     # p.name
     # 1              acoustic telemetry
     # 2 new technologies and techniques
     # 3  pop-up satellite archival tags
     # 4        salmon sampling in ocean
     # 5                  salmon tagging

     p1=cypher(graph,
'MATCH (p:IdeaTag) -[:hasIdeaTag]-> (:IdeaTag {name:"tagging"})
 MATCH (p)         -[:hasIdeaTag]-  (who:Person)
 RETURN who.name
    '); p1 # NULL   ?

     p1=cypher(graph,
'MATCH (who:Person) -[:hasIdeaTag]-> (:IdeaTag) -[:hasIdeaTag]-> (:IdeaTag {name:"tagging"})
RETURN who.name
'); p1 # NULL   ?

     p1=cypher(graph,
'MATCH (:Person {name:"Jim Irvine"}) -[:hasIdeaTag]-> (tag:IdeaTag)
RETURN tag.name
'); p1 # NULL   ?
 # 1 marine interactions between salmon and ecologically linked species
 # 2                  integrate fisheries and oceanographic information
 # 3                                        marine productivity factors
 # 4                                                     Pacific Salmon
 # 5                           experimental releases of hatchery salmon
 # 6                                                     salmon tagging
 # 7                                           salmon sampling in ocean
     p1=cypher(graph,
'MATCH (:IdeaTag {name:"salmon tagging" }) -[:hasIdeaTag]-> (tag:IdeaTag)
RETURN tag.name
'); p1 # NULL   ?
# 1  tagging
     p1=cypher(graph,
'MATCH (who:Person) -[:hasIdeaTag]-> (:IdeaTag {name:"salmon tagging"}) -[:hasIdeaTag]-> (tag:IdeaTag)
 RETURN who.name,tag.name
'); p1
     # NULL   ?

     p1=cypher(graph,
'MATCH (:Person {name:"Michael Scarratt"}) -[:hasIdeaTag]-> () -[:hasIdeaTag]-> (g:IdeaTag)
RETURN g.name '); p1  # NULL ?

     p1=cypher(graph,
'MATCH (:Person {name:"Michael Scarratt"}) -- (g:IdeaTag)
 RETURN g.name '); p1
     # g.name
     # 1                             oceanography
     # 2                  biological oceanography
     # 3                    chemical oceanography
     # 4                    physical oceanography
     # 5 oceanography of the Gulf of St. Lawrence
     # 6                           salmon tagging
     # 7                         salmon migration
     # 8                 oceanographic monitoring
     # 9                          marine survival

     p1=cypher(graph,
'MATCH (:Person {name:"Michael Scarratt"}) -- (:IdeaTag) -- (tag2:IdeaTag)
 RETURN tag2.name '); p1  # NULL

     p1=cypher(graph,
'MATCH (who:Person) -- (tag1:IdeaTag) -- (tag2)
WHERE who.name="Michael Scarratt" AND tag2.name="tagging"
RETURN tag1.name '); p1  # NULL

    p1=cypher(graph,
'MATCH (tag1:IdeaTag) -- (IdeaTag {name:"tagging"})
RETURN tag1.name'); p1  # 5 results including "salmon tagging"

     p1=cypher(graph,
'MATCH (:IdeaTag {name:"salmon tagging"}) -[:hasIdeaTag]-> (t)
RETURN t.name '); p1  # "tagging"

     p1=cypher(graph,
'MATCH (:Person {name:"Michael Scarratt"}) -[:hasIdeaTag]-> (tag1),
       (tag1) -[:hasIdeaTag]-> (tag2)
RETURN tag1.name, tag2.name '); p1





    cypher(graph,
'MATCH (org:Organization{name:"Science"}) RETURN COUNT(org)') # 37
    cypher(graph,
'MATCH (p) -[:hasOrg{type:"hasParent"}]-> (:Organization{name:"Science"})  RETURN p.name')

cypher(graph, query) # returns 3 Person
#          who.name
# 1    Bruce Patten
# 2 Arlene Tompkins
# 3       Jim Reist

# Org structure
    edge=cypher(graph,
'MATCH (from:Organization)-->(to:Organization)
RETURN from.name AS from, to.name AS to' )  # 84
# 1. catch all nodes including those linked to or from NA
    id=unique(c(edge$from, edge$to))
#2. remove nodes that were blank, now NA in R
    id=id[!is.na(id)]
    node = data.frame(id=id,label=id)
# 3. remove the NAs from links
    edge=edge[!(is.na(edge$to) | is.na(edge$from)),] # not is.na, 78
# 4. remove redundant links
    edge=unique(edge) # 36
#5 remove links to self, e.g. (SFU) --> (SFU)
    edge=edge[edge$to != edge$from, ] # 33
#5. plot
    visNetwork(node, edge)

# who where
    edge1 = cypher(graph,
'MATCH (who:Person)-->(at:Place) RETURN who.name AS from, at.name AS to')
    id=unique(c(edge1$from,edge1$to))
    id=id[!is.na(id)]
    node1 = data.frame(id=id,label=id, color= col[3]) # color: to place
    node1$color[node1$id %in% edge1$from] = col[2] # color: from person
    visNetwork(node1, edge1) %>% visEdges(color="black");
edge1[1:3,]
# from         to
# 1       Ian Bradbury       NAFC
# 2        Keri Benner   Kamloops
# 3     Jennifer Nener  Vancouver

# who for
    edge = cypher(graph,
'MATCH (who:Person)-[]->(for:Organization{type:"org3"}) RETURN who.name AS from, for.name AS to')

# 1. catch all nodes including those linked to or from NA
    id=unique(c(edge$from, edge$to))
#2. remove nodes that were blank, now NA in R
    id=id[!is.na(id)]
    node = data.frame(id=id,label=id)
# 3. remove the NAs from links
    edge=edge[!(is.na(edge$to) | is.na(edge$from)),] # not is.na
# 4. remove redundant links
    edge=unique(edge)
# 5. remove links to self, e.g. (x) --> (x)
    edge=edge[edge$to != edge$from, ]
# 6. change colors
    node$color= col[1] # to Org
    node$color[node$id %in% edge$from] = col[2] # from person
# 7. plot
   visNetwork(node2, edge2) %>% visEdges(color="black");
   edge[1:3,]
# from                               to
# 1 Ian Bradbury environmental resource salmonids
# 2 Ian Bradbury                          Science
# 4  Keri Benner          Fraser Stock Assessment

# who where what
   edge3 = rbind(edge1,edge)
   node3 = rbind(node1,node)
   node3=node3[!duplicated(node3$id),] # so Person is not repeated
   node3$color= col[1]  # org
   node3$color[node3$id %in% edge2$from] = col[2] # from person
   node3$color[node3$id %in% edge1$to] = col[3]   # to place
   visNetwork(node3, edge3)%>% visEdges(color="black");

# ideas
# requires expanding a list inside a CSV string: List2long()
    a1=read.csv("/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/SurveyMonkey2017January23trimmed.csv") # 51 row 11 col
    names(a1)
# "person"  "email"   "PosTitle"   "place" "org1"  "org2"  "org3"
# "telephone"    "work"  "colleague" "needsSupport"
    b=a1[a1$work!="", c("person","work")];dim(b) # 25
    b1=List2long(b$person, b$work) #61
    names(b1)=c("person","work")
    file="/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/PersonWork.csv"
    write.csv(b1, file, row.names=F)
    query='LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/PersonWork.csv" AS pw
MERGE (who:Person {name:pw.person}) -[:hasIdeaTag]-> (idea:IdeaTag{name:pw.work})
RETURN who.name, idea.name'
    a = cypher(graph, query); dim(a) # 11 seconds
    a[1:10,] # 61 rows
    cypher(graph,'MATCH (:Person{name:"Steve Smith"}) --> (i:IdeaTag) RETURN i.name')
    #                       i.name
    # 1    Salmon Stock Assessment
    # 2 Yukon Fisheries Management
    # 3              Stikine River
    # 4                 Taku River
    # 5                Alsek River

# more ideas
    b=a1[a1[,11] !="", c(1,11)];dim(b) # 22
    b1=List2long(b[,1], b[,2] ); dim(b1) #62
    names(b1)=c("person","idea")
    file="/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/PersonIdea2.csv"
    write.csv(b1, file, row.names=F)
    query='LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/PersonIdea2.csv" AS pt
    MERGE (who:Person{name:pt.person}) -[:hasIdeaTag]-> (idea:IdeaTag{name:pt.idea})
    RETURN who.name, idea.name'
    a = cypher(graph, query); dim(a) # 11 seconds 62 rows
    cypher(graph,'MATCH (:Person{name:"Steve Smith"}) --> (i:IdeaTag) RETURN i.name')
    # returns with a 6th idea added.
    edge = cypher(graph,
    'MATCH (who:Person)-[]->(idea:IdeaTag)
     RETURN who.name AS from, idea.name AS to')
    # 1. catch all nodes including those linked to or from NA
    id=unique(c(edge$from, edge$to))
    node = data.frame(id=id,label=id)
    # 6. change colors
    node$color= col[4] # to idea
    node$color[node$id %in% edge$from] = col[2] # from person
    # 7. plot
    visNetwork(node, edge) %>% visEdges(color="black");
    file="/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/ideaNodes.csv"
    write.csv(node, file, row.names=F)

# and finally, ideas to organize (generalize) the previous ideas
    file="/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/ideaNodes.csv"
    write.csv(node, file, row.names=F) # list of people and ideas, length 145
    # by hand, remove person, add generalizations and categories: new ideas about the old ideas
    # keep the new "from" tags separate to create nodes for these
    # then add "to" tags after deleting cases where there is no "to" tag
    # "Cannot merge node using null property value for name"
    # this first time, I lost track of the new tags, so a bit of hacking, sorry.
    a3=read.csv(file);a3[a3$hasTag =="",1] # test, see tags without tags, not all are top level
    which(duplicated(a3$tag)); # should be none
    # pull out the new ideas, add these to the graph.
    j=a3$tag %in% node[,1]; sum(!j) # 24
    a31=a3[!j,"tag"];# NOTE: a31 is vector, not dataframe, no column name, default is "x"
    file="/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/newIdeas.csv"
    write.csv(a31,file,row.names=F)
    read.csv(file) # check. notice header is "x"
    cypher(graph, 'LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/newIdeas.csv" AS ni MERGE (from:IdeaTag {name:ni.x}) RETURN from.name')
    #                    from.name
    # 1              Arctic Salmon
    # 2            Atlantic Salmon
    # 3                    climate
    # 4              collaboration
    # 5            data management
    # etc. to 24

    # now all the tags are in, make links between tags.
    # in from and to, remove rows with empty to.
    a3=a3[a3$hasTag !="",] # 111
    a32=List2long(a3) # colnames are "id", "char"
    file="/Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/IdeahasIdea.csv"
    write.csv(a32,file,row.names=F)
    cypher(graph,
'LOAD CSV WITH HEADERS FROM "file:///Users/Scott/Documents/Projects/DFO_Salmon_Net/Data/IdeahasIdea.csv" AS ihi
MERGE (from:IdeaTag {name:ihi.id}) -[:hasIdeaTag]-> (to:IdeaTag {name:ihi.char})
RETURN from.name, to.name') # < 2 seconds

# vis for Person hasIdeaTag hasIdeaTag
    edge1=cypher(graph,
'MATCH (who:Person) -[:hasIdeaTag]-> (phi:IdeaTag)
RETURN who.name as from, phi.name as to')  # 123
    edge2=cypher(graph,
'MATCH (from:IdeaTag) -[:hasIdeaTag]-> (to:IdeaTag)
RETURN from.name as from, to.name as to') # 196
    edge=rbind(edge1,edge2)
    id=unique(c(edge$from, edge$to)) # 172
    node = data.frame(id=id,label=id)
    node$color= col[4] #  idea attached to person
    node$color[node$id %in% edge1$from] = col[2] #  person
    node$color[node$id %in% edge2$to] = col[3] # idea attached to idea
    visNetwork(node, edge)
#-------------
#
# specific queries
        jim=cypher(graph,
'MATCH (from:Person{name:"Jim Irvine"}) RETURN from.name' ) # 8 results (?)

    jim=cypher(graph,
'MATCH (who:Person{name:"Jim Irvine"}) -- (what:IdeaTag)
RETURN what.name'); jim
# 1 interactions between salmon and ecologically linked species in the marine environment
# 2 integrate fisheries and oceanographic information
# 3 factors controlling marine productivity
# 4 Pacific salmon
# 5 Experimental releases of hatchery salmon
# 6 salmon tagging
# 7 salmon sampling in ocean

    jim=cypher(graph,
'MATCH (p1:Person) -[:hasIdeaTag]-> (:IdeaTag{name:"salmon tagging"})
RETURN p1.name' ); jim
#           p1.name
# 1 Michael Scarratt
# 2       Jim Irvine

    jim=cypher(graph,
'MATCH (p1:Person) -[]-> (:IdeaTag{name:"salmon tagging"})
RETURN p1.name' ); jim
    jim=cypher(graph,
'MATCH (:Person{name:"Jim Irvine"}) -[:IdeaTag*]-> (to:IdeaTag) RETURN to.name' ); jim  # NULL, dang!

    jim=cypher(graph,
'MATCH (:Person {name:"Jim Irvine"}) -[:hasIdeaTag]-> (thought:IdeaTag)
WITH thought
MATCH (thought) <-[:hasIdeaTag*1..7]- (:Person) ->]RETURN to.name' )
