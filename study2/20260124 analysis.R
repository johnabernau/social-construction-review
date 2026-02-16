# Sat Jan 24 15:05:23 2026 ------------------------------
# analysis of new journals, cs reviews, and other_reviews

require(tidyverse)
`%ni%` = Negate(`%in%`)

# Startup, loading, testing ----------------------------------------------------
# articles new = 41216 x 17vars
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/articles_new.RData")

# cs_reviews = 24625 x 17vars
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/cs_reviews.RData")

# other_reviews = 45041 x 17vars
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/other_reviews.RData")

# glimpse
sample_n(articles_new, 10) %>% View()

# test SCR search
# t <- "this is a sentence about social construction and another word socially constructed what about socialized constructionism"
# str_count(t, "social[:alpha:]* construct") # count
# str_extract_all(t, "social[:alpha:]* construct") # extract list


# Binding together for one big operation (N = 110882) --------------------------
allthree <- bind_rows(articles_new, cs_reviews, other_reviews)

# Count, extract SCR, total word count
allthree$scr_count <- str_count(allthree$cleantext,
                                    "social[:alpha:]* construct") # count
allthree$scr_extract <- str_extract_all(allthree$cleantext,
                                            "social[:alpha:]* construct") # extract
allthree$word_count <- str_count(allthree$cleantext, '\\w+')

names(allthree)

# Examine outliers -------------------------------------------------------------
# 93 titled book reviews incorrectly coded as research articles
allthree$content_subtype[allthree$title == "Book Reviews"] <- "book-review"

# book reviews in AJS 130.4 (1998) all have correct metadata but wrong PDF.
# mistake98 <- allthree %>% 
#   filter(journal == "American Journal of Sociology",
#          year == 1998,
#          title == "Book Reviews")
# # only 4/156 were correctly uploaded
# m2 <- mistake98 %>% distinct(cleantext, .keep_all = TRUE)
# checked all AJS book reviews
ajs_bookreviews <- allthree %>% 
  filter(journal == "American Journal of Sociology",
         title == "Book Reviews")
# only 18 / 512 book reviews were correctly uploaded (N = 494)
m3 <- ajs_bookreviews %>% distinct(cleantext, .keep_all = TRUE)

# doing this for entire dataset just to be safe (Removed N = 1024 duplicates)
allthree <- allthree %>% distinct(cleantext, .keep_all = TRUE)


#save(allthree, file = "~/Desktop/allthree.RData")
rm(list = ls())
load("/Users/jberna5/Library/CloudStorage/GoogleDrive-bernau.john@gmail.com/My Drive/_cloudlocal/1. Desktop/2. Publications/scr_review/20251205 AS RR/allthree.RData")

count(allthree, content_subtype)


# Table 2 Descriptives ---------------------------------------------------------
min <- allthree %>%  
  count(journal, year) %>% 
  group_by(journal) %>% 
  slice_min(year, n=1) %>% 
  mutate(year_min = year) %>% 
  select(-year, -n)
max <- allthree %>%  
  count(journal, year) %>% 
  group_by(journal) %>% 
  slice_max(year, n=1) %>% 
  mutate(year_max = year) %>% 
  select(-year, -n)
cnt <- allthree %>%  
  count(journal, content_subtype) %>% 
  mutate(content2 = case_when(
    content_subtype == "book-review" ~ "book_review",
    content_subtype == "research-article" ~ "research_article")) %>% 
  select(-content_subtype) %>% 
  pivot_wider(names_from = content2, values_from = n) %>% 
  mutate(book_review = replace_na(book_review, 0),
         research_article = replace_na(research_article, 0))
wrds <- allthree %>% 
  group_by(journal) %>% 
  summarise(totalwords_m = sum(word_count)/1000000) %>% 
  ungroup()
table2 <- full_join(min, max) %>% 
  full_join(cnt) %>% 
  full_join(wrds) %>% 
  mutate(coverage = year_max-year_min)

rm(min, max, cnt, wrds)

sum(table2$book_review) # N = 69020 book reivews
sum(table2$research_article) # N = 40838 research articles
sum(table2$totalwords_m) # 339.7m total words
sum(table2$coverage) # 1,121 journal years / 1895-2022 / 127 yrs

write.csv(table2, file = "~/Desktop/table2.csv")


# Rename long journal titles ---------------------------------------------------
allthree$journal[allthree$journal == "The British Journal of Sociology"] <- "British Journal of Sociology"
allthree$journal[allthree$journal == "The Canadian Journal of Sociology"] <- "Canadian Journal of Sociology"
allthree$journal[allthree$journal == "International Social Science Review"] <- "Intl Social Science Review"
allthree$journal[allthree$journal == "Journal for the Scientific Study of Religion"] <- "Jnl for the Sci Study of Religion"
allthree$journal[allthree$journal == "Journal of Health and Social Behavior"] <- "Jnl of Health and Social Behavior"

# ARTICLES NEW ----------------------------------------------------------------
# create reference lists
general_int <- c("Annual Review of Sociology",
                 "The American Sociologist",
                 "American Journal of Sociology",
                 "American Sociological Review",
                 "European Journal of Sociology",
                 "Intl Social Science Review",
                 "British Journal of Sociology",
                 "Canadian Journal of Sociology")

substantive <- c("Social Psychology Quarterly",
                 "Journal of Marriage and Family",
                 "Jnl for the Sci Study of Religion",
                 "Theory and Society",
                 "Race, Gender & Class",
                 "Signs",
                 "Jnl of Health and Social Behavior",
                 "Sociology of Education")

# general = 19845
count(allthree, journal %in% general_int & content_subtype == "research-article")
# substantive = 19240
count(allthree, journal %in% substantive & content_subtype == "research-article")

# OR = 44395
count(allthree, content_subtype == "book-review" & journal != "Contemporary Sociology")
# CS = 24625
count(allthree, content_subtype == "book-review" & journal == "Contemporary Sociology")
# teaching = 1753
count(allthree, content_subtype != "book-review" & journal == "Teaching Sociology")


# only research articles (N = 40838)
articles_new <- allthree %>% 
  filter(content_subtype == "research-article" & journal != "Contemporary Sociology")

# # count(articles_new, scr_count)
# articles_new %>% slice_max(scr_count, n = 25) %>% View()

# journal articles per year
apy <- articles_new %>% 
  count(journal, year) %>% 
  rename(apy = n)
# scr per year
scr_py <- articles_new %>% 
  count(journal, year, scr_count) %>% 
  filter(scr_count > 0) %>% 
  mutate(yr_count = scr_count*n) %>% 
  group_by(journal, year) %>% 
  mutate(scr_articles = sum(n), yr_count2 = sum(yr_count)) %>% 
  ungroup()
# collapse and join
an_tab <-  scr_py %>% 
  select(journal, year, scr_articles, yr_count2) %>% 
  unique() %>% 
  full_join(apy) %>% 
  arrange(journal, year) %>% 
  mutate(p = yr_count2 / apy)
# clean workspace
rm(apy, scr_py)
# replace NA with 0s
an_tab <- an_tab %>% replace(is.na(.), 0)

# Re-level for proper ordering
an_tab$journal <- factor(an_tab$journal, 
                         levels = c("American Journal of Sociology",
                                    "American Sociological Review",
                                    "Annual Review of Sociology",
                                    "The American Sociologist",
                                    "European Journal of Sociology",
                                    "British Journal of Sociology",
                                    "Canadian Journal of Sociology",
                                    "Intl Social Science Review",
                                    "Social Psychology Quarterly",
                                    "Journal of Marriage and Family",
                                    "Jnl for the Sci Study of Religion",
                                    "Theory and Society",
                                    "Race, Gender & Class",
                                    "Signs",
                                    "Jnl of Health and Social Behavior",
                                    "Sociology of Education",
                                    "Teaching Sociology"))

# OTHER REVIEWS ----------------------------------------------------------------
# the other reviews (N = 44395)
other_reviews <- allthree %>% 
  filter(content_subtype == "book-review" & journal != "Contemporary Sociology")
# count(other_reviews, scr_count)
# other_reviews %>% slice_max(scr_count, n = 25) %>% View()

# journal articles per year
apy <- other_reviews %>% 
  count(journal, year) %>% 
  rename(apy = n)
# scr per year
scr_py <- other_reviews %>% 
  count(journal, year, scr_count) %>% 
  filter(scr_count > 0) %>% 
  mutate(yr_count = scr_count*n) %>% 
  group_by(journal, year) %>% 
  mutate(scr_articles = sum(n), yr_count2 = sum(yr_count)) %>% 
  ungroup()
# collapse and join
or_tab <-  scr_py %>% 
  select(journal, year, scr_articles, yr_count2) %>% 
  unique() %>% 
  full_join(apy) %>% 
  arrange(journal, year) %>% 
  mutate(p = yr_count2 / apy)
# clean workspace
rm(apy, scr_py)
# replace NA with 0s
or_tab <- or_tab %>% replace(is.na(.), 0)

# CS REVIEWS ----------------------------------------------------------------
# one dataset will be CS book reviews (N = 24625)
cs_reviews <- allthree %>% 
  filter(content_subtype == "book-review" & journal == "Contemporary Sociology")
# count(cs_reviews, scr_count)
# cs_reviews %>% slice_max(scr_count, n = 25) %>% View()

# journal articles per year
apy <- cs_reviews %>% 
  count(journal, year) %>% 
  rename(apy = n)
# scr per year
scr_py <- cs_reviews %>% 
  count(journal, year, scr_count) %>% 
  filter(scr_count > 0) %>% 
  mutate(yr_count = scr_count*n) %>% 
  group_by(journal, year) %>% 
  mutate(scr_articles = sum(n), yr_count2 = sum(yr_count)) %>% 
  ungroup()
# collapse and join
cs_tab <-  scr_py %>% 
  select(journal, year, scr_articles, yr_count2) %>% 
  unique() %>% 
  full_join(apy) %>% 
  arrange(journal, year) %>% 
  mutate(p = yr_count2 / apy)
# clean workspace
rm(apy, scr_py)
# replace NA with 0s
cs_tab <- cs_tab %>% replace(is.na(.), 0)



# [FINAL] Joining all together for master plot------------------------------------------

# coding for general / sub / teaching / reviews
an_tab <- an_tab %>% 
  mutate(section = ifelse(journal %in% general_int, "general",
                          ifelse(journal %in% substantive, "substantive",
                                 "teaching_soc")))
or_tab <- or_tab %>% 
  mutate(section = "book_reviews")
cs_tab <- cs_tab %>% 
  mutate(section = "book_reviews")

# all_tab has entire dataset journal-years 
all_tab <- an_tab %>% 
  bind_rows(or_tab, cs_tab)

all_tab$section <- factor(all_tab$section, levels = c("general",
                                                      "substantive",
                                                      "teaching_soc",
                                                      "book_reviews"))
# class_review has only teaching and book reviews (CS + OR)
class_review <- an_tab %>% 
  filter(journal == "Teaching Sociology") %>% 
  bind_rows(or_tab, cs_tab)


# allthree
names(allthree)

scr_list <- as.data.frame(unlist(allthree$scr_extract))
names(scr_list) <- "wrd"
count(scr_list, wrd, sort = TRUE)

# See plotting script for plots
