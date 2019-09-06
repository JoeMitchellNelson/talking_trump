require(pacman)

p_load(randomForest,rpart,readr,RedditExtractoR,dplyr,RCurl,rjson,lubridate,
       rvest,stringr,Hmisc,rattle,RColorBrewer,tidytext,tidyverse)


# num_pages limits the number of comments to be scraped. currently set to a maximum of 4 pages (or 400 comments).
num_pages <- 4

#### Extract comment information and metadata from a user account ####
# see https://gist.github.com/dmarx/8140428 for source

get_User_subs_page = function(user, after=NULL, cache=c()){
  
  baseurl = "http://www.reddit.com/user/"
  params = "limit=100"
  if(!is.null(after)){    
    params = paste(params, "&after=",after, sep="")
  }  
  
  userCommentsUrl = paste(baseurl, user, "/.json?",params, sep="")  
  jsonResponse = readLines(userCommentsUrl)
  StructuredResponse = rjson::fromJSON(jsonResponse, unexpected.escape = "keep")  
  
  # Extract subreddits
  n <- length(StructuredResponse$data$children) # Count retrieved comment objects
  if (n>0) {
    substemp = rep(NA)
    comtemp = rep(NA)
    votestemp = rep(NA)
    controtemp = rep(NA)
    adulttemp = rep(NA)
    datetemp = rep(NA)
    done = F
    for(i in 1:n){
      obj = StructuredResponse$data$children[[i]]$data
      if(any(cache==obj$id)){
        print("done")
        done=T
        return(list(substemp, NULL, cache, done))
      }
      substemp[i] = obj$subreddit
      comtemp[i] <- list(obj$body)
      votestemp[i] <- obj$ups
      controtemp[i] <- list(obj$controversiality)
      adulttemp[i] <- obj$over_18
      datetemp[i] <- obj$created
      cache=c(cache, obj$id)
    }
    
    nextID = StructuredResponse$data$after # for paging
    output <- list(substemp, comtemp, votestemp, controtemp, adulttemp, datetemp, nextID, cache, done)
  } else {
    output <- NULL
  }
  return(output)
}

#### Turn data from each user into a tidy table--one comment per row ####


user_table <- function (USER) {
  subreddits = c()
  comments = c()
  votes= c()
  controversial = c()
  over_18 = c()
  date = c()
  afterID=NULL
  ids_cache = c()
  done <- F
  iter=0
  while(!done) {
    iter=iter+1
    print(iter)
    subs_page = get_User_subs_page(user=USER, after=afterID, cache=ids_cache)  
    if (length(subs_page)==9 & iter <= num_pages) { 
      subreddits = c(subreddits, subs_page[[1]])
      comments = c(comments, subs_page[[2]])
      votes = c(votes, subs_page[[3]])
      controversial = c(controversial,subs_page[[4]])
      over_18 = c(over_18,subs_page[[5]])
      date <- c(date,subs_page[[6]])
      afterID=subs_page[[length(subs_page)-2]]
      ids_cache=subs_page[[length(subs_page)-1]]
      done = subs_page[[length(subs_page)]]
      
      Sys.sleep(2) # sleep 2 seconds to respect reddit API so we don't get blocked
    } else {
      done <- T
    }
  }

  comments <- unlist(as.character(comments))
  controversial <- unlist(as.character(controversial))
  
  controversial <- controversial[controversial!="TRUE"]
  subreddit <- subreddits[!is.na(subreddits)]
  
  if (length(votes)==2*length(comments)) {  ### sometimes the "votes" vector was doubled, not sure why
    votes <- votes[1:length(comments)]
  }
  
  post_history <- cbind(comments,subreddit,votes,controversial,over_18,date)
  post_history <- as.data.frame(post_history)
  post_history$votes <- as.numeric(as.character(post_history$votes))
  post_history$controversial <- as.numeric(as.character(post_history$controversial))
  post_history$date <- as.numeric(as.character(post_history$date))
  post_history$date <- as_datetime(post_history$date,tz="UTC")
  post_history <- post_history %>% mutate(over_18=ifelse(over_18=="TRUE",1,0))
  
  return(post_history)
}

#### next go to get_comment_history.R ####
  