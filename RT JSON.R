# write a file of JSON with RoundTable fields for Person.
library(jsonlite)
options(stringsAsFactors = FALSE)
# Resource Type Codes
#  1 (:Person)
#  2 (:Organization)
#  3 (:Tag)
#  4 (:Place)
#  5 (:Address)
#  6 (:Contact)
#  7 (:Document
#  8 (:WebPage)
#  9 (:Event)
# 10 (:WorkGroup)
# 11 (:Activity)
# Link Type Codes
# xxyyzz where xx is From Resource Type, yy is To Resource Type, zz is Link SubType

MakeID=function(N,prefix) {
# need string for random number 0 to 999999 but filled with zeros
# make 1M to (2M-1) as string, chop of the leading "1"
    id=substr(as.character(as.integer(1e6+runif(N,0,999999))),2,7);
# add the code for this link typeL person 01 to place 02 link type 01
    id=paste0(prefix,id) # e.g. "010201000001"
    return(id)
}


MakeLink=function(fileName,fromID, toID){
    # (from) -[has]- (to)
    if(file.exists(fileName)){
        cat("removing",fileName,"\n"); file.remove(fileName);}
    N=length(fromID);
    # make string with leading zeros for random number 0 to 999999
    id=substr(as.character(as.integer(1e6+runif(N,0,999999))),2,7);
    # add the code for this link typeL person 01 to place 02 link type 01
    linkType= paste0(substr(fromID[1],1,2),substr(toID[1],1,2),"01")
    id=paste0(linkType,id) # e.g. "010201123456"
    a=data.frame(id=id,
                 fromResourceNodeID= fromID,
                 fromResourceNodeTypeID="",
                 fromResourceNodeSubTypeID="",
                 toResourceNodeID=toID,
                 toResourceNodeTypeID="",
                 toResourceNodeSubTypeID="",
                 linkTypeID=linkType,
                 description="",
                 status="active",
                 startDate="",
                 endDate="",
                 stringsAsFactors = FALSE);
    write_json(a,fileName) # just unique nodes
    )
cat(fileName,", linkType ",linkType,", count=",N, ": success. \n",
    sep="")
return(id)
}
#Example:
fromID=MakeID(5, "01")
# "01201291" "01056181" "01384990" "01793058" "01664620"
toID= MakeID(5, "02")
#  "02868487" "02981813" "02693706" "02290896" "02591237"
MakeLink("PersonHasOrganization.txt", fromID, toID)

# 1 Person
PersonJSON=function(namestring,description){
    file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
    N=length(namestring)
    id=MakeID(N,"01")
    twoNames= unlist(strsplit(trimws(namestring,"both")," "));
    # assumes both names every row, unlist skips NA.
    j=seq(1, 2*N, 2); # 1, 3, 5 ... 2N-1
    firstnamesorinitials=twoNames[j]; # transpose
    familyname=twoNames[j+1] # 2,4,6, ...2N
    a=data.frame(id,label=namestring,namestring, firstnamesorinitials, familyname, description, status="", active="", startdate="",
enddate="");
    write_json(a,file)
    cat("PersonJSON: success. \n")
    return(id)
}
# Example
# namestring=c("Chuck Parken","Joel Harding")
# PersonID=PersonJSON(namestring,"")
# stuff=c('position=BI,    jobTitle=Aquatic Biologist',
#         'position=SE-RES,jobTitle=Research Scientist')
#PersonID=PersonJSON(namestring,description=stuff);
#a=read_json(file,simplifyVector=T)
#a # same data.frame

# before using package jsonlite
    # field= c("id", "label", "namestring", "firstnamesorinitials", "familyname", "description", "status", "active", "startdate","enddate")
    # txt = toJSON(a)
    # write(txt,file,append=TRUE);
    # for (k in 1:N){
    #     text='{'
    #     for(j in 1:length(field)){
    #         text=paste0(text,field[j],':"',a[k,j],'",')
    #     }
    #     text=paste(substring(text,1,nchar(text)-1),"}+")
    #     if(k==N)substring(text,1,nchar(text)-1) # last record
    #     write(text,file,append=TRUE)
    # }

# 2 Organization   reduce to unique
OrganizationJSON=function(namestring,description="") {
    # input: vector of non-unique org acronym and name
    # result: nodes for unique orgs, as file
    #         ID unique orgs
    #         hasOrganization as vector of IDs same length as input
    # expecting: "IOS, Institite of Ocean Sciences" with comma
    fileName="Organization.txt";
    if(file.exists(fileName)){cat("removing",fileName,"\n"); file.remove(fileName);}
    N=length(namestring);
    options(stringsAsFactors = FALSE) # so annoying
    twoNames= as.data.frame(strsplit(namestring,","));
    # magically fills in long name if only one name provided.
    names(twoNames) = NULL
    # unlist skips NA so cannot be used here
    short=trimws(twoNames[1,], "both");
    long= trimws(twoNames[2,], "both");
    # if only one name, no acronym, short is the node label (long name)
    ulong=unique(long); # find unique names, includes misspelt.
    p=match(ulong,long) # find first occurrence
    ushort=short[p]     # and use that for the acronym
    if(length(description >1)) description=description[p];
      # if descriptions provided, instead of default "", then
      # description is saved from ONLY FIRST occurence of each unique name.
    M=length(ulong) # count of unique names
    OrganizationID=MakeID(M,"02"); # "02" is Org
    a=data.frame(id=OrganizationID,label=ushort,name=ulong,
        acronym=ushort,type=description,status="active",stringsAsFactors = FALSE);
    write_json(a,fileName) # just unique nodes
    hasOrganizationID=character(N); # for each row of input data (typically person)
    # save the OrganizationID for Edge: Person -[hasOrg]- Org, for each person
    for(m in 1:M) hasOrganizationID[long==ulong[m]] =OrganizationID[m];
        # finds positions of all instances of each unique name of Organization
    cat("OrganizationJSON, count=",M,": success. \n", sep="")
    return(list(OrganizationID, hasOrganizationID))
}
# Example
    namestring=c("IOS, Institute of Ocean Sciences",
                 "PBS, Pacific Biological Station",
                 "Cultus Lake",  # no acronym
                 "IOS, Institute of Ocean Sciences",
                 "PBS, Pacific Biological Station")
    OrganizationJSON(namestring) # returns a list of two lists
# [[1]] [1] "2322835" "2670000" "2655291"
# [[2]] [1] "2322835" "2670000" "2655291" "2322835" "2670000"

# "id": 3901
# "label": "Institute of Ocean Sciences",
# "name": "Institute of Ocean Sciences",
# "acronym": "IOS",
# "organizationtype": "federal",
# "status": "active"  }


# 1.2 Person hasOrganization
PersonhasOrganizationJSON = function(fromID, hasOrganizationID){
    fileName="PersonHasOrganization.txt";
    if(file.exists(fileName)){
        cat("removing",fileName,"\n"); file.remove(fileName);}
    N=length(fromID);
    options(stringsAsFactors = FALSE) # so annoying
    # need string for random number 0 to 999999 but filled with zeros
    id=substr(as.character(as.integer(1e6+runif(N,0,999999))),2,7);
    # add the code for this link typeL person 01 to place 02 link type 01
    id=paste0("010201",id) # e.g. "010201123456"
    a=data.frame(id=id,
                 fromResourceNodeID= PersonID,
                 fromResourceNodeTypeID="",
                 fromResourceNodeSubTypeID="",
                 toResourceNodeID=hasOrganizationID,
                 toResourceNodeTypeID="",
                 toResourceNodeSubTypeID="",
                 linkTypeID="010201" )
    write_json(a,fileName) # just unique nodes
    cat("Person hasOrganization: success. \n")
    return(id)
}
# Example
PersonID=MakeID(5, "01")
    # "01201291" "01056181" "01384990" "01793058" "01664620"
hasOrganizationID= MakeID(5, "02")
    #  "02868487" "02981813" "02693706" "02290896" "02591237"
PersonhasOrganizationJSON(PersonID, hasOrganizationID)
    #"010201617760" "010201743315" "010201106029" "010201932185" "010201373348"


#3 Tag  -  expand. result is Tag nodes in JSON and 3 lists:
#          (1) TagID, (2) From PersonID (expanded), (3) to TagID
TagJSON=function(PersonID,namestring){
# rows match PersonID.  Tags comma separated. No repeated tags within Person.
# Find unique tags, make TagID and Tag nodes. Match tags within Person to TagID.
# Repeat Person to match each Person to multiple Tag for each Person.
# return TagID, From_PersonID, To_TagID.
    fileName="Tag.txt";
    if(file.exists(fileName)){
        cat("removing",fileName,"\n"); file.remove(fileName)}
    N=length(PersonID) # number of input rows
    tag=strsplit(namestring,",") # list by Person of lists of Tag
    # find unique names, make id and nodes
    utag=unique(unlist(tag)) # helpful: first hand-edit tags to reduce synonyms
    M=length(utag)
    TagID=MakeID(M,"03") # 3 for Tag
    a=data.frame(id=TagID,label=utag,name=utag,type="",description="",
        stringsAsFactors = FALSE);
    write_json(a,fileName) # unique
    ToTagID=tag; # placeholder with same construction as input tags
    FromPersonID= tag;
    for(j in 1:N){                        # for each person
        p= TagID[ utag %in% tags[[j]] ]   # Index unique tags in all tags. Improve?
        toTagID[[j]]=TagID[p]             # swap tag string for unique TagID
        FromPersonID[[j]]=rep(PersonID[j],sum(p)) # repeat Person for each of their Tags
    }

    # build link for Edge: Person -[hasOrg]- Org, for each person
    for(m in 1:M) hasOrganizationID[long==ulong[m]] =OrganizationID[m];
    # finds all instances of each unique name
    cat("OrganizationJSON: success. \n")
    return(list(TagID, fromPersonID, toTagID))
}
# Example: notice repeated ideas
namestring=c(
"Stock assessment, climate change, fisheries management,marine survival",
"Acoustic telemetry, pop-up satellite archival tags, salmon tagging, salmon migration",
"Groundwater salmon interaction",
"Database architecture, business process modelling",
"Salmon tagging, salmon migration,oceanographic monitoring, marine survival");


    WebPagesJSON=function(namestring,description){
        file="Person.txt";
        if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

        webpages": [{"id": 21101,"label": "PBS Home Page", "name": "Pacific Biological Station Home Page",  "description": "main webpage for the Pacific Biological Station", "URL":"http://www.pac.dfo-mpo.gc.ca/science/facilities-installations/pbs-sbp/index-eng.html", "status": "active","webpagetype": "main", "createdDate": "2017 January 19", "modifiedDate": "2017 January 19"}

WorkGroupJSON=function(namestring,description){
 file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

"workgroups": [{"id": 21001,"label": "DFO Salmon Network", "name": "DFO Salmon Network",  "description": "salmon staff in DFO","workgrouptype": "network", "status": "active", "startdate": "2017 January 19", "enddate": "2020 January 19"}


PlaceJSON=function(namestring,description){
 file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

"places": [{"id": 27000,"label": "Canada", "name":"Canada", "abbreviation":"","alpha2code":"CA", "alpha3code":"CAN",	"description": "", "placetype": "country", "altPlaceType":"", "status":"active", "geoJSONStringType": "Polygon", "geoJSONString":"", "source":"", "sourceurl":"" }



EventJSON=function(namestring,description){
 file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

"events": [{"id": 25001, "label": "DFO IYS Workshop Richmond January 2017", "name": "DFO IYS Workshop Richmond January 2017", "description": "DFO salmon scientists network","eventtype": "workshop","status": "active","startdate": "2017 January 24", "enddate": "2017 January 26", "address":"Richmond"},'+

DocumentJSON=function(namestring,description){
 file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

"documents": [{ "id": 22001, 	"label":"A Departmental Salmon Network", "name": "A Departmental Salmon Network with Reference to the International Year of the Salmon", "description": "Draft Terms of Reference","format": ".docx","citation_string": "2017 January 19", "createdDate":"E JAN 01 2017", "modifiedDate":"E FEB 28 2017"},'+

AddressJSON=function(namestring,description){
 file="Address.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

"addresses": [{  "id": 29001, "label": "NAFC",
"name":"Northwest Atlantic Fisheries Centre ",
"addressString":"80 East White Hills Road  St. John\'s, NL Canada A1A 5J7",
"addressTypeID": 41000, "status": "active",
"street": "80 East White Hills Road ",
"locality": 27014, "region": 27001,
"country": 27000,  "postalCode": "A1A 5J7" ,
"geoJSONStringType":"point",
"geoJSONString":"[longitude, latitude, elevation]"}


IsRelatedToJSON=function(){
 file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
        N=length(namestring)
        id=as.integer(6e8+0.999e8*runif(N,0,1));

}
{"isRelatedToEdges": [{
"id": 76001,
"fromResourceNodeID":"6067182960",
"fromResourceNodeTypeID":'+resourceNodeTypeID_person+',
"fromResourceNodeSubTypeID":"",
"toResourceNodeID":"6064932323",
"toResourceNodeTypeID":'+resourceNodeTypeID_person+',
"toResourceNodeSubTypeID":"",
"linkTypeID":'+resourceLinkTypeID_isRelatedTo+',
"linkSubTypeID":'+resourceLinkSubTypeID_worksWith+',
"label":"worksWith",
"name":"works with",
"description": "on Fraser Chinook-Coho stock assessment",
"status": "active",  "isPrimary":"yes",  "startDate":"", "endDate":""}

HasOrganizationJSON= function(){
 file="Person.txt";
    if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
    N=length(namestring)
    id=as.integer(6e8+0.999e8*runif(N,0,1));

}
'{"hasOrganizationEdges": { "id": 77001,
"fromResourceNodeID":"6066750860",
"fromResourceNodeTypeID":'+resourceNodeTypeID_person+',
"fromResourceNodeSubTypeID":"",
"toResourceNodeID":"3902",
"toResourceNodeTypeID":'+resourceNodeTypeID_organization+',
"toResourceNodeSubTypeID":"",
"linkTypeID":'+resourceLinkTypeID_hasOrganization+',
"linkSubTypeID":"",
"label":"0jkglkjg",
"description": "0iuefkjgi",
"status": "active",  "start_date":"", "end_date":"",
"isPrimaryOrganization":"true",
"roleLabel":"0hkjdfsh",
"roleDescription":"0hkutiutiutsh",
"roleType":"",  "roleTitle":"",
"roleStatus": "active", "role_start_date":"",  "role_end_date":"",  "isPrimaryRole":""}

hasWorkgroupJSON= function(){ file="Person.txt";
if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
N=length(namestring)
id=as.integer(6e8+0.999e8*runif(N,0,1));
}
"hasWorkgroupEdges": [{
"id": 78001,
"fromResourceNodeID":6066750860,
"fromResourceNodeTypeID":'+resourceNodeTypeID_person+',
"fromResourceNodeSubTypeID":"",
"toResourceNodeID":21001,
"toResourceNodeTypeID":'+resourceNodeTypeID_workgroup+',
"toResourceNodeSubTypeID":"",
"linkTypeID":'+resourceLinkTypeID_hasWorkgroup+',
"linkSubTypeID":"", "label":"", "description": "",
"status": "active",  "start_date":"", "end_date":"",
"isPrimaryWorkgroup":"", "roleLabel":"",  "roleDescription":"",  "roleType":"",  "roleTitle":"",
"role_start_date":"",  "role_end_date":"", "isPrimaryRole":""}


hasActivityJSON= function(){ file="Person.txt";
if(file.exists(file)){cat("removing",file,"\n"); file.remove(file)}
N=length(namestring)
id=as.integer(6e8+0.999e8*runif(N,0,1));
"hasActivityEdges": [{ "id": 76001,  "fromResourceNodeID":6066750860, "fromResourceNodeTypeID":'+resourceNodeTypeID_person+', "fromResourceNodeSubTypeID":"", "toResourceNodeID":"24011", "toResourceNodeTypeID":'+resourceNodeTypeID_activity+', "toResourceNodeSubTypeID":"", "linkTypeID":'+resourceLinkTypeID_hasActivity+', 	"linkSubTypeID":"", "label":"lhkjdkj", "description": "giuagiek",  "status": "active",  "start_date":"", "end_date":"", "isPrimaryActivity":"", "roleLabel":"",  "roleDescription":"",  "roleType":"",  "roleTitle":"", "role_start_date":"",  "role_end_date":"",  "isPrimaryRole":""},'+


{"selectedIdeaNodeEdges": ['+

                          '{ "id": 76001,  "fromResourceNodeID":6066104472, "fromResourceNodeTypeID":'+resourceNodeTypeID_person+', "fromResourceNodeSubTypeID":"", "toIdeaNodeID":"66501", "toIdeaNodeTypeID":'+ideaNodeTypeID_tag+', "toIdeaNodeSubTypeID":"", "linkTypeID":'+crossLinkTypeID_selected+', 	"linkSubTypeID":"", "label":"lhkjdkj", "description": "giuagiek",  "status": "active",  "start_date":"", "end_date":"" },'+

'{"hasAddressEdges": [{ "id": 66001,  "fromResourceNodeID":"3916", "fromResourceNodeTypeID":"'+resourceNodeTypeID_organization+'", "fromResourceNodeSubTypeID":"", "toResourceNodeID":"29001", "toResourceNodeTypeID":"'+resourceNodeTypeID_address+'", "toResourceNodeSubTypeID":"41000", "linkTypeID":"'+resourceLinkTypeID_hasAddress+'", 	"linkSubTypeID":"41000", "label":"hasAddress", "name":"has Address", "description": "",  "status": "active",  "startDate":"", "endDate":"", "isPrimaryAddress":"true"},'+


    /*var isRelatedToEdges_text = '{"isRelatedToEdges": ['+
    '{ "id": 79001,  "fromResourceNodeID":"6067182960", "fromResourceNodeTypeID":"11210", "fromResourceNodeSubTypeID":"", "toResourceNodeID":"28002", "toResourceNodeTypeID":"11210", "toResourceNodeSubTypeID":"", "linkTypeID":"21220", 	"linkSubTypeID":"", "label":"", "contactString":"Chuck.Parken@dfo-mpo.gc.ca", "description": "",  "status": "active", "isPrimary":"yes", "startDate":"", "endDate":""},'+
