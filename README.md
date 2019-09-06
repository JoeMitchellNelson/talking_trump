# talking_trump

This repo contains everything you need to scrape reddit comments and find the most distinctive set of words
that one community uses relative to another. 

However, you will have to collect your own sets of usernames from the community of interest and reddit more broadly.

By convention, I call the community of interest TD and the rest of reddit nonTD, since I use this to analyze r/the_donald. But this code can be adapted for any subreddit, or group of subreddits, depending on how you choose your samples.

## Using this repo

Start by running the functions in code/scraping_functions.R.
Then use get_comment_history.R to scrape comment history from the users you specify. This file calls the functions defined in scraping_functions. Note that get_comment_history.R will save a .csv file for each user (files tend to be around 50-100 kB). You may want to start small.

analyze_comments.R takes the set of files you created for each user and turns them into two dataframes (one for each subsample). The dataframes contain every word ever used by any user, the number of instances of each word, and the number of unique users who used each word.

make_chatterplot.R combines these two dataframes, calculates a usage ratio for each word, and produces a chatterplot of the most
distinctive words found in one community.

Usage score is calculated as (word uses + 1)/(total uses of any word) * (unique users of the word + 1)/(total users in subsample). This measure weights usage more heavily if a word is used by many users, rather than by a few users many times. Then ratio of usage scores is taken to find the most distinctive words in one subsample (TD) relative to the other (nonTD).

#### Sources and code I adapted

Scraping reddit: dmarx's github, https://gist.github.com/dmarx/8140428

Text analysis: Text mining with R by Julia Silge and David Robinson, https://www.tidytextmining.com/tidytext.html

Chatterplots: Daniel McNichols' Toward Data Science blog, https://towardsdatascience.com/rip-wordclouds-long-live-chatterplots-e76a76896098
