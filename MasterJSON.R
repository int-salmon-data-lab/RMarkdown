MasterJSON.R
# applies a suite of functions to create RoundTable nodes as JSON.
# Must keep track of the IDs for each Resource type,
# so they can be linked correctly. Do this by Person.
#

# Codes for Nodes
# 1 (:Person) one million PersonID, from 1,000,000 to 1,999,999
# 2 (:Organization)
# 3 (:Tag)
# 4 (:Place)
# 5 (:Address)
# 6 (:Contact)
# 7 (:Document
# 8 (:WebPage)
# 9 (:Event)
#10 (:WorkGroup) WorkGroupID  10,000,000 to 10,999,999
#11 (:Activity)  ActivityID  11,000,000 to 10,999,999
#40  (undefined)  40,000,000 to 40,999,999
# Codes for Edges
# xxyyzz where xx is From Resource Type, yy is To Resource Type, zz is Link SubType
# 010101 is O1 Person   to 01 Person   by PersonToPerson     type 01
# 111111 is 11 Activity to 11 Activity by ActivityToActivity type 11
# 404099 is Resource type 40 to Resource type 40, link subtype 99
# allows 1 M of each type of Edge: 404099,000000 to 404099,999999; 12 characters
# plus able to spill over to 100 M for Edge Type by ignoring Edge subtypes.
# Thought not restrictive.

# Example
surveyFile= "/Users/Scott/Documents/Projects/DFO Salmon Net/Data/SurveyMonkey2017January23 trimmed.csv"; file.exists(surveyFile)
srvy= as.data.frame(read.csv(
    surveyFile,header=TRUE, colClasses="character"));
names(srvy)
# [1] "EmailAddress"         "FirstName"
# [3] "LastName"             "PositionAndTitle"
# [5] "Organization2"        "Place"
# [7] "Organization1"        "Telephone"
# [9] "Work"                 "Colleagues"
# [11] "LikeToReceiveSupport"

# 1
PersonID=PersonJSON( namestring=paste(srvy$FirstName,srvy$FirstName),
    description=srvy$PositionAndTitle );
# 2
OrganizationID=OrganizationJSON(srvy$OfficeLocation)
# 3
TagID=TagJSON(paste(srvy$Work,srvy$LikeToReceiveSupport,sep=",") )




