List2Rows = function(id, charList){
    # id has characteristics as a comma separated list of  strings.
    # result is a dataframe with two columns:
    #   (1) id -- likely repeated
    #   (2) char -- one per row, expanded from charList
    if(missing(charList) & dim(id)[2]==2){ # input is matrix or dataframe
        charList=id[,2] # character vector
        id=id[,1]       # character vector
    }
    if (length(id) != length(charList)) stop("List2long: input lengths differ")
    if(any(id=="")) stop("List2long: gaps in variable 'id' ")
    expanded=strsplit(charList,",") # one list of lists.
    # how big is the result?
    nrow=length(unlist(expanded))+sum(charList=="") #unlist drops empty lists, fix
    cat("number of rows for characteristics", nrow,"\n")
    res=as.data.frame(matrix(nrow=nrow, ncol=2));
    colnames(res)=c("id", "char")
    irow=0
    for(j in 1:length(expanded)){ # for each row in charList, ie. each id
        # when there are no characteristics
        if (length(expanded[[j]]) == 0) {
            irow=irow+1
            res[irow,1]=id[j]
            res[irow,2]="";
            next;
        }
        # when there is at least one characteristic
        for(k in 1:length(expanded[[j]])){ # all chars for that one id
            irow=irow+1
            res[irow,1]=id[j]
            res[irow,2]=trimws(expanded[[j]][k], which="both")
        }
    }
    return(res)
}
# example
# pet=c("cat","bat","dog");    # bat has no characteristics
# eats=c("bird, frog, fish","", "bone, squirrel, rabbit, cat")
# List2long(pet,eats)
