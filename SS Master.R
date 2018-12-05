# SS Master.R
# library(rNeo4j) # turn on via packages in RStudio
options(stringsAsFactors = FALSE)
setwd("/Users/Scott/Documents/Projects/DFO Salmon Net/Data from R")
# applies a suite of functions to create RoundTable nodes in a neo4j graph.
# Track IDs for each Resource type for Links. First by Person.
## Codes for Nodes (strings, not integers)
#  each has 1 M possibilities, person "O1" from 01000000 to 01999999
    ResourceType=c("Person","Organization","Tag","Place","Address","Contact",
        "Document","WebPage","Event","WorkGroup","Activity");
    ResourceCode=c("01","02","03","04","05","06","07","08","09","10","11")
    names(ResourceCode)=ResourceType; ResourceCode
# Person Organization          Tag        Place      Address
#    "01"         "02"         "03"         "04"         "05"
# Contact     Document      WebPage        Event    WorkGroup   Activity
#    "06"         "07"         "08"         "09"         "10"        "11"

## Codes for Links
    LinkCode=c("00","01","02","03","04","05","06" ) # "00" is "has" is default
    LinkName=c("has","isIn", "reportsTo","worksWith","created","leads","isVersionOf")
    names(LinkCode)=LinkName; LinkCode
# has isIn   reportsTo   worksWith     created       leads isVersionOf
# "00" 01"        "02"        "03"        "04"        "05"        "06"

## Codes for Edges (for QC)
# xxyyzz: xx is From, yy is To , zz is LinkType
# 010100 is O1 Person   to 01 Person   by 00 hasPerson
# 111103 is 11 Activity to 11 Activity by 03 worksWith
# 1 M of each EdgeType: 010100,000000 to 010100,999999; 12 character id

# Example
surveyFile= "/Users/Scott/Documents/Projects/DFO Salmon Net/Data/SurveyMonkey2017January23 trimmed.csv"; file.exists(surveyFile)
srvy= as.data.frame(read.csv(
    surveyFile,header=TRUE, colClasses="character"));
names(srvy)
# [1] "EmailAddress"  "FirstName" "LastName" "PositionAndTitle"
# [5] "Organization2" "Place"  "Organization1" "Telephone"
# [9] "Work" "Colleagues"  "LikeToReceiveSupport"
# write(unlist(strsplit(srvy$Colleagues,",")), "colleagues.csv") # added new people

graph = startGraph("http://localhost:7474/db/data/", username=neo4j,password=)
clear(graph)
PersonID=PersonNode(srvy$FirstName,srvy$LastName,description=srvy$PositionAndTitle);
OrganizationID=OrganizationJSON(srvy$OfficeLocation)
TagID=TagJSON(paste(srvy$Work,srvy$LikeToReceiveSupport,sep=",") )




