# text block of emails.R
# from rows in csv
# 1. import the spreadsheet
a= read.csv("/Users/Scott/Desktop/temp-email.csv");(len=dim(a)[1]) #128
# 2. extract email column as a vector
a1= a[,4]
#3. remove blanks.
a1=a1[a1 != ""]  # 42
# 4. convert from character vector to one string
a2= paste(a1,collapse=";")
print(a2)
#  "marc.tudel@dfo-mpo.gc.ca;gregor.reid@dfo-mpo.gc.ca;steven.leadbeater@dfo-mpo.gc.ca;cynthia.hawthorne@dfo-mpo.gc.ca; ... <truncated>
