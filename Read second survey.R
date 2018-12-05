# Read second survey.R
# required extensive hand edits to headers of .csv
# added blank line to end of csv to avoid error

f = "/Users/Scott/Documents/Projects/IYS/second survey 2017 July/Result/DFO Salmon Network condensed fixed.csv"
file.exists(f)
a=read.csv(f)
a1=as.data.frame(a)
dimnames(a1)[2]
[[1]]
  [1] "Respondent.ID"        "Collector.ID"         "Start.Date"           "End.Date"             "IP.Address"           "Email.Address"        "First.Name.Sent"     
  [8] "Last.Name.Sent"       "Custom.Data"          "First.Name"           "Last.Name"            "Prefix"               "Suffix"               "Web.Page"            
 [15] "Position.Title"       "Other.Position"       "Position.Description" "DFO.Region"           "DFO.Branch"           "Your.location"        "Your.location.other" 
 [22] "IYS.1.1"              "IYS.1.2"              "IYS.1.3"              "IYS.1.4"              "IYS.1.5"              "IYS.1.6"              "IYS.1.7"             
 [29] "IYS.1.8"              "IYS.1.Other"          "IYS.2.1"              "IYS.2.2"              "IYS.2.3"              "IYS.2.4"              "IYS.2.5"             
 [36] "IYS.2.6"              "IYS.2.7"              "IYS.2.8"              "IYS.2.other"          "IYS.3.1"              "IYS.3.1.1"            "IYS.3.2"             
 [43] "IYS.3.3"              "IYS.3.4"              "IYS.3.5"              "IYS.3.6"              "IYS.3.7"              "IYS.3.other"          "IYS.4.1"             
 [50] "IYS.4.2"              "IYS.4.3"              "IYS.4.4"              "IYS.4.5"              "IYS.4.6"              "IYS.4.7"              "IYS.4.other"         
 [57] "IYS.5.1"              "IYS.5.2"              "IYS.5.3"              "IYS.5.4"              "IYS.5.other"          "IYS.6.1"              "IYS.6.2"             
 [64] "IYS.6.3"              "IYS.6.4"              "IYS.6.5"              "IYS.6.6"              "IYS.6.7"              "IYS.6.8"              "IYS.6.9"             
 [71] "IYS.6.10"             "IYS.6.other"          "Activity.1.1"         "Activity.1.2"         "Activity.1.3"         "Activity.1.4"         "Activity.1.5"        
 [78] "Activity.1.6"         "Activity.1.7"         "Activity.1.8"         "Activity.1.9"         "Activity.1.10"        "Activity.2.1"         "Activity.2.2"        
 [85] "Activity.2.3"         "Activity.2.4"         "Activity.2.5"         "Activity.2.6"         "Activity.2.7"         "Activity.2.8"         "Activity.2.9"        
 [92] "Activity.2.10"        "Activity.2.11"        "Activity.2.12"       "Activity.3.1"         "Activity.3.2"         "Activity.3.3"         "Activity.3.4"        
 [99] "Activity.3.5"         "Activity.3.6"         "Activity.3.7"         "Activity.3.8"         "Comment.Survey"       "Comment.Salmon.Net"  
# why are there 12 fields for activity 2 and 8 fields for activity 3 ?
