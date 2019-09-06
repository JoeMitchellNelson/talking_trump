require(pacman)

p_load(randomForest,rpart,readr,RedditExtractoR,dplyr,RCurl,rjson,lubridate,
       rvest,stringr,Hmisc,rattle,RColorBrewer,ddpcr,tidytext,tidyr,wordcloud,
       ggrepel,ggplot2)

### need to run get_comment_history.R to generate the csv files this code will call

### these two loops will pull out individual words, keeping track of which user said them
### if you want 2-word phrases (bigrams) instead of individual words, use:
### unnest_tokens(temp,bigram,comments,token="ngrams",n=2,collapse=F)
### see https://www.tidytextmining.com/ngrams.html 

##########################################################
############## start counting words ######################
##########################################################

TD_text <- NULL
j <- 0
for (i in 1:length(TD)) {
  USER <- TD[i] %>% as.character()
  filename <- paste0("~/talking_trump/user_tables/TD/",USER,".csv")
  if (file.exists(filename)) {
    TABLE <- read.csv(filename)
    TABLE$username <- USER
    TABLE$comments <- as.character(TABLE$comments)
    TABLE <- TABLE %>% filter(comments!="NULL")
    temp <- TABLE %>% dplyr::select(comments,username)
    temp <- unnest_tokens(temp,word,comments)
    TD_text <- rbind(TD_text,temp)
  }
  j <- j+1
  print(j)
}

nonTD_text <- NULL
j <- 0
for (i in 1:length(nonTD)) {
  USER <- nonTD[i] %>% as.character()
  filename <- paste0("~/talking_trump/user_tables/nonTD/",USER,".csv")
  if (file.exists(filename)) {
    TABLE <- read.csv(filename)
    TABLE$username <- USER
    TABLE$comments <- as.character(TABLE$comments)
    TABLE <- TABLE %>% filter(comments!="NULL")
    temp <- TABLE %>% dplyr::select(comments,username)
    temp <- unnest_tokens(temp,word,comments)
    nonTD_text <- rbind(nonTD_text,temp)
  }
  j <- j+1
  print(j)
}


# want to know how widespread the usage of words is among each sample
# so we need to know how many times a word was used AND how many users used it

total_users_TD <- TD_text$username %>% unique() %>% length() # this should equal length(TD), but there may have been some failures

count_users <- TD_text %>% group_by(word) %>% unique %>%  mutate(nusers = n()) %>% 
  dplyr::select(word,nusers) %>% unique() # count how many users use each word

nTD <- nrow(TD_text) # total number of (non unique) words used by subsample

# filter out some common words (stop words), pieces of links, and unicode characters
# again, see https://www.tidytextmining.com/tidytext.html

words_filtered <- TD_text %>%
  filter((!word %in% stop_words$word))  %>%
  filter(!word %in% c("upload.wikimedia.org","null", "amp", "u","https","http", "gt","v","www.youtube.com","r")) %>% 
  filter(!str_detect(word,"[0-9]")) %>% 
  filter(!is.na(word))

### count total uses of each word

TD_word_counts <- words_filtered %>% 
  count(word, sort = TRUE)

TD_word_counts <- left_join(TD_word_counts,count_users,by="word") # add user counts and total counts into same dataframe

## create a usage score for each word: (word frequency)*(user frequency)

write.csv(TD_word_counts,"~/talking_trump/results/TD_word_counts.csv")

#################################
#### repeat for other sample ####
#################################

total_users_nonTD <- nonTD_text$username %>% unique() %>% length() # this should equal length(nonTD), but there may have been some failures

count_users <- nonTD_text %>% group_by(word) %>% unique %>%  mutate(nusers = n()) %>% 
  dplyr::select(word,nusers) %>% unique() # count how many users use each word

nnonTD <- nrow(nonTD_text) # total number of (non unique) words used by subsample

# filter out some common words (stop words), pieces of links, and unicode characters
# again, see https://www.tidytextmining.com/tidytext.html

words_filtered <- nonTD_text %>%
  filter((!word %in% stop_words$word))  %>%
  filter(!word %in% c("upload.wikimedia.org","null", "amp", "u","https","http", "gt","v","www.youtube.com","r")) %>% 
  filter(!str_detect(word,"[0-9]")) %>% 
  filter(!is.na(word))

### count total uses of each word

nonTD_word_counts <- words_filtered %>% 
  count(word, sort = TRUE)

nonTD_word_counts <- left_join(nonTD_word_counts,count_users,by="word") # add user counts and total counts into same dataframe

write.csv(nonTD_word_counts,"~/talking_trump/results/nonTD_word_counts.csv")

