# Wed Dec 17 13:09:51 2025 ------------------------------
# 
require(tidyverse)
require(readtext)
`%ni%` = Negate(`%in%`)

#file.path(file.choose())
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/jstor_sociology_meta.RData")


names(mydata)
head(mydata)
mydata %>% count(content_type, content_subtype)

# >>>>> Only keep substantive entries of "article" type
toremove <- c("backmatter", "correction", "frontmatter", "index", 
              "misc", "other", "retraction") # string for filtering
research <- mydata %>% # filter
  filter(content_type == "article") %>% 
  filter(content_subtype  %ni% toremove)
research %>% count(content_type, content_subtype) # check

# >>>>> Save journal list for external review and selection
research_journals <- research %>% count(is_part_of)
write.csv(research_journals, file = "/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/research_journals.csv")
count(research, languages)
research_journals2 <- read.csv(file = "/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/research_journals_edited.csv")
journ_tokeep <- research_journals2 %>% 
  filter(keep == 1)
jtk <- journ_tokeep$is_part_of # this list of 79 journals to keep

# >>>>> Use jtk to filter research
research2 <- research %>% 
  filter(is_part_of %in% jtk)
research2 %>% count(is_part_of) %>% View() # check

# add new line character to each
research2$newline <- "\n"
bernau_request_ids <- paste0(research2$item_id, research2$newline)
bernau_request_ids[1500:1550]

# write to txt file
cat(bernau_request_ids, file = "~/Desktop/bernau_request_ids.txt")


# they didn't like my text file. Remove default spaces b/t elements
cat(bernau_request_ids, 
    sep = "",
    file = "~/Desktop/bernau_request_ids2.txt")
