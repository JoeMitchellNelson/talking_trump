# run scraping_functions.R first

# you'll have to draw your own samples.

# I call the first subsample "TD". put your usernames for this subsample into a character vector.
TD <- c("spez","another_name")

# and the second subsample is "nonTD". put your usernames for this subsample into a character vector.
nonTD <- c("joe_m_n","username2")

# loop through the usernames in each vector, 
# and save a table of comments and metadata to .csv files in separate folders
# this loop will not run unless you run the functions in scraping_functions.R first
# these loops take some time to run since reddit's api requires 2 seconds between requests

for (i in 1:length(TD)) {
  temp <- user_table(TD[i]) 
  filename <- paste0("~/talking_trump/user_tables/TD/",TD[i],".csv")
  write.csv(temp,filename)
}

for (i in 1:length(nonTD)) {
  temp <- user_table(nonTD[i]) 
  filename <- paste0("~/talking_trump/user_tables/nonTD/",nonTD[i],".csv")
  write.csv(temp,filename)
}

# each row in a csv file gives (in order): comment text, name of subreddit, vote score, 
# flag for whether the comment is considered "controversial", 
# flag for whether the OP is NSFW, and the datetime of the comment

# next go to analyze_comments.R