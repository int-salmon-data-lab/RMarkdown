# Correspond.R
# from two columns each with repeats, make a list of corresponding uniques
# col 1 is "id" col 2 is "has" as in "this id has these corresponding traits"
Correspond = function(a){
    a1=unique(sort(a[,1]))           # vector of type character
    #cat("a1=",a1,"\n")
    rslt= vector("list", length(a1)) # result
    for (j in 1:length(a1)) {        # each unique
        k = a[,1] %in% a1[j]         # indices of repeated unique in original
        a2 = a[k,2]                  # all corresponding
        #cat("j=",j,"a1[j]=",a1[j],"a2=",a2,"\n")
        rslt[[j]] = list( id=a1[j], has=sort(unique(a2)) )
    }
    return (rslt)
}
#example
    habit = cbind(spec= c("cat", "dog",  "fox","frog","cat", "bat"),
                   hab= c("tree","grass","den","",    "tree","tree") );
    a3=Correspond(habit);a3
