####################################
#                                  # 
# 247 Team Recruit Rankings Scrape #
#                                  #
####################################

library(rvest) # For web scraping
library(stringr) # For string processing

base_url <- "http://247sports.com/Season/%-Basketball/CompositeRecruitRankings?InstitutionGroup=HighSchool"

year_list <- seq(from = 2008, to = 2017, by = 1)
conf_list <- c("Big-East")

# initialize the matrix to append teams to
recruit_matrix <- matrix("", nrow = 1, ncol = 6) 
for(year in year_list){
  year_url <- sprintf(base_url, year)
  year_url <- str_c(year_url, "?Conference=%s")
  for(conf in conf_list){
    conf_url <- sprintf(year_url, conf)
    conf_values <- read_html(conf_url) %>% 
      html_nodes(".team_itm span , .playerinfo_blk a") %>% # from the Inspector Gadget tool
      html_text %>%
      str_trim %>%
      matrix(ncol = 4, byrow = T) %>%
      cbind(conf, year)
    recruit_matrix <- rbind(recruit_matrix, conf_values)
    Sys.sleep(1) # wait a second to not throttle the servers at 247
  }
}

# remove the first empty row
recruit_matrix <- recruit_matrix[-1, ]
recruit_df <- data.frame(Team = recruit_matrix[, 1],
                         Recruits = as.numeric(str_extract_all(recruit_matrix[, 2], "[0-9]+", simplify = T)[, 1]),
                         Class_Points = as.numeric(recruit_matrix[, 4]),
                         Conference = recruit_matrix[, 5],
                         Year = recruit_matrix[, 6], 
                         stringsAsFactors = F)

write.csv(recruit_df, "247_recruit_rankings_04_20_17.csv", row.names = F)



