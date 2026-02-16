# Wed Jan 21 09:33:03 2026 ------------------------------
# creating small subset of journals to include

require(tidyverse)
`%ni%` = Negate(`%in%`)

# From previous work 20251217 journal selection:
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/jstor_sociology_meta.RData")
# >>>>> Only keep substantive entries of "article" type
toremove <- c("backmatter", "correction", "frontmatter", "index", 
              "misc", "other", "retraction") # string for filtering
research <- mydata %>% # filter
  filter(content_type == "article") %>% 
  filter(content_subtype  %ni% toremove)
research_journals2 <- read.csv(file = "/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/research_journals_edited.csv")
journ_tokeep <- research_journals2 %>% 
  filter(keep == 1)
jtk <- journ_tokeep$is_part_of # this list of 79 journals to keep


# then make smaller subet
jtak <- c("Contemporary Sociology",
          "American Journal of Sociology",
          "American Sociological Review",
          "Journal for the Scientific Study of Religion",
          "The British Journal of Sociology",
          "The Canadian Journal of Sociology / Cahiers canadiens de sociologie",
          "Social Research",
          "Journal of Health and Social Behavior",
          "Journal of Marriage and Family",
          "Social Psychology Quarterly",
          "Sociometry",
          "Social Psychology",
          "Signs",
          "Journal of the History of Sexuality",
          "International Social Science Review",
          "Social Science",
          "International Review of Modern Sociology",
          "International Review of Sociology",
          "European Journal of Sociology / Archives Européennes de Sociologie / Europäisches Archiv für Soziologie",
          "Sociology of Education",
          "The Journal of Educational Sociology",
          "Social Science History",
          "Teaching Sociology",
          "The American Sociologist",
          "Theory and Society",
          "Annual Review of Sociology",
          "Race, Gender & Class",
          "Race, Sex & Class")

# >>>>> Use jtak to filter research
newjournals_meta <- research %>% 
  filter(is_part_of %in% jtak)
# newjournals_meta %>% count(is_part_of) %>% View() # check
# newjournals_meta[1:100,] %>% View() # check
save(newjournals_meta, file = "~/Desktop/newjournals_meta.RData")
# file.path(file.choose())

# clear environment >>>>>>>>
rm(list = ls())

# loading new metadata
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/newjournals_meta.RData")

# load all metadata
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/jstor_sociology_full.RData")

# names(jstor_full)
# names(newjournals_meta)

# joining metadata and fulltext
newjournals_full <- jstor_full %>% 
  filter(iid %in% newjournals_meta$item_id)
newjournals_meta$iid <- newjournals_meta$item_id
newjournals_both <- inner_join(newjournals_meta, newjournals_full)

rm(newjournals_full, newjournals_meta)

# cleaning unnecessary vars
# names(newjournals_both)
# newjournals_both[1:100,] %>% View()
# count(newjournals_both, publishers)
# keep these 14 vars
new_complete <- newjournals_both %>% 
  select(item_id, ithaka_doi, title, is_part_of, creators_string, creators, 
         published_date, url, content_subtype, issue_volume, issue_number, 
         full_text, references, publishers)

# Recode year
new_complete$year <- as.numeric(substr(new_complete$published_date, 1, 4))

# recoding for journal history
new_complete$journal <- new_complete$is_part_of

# journal of educational sociology (est 1927) became soc of ed in 1963
new_complete$journal[new_complete$journal == "The Journal of Educational Sociology"] <- "Sociology of Education"

# sociometry (est 1937) > social psychology (1978) > SPQ (1979-Present)
new_complete$journal[new_complete$journal == "Sociometry"] <- "Social Psychology Quarterly"
new_complete$journal[new_complete$journal == "Social Psychology"] <- "Social Psychology Quarterly"

# tidy names
new_complete$journal[new_complete$journal == "European Journal of Sociology / Archives Européennes de Sociologie / Europäisches Archiv für Soziologie"] <- "European Journal of Sociology"
new_complete$journal[new_complete$journal == "The Canadian Journal of Sociology / Cahiers canadiens de sociologie"] <- "The Canadian Journal of Sociology"

# intl review of soc (1971) > intl review of mod soc (1972)
new_complete$journal[new_complete$journal == "International Review of Sociology"] <- "International Review of Modern Sociology"

# social science (1925-1981) > intl SS review (1985-2021)
new_complete$journal[new_complete$journal == "Social Science"] <- "International Social Science Review"

# race sex class > race gender class
new_complete$journal[new_complete$journal == "Race, Sex & Class"] <- "Race, Gender & Class"

# check recoding
# new_complete %>% count(is_part_of, journal) %>% View()
# unique(new_complete$is_part_of)


# save dataframe
save(new_complete, file = "~/Desktop/new_complete.RData")
# file.path(file.choose())
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/new_complete.RData")


# Descriptive table of 18 journals --------------------------------------------
# only the 18 chosen journals
chosenones <- new_complete %>% 
  filter(journal %in% c("American Journal of Sociology",
                        "American Sociological Review",
                        "Annual Review of Sociology",
                        "The American Sociologist",
                        "European Journal of Sociology",
                        "The British Journal of Sociology",
                        "The Canadian Journal of Sociology",
                        "International Social Science Review",
                        "Social Psychology Quarterly",
                        "Journal of Marriage and Family",
                        "Journal for the Scientific Study of Religion",
                        "Theory and Society",
                        "Race, Gender & Class",
                        "Signs",
                        "Journal of Health and Social Behavior",
                        "Sociology of Education",
                        "Teaching Sociology",
                        "Contemporary Sociology"))

min <- chosenones %>%  
  count(journal, year) %>% 
  group_by(journal) %>% 
  slice_min(year, n=1) %>% 
  mutate(year_min = year) %>% 
  select(-year, -n)

max <- chosenones %>%  
  count(journal, year) %>% 
  group_by(journal) %>% 
  slice_max(year, n=1) %>% 
  mutate(year_max = year) %>% 
  select(-year, -n)
cnt <- chosenones %>%  
  count(journal)
table2 <- full_join(min, max) %>% 
  full_join(cnt)
# ------------------------------------------------------------------------------

# one dataset will be CS book reviews (N = 24625)
cs_reviews <- chosenones %>% 
  filter(content_subtype == "book-review" & journal == "Contemporary Sociology")
# the other reviews (N = 45041)
other_reviews <- chosenones %>% 
  filter(content_subtype == "book-review" & journal != "Contemporary Sociology")
# only research articles (N = 41216)
articles_new <- chosenones %>% 
  filter(content_subtype == "research-article" & journal != "Contemporary Sociology")
count(articles_new, journal) %>% View()


# histograms
ggplot(articles_new, aes(x = year)) + 
  geom_histogram(aes(fill = journal), color = "white") +
  facet_wrap(~journal, ncol = 4) +
  scale_fill_discrete(guide = NULL)

ggplot(articles_new, aes(x = year)) + 
  geom_density(aes(fill = journal), alpha = 0.5, color = "white") +
  facet_wrap(~journal, ncol = 4) +
  scale_fill_discrete(guide = NULL)

ggplot(cs_reviews, aes(x = year)) + 
  geom_histogram(aes(fill = journal), color = "white") +
  facet_wrap(~journal, ncol = 4) +
  scale_fill_discrete(guide = NULL)

# three outlier journals to examine: JMF, TS, TAS
# tas70s <- articles_new %>% filter(is_part_of == "The American Sociologist") %>% 
#   filter(year >1966 & year < 1974)
# everything looks fine, some journals are more active in certain years

# test unlisting full text on sample
# test <- sample_n(articles_new, 5)
# length(test$full_text[1]) # 1 list
# unlist(test$full_text[1]) %>% length() # X items in list
# # must use collapse arg in paste function
# paste(unlist(test$full_text[1]), collapse = " ") %>% length()
# # save to new variable
# test$full_text2[1] <- paste(unlist(test$full_text[1]), collapse = " ")
# # function to do this for every row
# for (x in 1:nrow(test)){
#   test$full_text2[x] <- paste(unlist(test$full_text[x]), collapse = " ")
# }

# now for whole datasets
for (x in 1:nrow(articles_new)){
  articles_new$full_text2[x] <- paste(unlist(articles_new$full_text[x]), collapse = " ")
}

for (x in 1:nrow(cs_reviews)){
  cs_reviews$full_text2[x] <- paste(unlist(cs_reviews$full_text[x]), collapse = " ")
}

for (x in 1:nrow(other_reviews)){
  other_reviews$full_text2[x] <- paste(unlist(other_reviews$full_text[x]), collapse = " ")
}

# double-checking
count(articles_new, is.na(full_text2))
count(articles_new, full_text2 == "") # 4 blank

count(cs_reviews, is.na(full_text2))
count(cs_reviews, full_text2 == "") # 0 blank

count(other_reviews, is.na(full_text2))
count(other_reviews, full_text2 == "") # 17 blank

# Sat Jan 24 14:28:59 2026 ------------------------------

class(articles_new$full_text2)


# basic cleaning
# test <- sample_n(articles_new, 10)
# test$cleantext <- tolower(test$full_text2) # Lowercase
# test$cleantext <- gsub("- ", "", test$cleantext) # Remove word line splits
# test$cleantext <- gsub("[[:punct:]]", "", test$cleantext) # Remove punctuation
# test$cleantext <- gsub("[[:digit:]]", "", test$cleantext) # Remove numbers
# test$cleantext <- gsub("\\s+", " ", str_trim(test$cleantext)) # Remove extra whitespaces

# articles are OCR'd so header may include journal title and short article title
# keep this in mind if it affects analysis
# test$cleantext <- gsub(tolower(test$is_part_of), "_journalheader_", test$cleantext) # Replace header with "_header_"
# test$full_text[2]
# tolower(test$is_part_of[2])
# test$cleantext[3]
# str_detect(test$full_text[2], tolower(test$is_part_of[2]))
# str_detect(test$cleantext, "_journalheader_")

# ARTICLES new basic cleaning
articles_new$cleantext <- tolower(articles_new$full_text2) # Lowercase
articles_new$cleantext <- gsub("- ", "", articles_new$cleantext) # Remove word line splits
articles_new$cleantext <- gsub("[[:punct:]]", "", articles_new$cleantext) # Remove punctuation
articles_new$cleantext <- gsub("[[:digit:]]", "", articles_new$cleantext) # Remove numbers
articles_new$cleantext <- gsub("\\s+", " ", str_trim(articles_new$cleantext)) # Remove extra whitespaces


# CS REVIEWS basic cleaning
cs_reviews$cleantext <- tolower(cs_reviews$full_text2) # Lowercase
cs_reviews$cleantext <- gsub("- ", "", cs_reviews$cleantext) # Remove word line splits
cs_reviews$cleantext <- gsub("[[:punct:]]", "", cs_reviews$cleantext) # Remove punctuation
cs_reviews$cleantext <- gsub("[[:digit:]]", "", cs_reviews$cleantext) # Remove numbers
cs_reviews$cleantext <- gsub("\\s+", " ", str_trim(cs_reviews$cleantext)) # Remove extra whitespaces

# OTHER REVIEWS basic cleaning
other_reviews$cleantext <- tolower(other_reviews$full_text2) # Lowercase
other_reviews$cleantext <- gsub("- ", "", other_reviews$cleantext) # Remove word line splits
other_reviews$cleantext <- gsub("[[:punct:]]", "", other_reviews$cleantext) # Remove punctuation
other_reviews$cleantext <- gsub("[[:digit:]]", "", other_reviews$cleantext) # Remove numbers
other_reviews$cleantext <- gsub("\\s+", " ", str_trim(other_reviews$cleantext)) # Remove extra whitespaces

# double check this worked?
articles_new$cleantext[1]
names(other_reviews)

# remove listed full_text to save space
articles_new <- articles_new %>% select(-full_text)
cs_reviews <- cs_reviews %>% select(-full_text)
other_reviews <- other_reviews %>% select(-full_text)

save(articles_new, file = "~/Desktop/articles_new.RData")
save(cs_reviews, file = "~/Desktop/cs_reviews.RData")
save(other_reviews, file = "~/Desktop/other_reviews.RData")

# Next time, maybe do cleaning on whole dataset before splitting into three?

write.csv(table2, file = "~/Desktop/table2.csv")
