require(pacman)

p_load(readr,dplyr,RCurl,rjson,lubridate,
       rvest,stringr,Hmisc,rattle,RColorBrewer,ddpcr,tidytext,tidyr,wordcloud,
       ggrepel,ggplot2)

##########################################################
### build chatterplot based on most distinctive words ####
##########################################################

TD_word_counts <- read.csv("~/talking_trump/results/TD_word_counts.csv") %>% dplyr::select(-1)
nonTD_word_counts <- read.csv("~/talking_trump/results/nonTD_word_counts.csv") %>% dplyr::select(-1)

word_compare <- full_join(TD_word_counts,nonTD_word_counts,by="word")

word_compare <- word_compare %>%  replace_na(replace=list(nusers.x=0,nusers.y=0,n.x=0,n.y=0))

## create a usage score for each word: (word frequency)*(user frequency). add 1 to the numerators
## to ensure it's possible to take a ratio. (some words may never appear in one sample or the other).

word_compare <- word_compare %>% mutate(usage_TD = ((n.x+1)/nTD)*((nusers.x+1)/total_users_TD))
word_compare <- word_compare %>% mutate(usage_nonTD = ((n.y+1)/nnonTD)*((nusers.y+1)/total_users_nonTD))

## very high ratios indicate that usage is much higher among the TD sample
word_compare <- word_compare %>% mutate(ratio = usage_TD/usage_nonTD)

# sort by ratio, largest ratios at the top
word_compare <- word_compare[order(-word_compare$ratio),]

# pick the top 50 words for a chatterplot
for_chatter <- word_compare[1:50,]


## make the chatterplot
# see https://towardsdatascience.com/rip-wordclouds-long-live-chatterplots-e76a76896098 for source

for_chatter %>% 
  # construct ggplot
  ggplot(aes(usage_TD, ratio,  label = word)) +
  
  ### play with force parameter if words overlap too much
  geom_text_repel(segment.alpha = 0, 
                  force=1, 
                  aes(colour=usage_TD, size=ratio)) + 
  
  # viridis palettes are colorblind friendly
  scale_colour_viridis_c(alpha = 1, begin = 0, end = .8,
                         direction = 1, option = "B", aesthetics = "colour") +
  
  scale_size_continuous(range = c(4, 10),
                        guide = FALSE) +
  
  #if you have outliers, uncomment these lines to use log scale
  scale_x_log10() +
  scale_y_log10() +
  
  ggtitle("Chatterplot of TD's most distinctive words",
          subtitle = "this is a subtitle"
  ) + 
  labs(y = "Usage by r/T_D users", x = "Ratio of usage") +
  
  
  # minimal theme & customizations
  theme_minimal() +
  theme(legend.position=c(.99, .99),
        legend.justification = c("right","top"),
        panel.grid.major = element_line(colour = "whitesmoke"))
