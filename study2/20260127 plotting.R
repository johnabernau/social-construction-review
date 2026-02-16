# Tue Jan 27 14:12:01 2026 ------------------------------
# after 20260124 analysis script has been run, plots here

library("viridis")  
library(RColorBrewer)
#display.brewer.all()
library(wesanderson)
#names(wes_palettes)

# PLOT 1 = All data in one facet w/ trend lines --------------------------------
all_tab$section <- factor(all_tab$section, levels = c("teaching_soc",
                                                     "general",
                                                     "substantive",
                                                     "book_reviews"),
                          labels = c("Teaching Sociology",
                                     "Generalist",
                                     "Substantive",
                                     "Book Reviews"))
all_tab %>% 
  ggplot(aes(year, p)) + 
  geom_smooth(aes(color = section, linetype = section), 
              se = F, span = 0.6, size = 1) +
  scale_y_continuous(name = "Avg \"social* construct\" use per article") +
  scale_x_continuous(name = "Year") +
  scale_colour_brewer(palette = "Spectral", direction = -1, name = NULL) +
  scale_linetype_discrete(name = NULL) +
  theme_minimal() +
  theme(plot.margin=unit(c(0.5,0.5,0.5,0.5), 'cm'))


ggsave("~/Desktop/scr_alltrend.jpg", width = 7.5, height = 4, units = "in")

customcolors <- brewer.pal(4, "Spectral")

# PLOT 2 = Generalist post 1950 w/ facet ---------------------------------------

an_tab %>% 
  filter(journal %in% general_int,
         year > 1950) %>% 
  ggplot(aes(year, p)) + 
  geom_point(color = customcolors[3]) +
  geom_smooth(color = "black", span = 0.6, se = F, size = 1) +
  facet_wrap(~journal, ncol = 4, scales = "free_y") +
  # scale_colour_brewer(palette = "Dark2", direction = -1, 
  #                     name = NULL, guide = "none") +
  # scale_fill_manual(values = wes_palette("GrandBudapest1", n = 8))
  #scale_color_viridis_d(name = NULL, guide = "none", option = "D") +
  geom_vline(xintercept = 1999, linetype = "dashed", alpha = 0.5) +
  scale_y_continuous(name = "Avg \"social* construct\" use per article") +
  scale_x_continuous(name = "Year") +
  theme_minimal() +
  theme(plot.margin=unit(c(0.5,0.5,0.5,0.5), 'cm'))

ggsave("~/Desktop/scr_general2.jpg", width = 9, height = 6, units = "in")


# PLOT 3 = Substantive post 1950 w/ facet --------------------------------------
an_tab %>% 
  filter(journal %in% substantive,
         year > 1950) %>% 
  ggplot(aes(year, p)) + 
  geom_point(color = customcolors[2]) +
  geom_smooth(color = "black", span = 0.6, se = F, size = 1) +
  facet_wrap(~journal, ncol = 4, scales = "free_y") +
  # scale_colour_brewer(palette = "Dark2", direction = -1, 
  #                     name = NULL, guide = "none") +
  # scale_fill_manual(values = wes_palette("GrandBudapest1", n = 8))
  #scale_color_viridis_d(name = NULL, guide = "none", option = "D") +
  geom_vline(xintercept = 1999, linetype = "dashed", alpha = 0.5) +
  scale_y_continuous(name = "Avg \"social* construct\" use per article") +
  scale_x_continuous(name = "Year") +
  theme_minimal() +
  theme(plot.margin=unit(c(0.5,0.5,0.5,0.5), 'cm'))

ggsave("~/Desktop/scr_substantive2.jpg", width = 9, height = 6, units = "in")

# PLOT 4 = Teaching / CS / Reviews post-1950 w/ facet --------------------------

classbooks <- all_tab %>% 
  filter(section %in% c("Teaching Sociology", "Book Reviews"))

classbooks$section <- as.character(classbooks$section)
count(classbooks, section)
classbooks$section[classbooks$journal == "Contemporary Sociology"] <- "Contemp Soc Reviews"
classbooks$section[classbooks$section == "Book Reviews"] <- "Other Book Reviews"

classbooks$section <- factor(classbooks$section, 
                             levels = c("Teaching Sociology",
                                        "Contemp Soc Reviews",
                                        "Other Book Reviews"))
classbooks %>% 
  ggplot(aes(year, p)) + 
  geom_point(aes(color = section)) +
  geom_smooth(color = "black", span = 0.6, se = F, size = 1) +
  facet_wrap(~section, ncol = 4, scales = "free") +
  geom_vline(xintercept = 1999, linetype = "dashed", alpha = 0.5) +
  scale_y_continuous(name = "Avg \"social* construct\" use per article") +
  scale_x_continuous(name = "Year") +
  scale_color_manual(values = c(customcolors[4], customcolors[1], customcolors[1]), guide = NULL) +
  theme_minimal() +
  theme(plot.margin=unit(c(0.5,0.5,0.5,0.5), 'cm'))



ggsave("~/Desktop/scr_classbooks2.jpg", width = 7.5, height = 4, units = "in")


# Checking berger citations ----------------------------------------------------

# Count Berger and Luckmann word count
allthree$berger <- str_count(allthree$cleantext,
                                "berger and luckmann") # count
allthree$berger2 <- str_count(allthree$cleantext,
                              "berger luckmann") # count
allthree$berger3 <- allthree$berger + allthree$berger2

# allthree %>% slice_max(berger3, n = 5) %>% View()

# checking "references" 
# test
# test <- sample_n(allthree, size = 25)
# for (x in 1:nrow(test)){
#   test$references[x] <- paste(unlist(test$references[x]), collapse = " ")
# }
# test$r <- str_count(test$references,
#                              "Press") # count
# actual
# flatten lists
for (x in 1:nrow(allthree)){
  allthree$references[x] <- paste(unlist(allthree$references[x]), collapse = " ")
  if (x %% 1000 == 0){
    print(paste("Counting row", x))
  }
}

allthree$ref_clean <- tolower(allthree$references) # Lowercase
allthree$ref_clean <- gsub("- ", "", allthree$ref_clean) # Remove word line splits
allthree$ref_clean <- gsub("[[:punct:]]", "", allthree$ref_clean) # Remove punctuation
allthree$ref_clean <- gsub("[[:digit:]]", "", allthree$ref_clean) # Remove numbers
allthree$ref_clean <- gsub("\\s+", " ", str_trim(allthree$ref_clean)) # Remove extra whitespaces


# count references
# allthree$berger_references <- str_count(allthree$references,"Berger and Luckmann") +
#   str_count(allthree$references,"Berger & Luckmann") # count
# allthree$berger_references2 <- str_count(allthree$references,
#                                          "Berger, Peter and Thomas Luckmann")
allthree$scor_references <- str_count(allthree$ref_clean,
                                         "social construction of reality")

cite_check <- allthree %>% select(year, scr_count, berger3, scor_references)

t <- cite_check %>% 
  group_by(year) %>% 
  summarise(scr_intext = sum(scr_count),
            berger_intext = sum(berger3),
            scor_references = sum(scor_references)) %>% 
  ungroup() %>% 
  pivot_longer(cols = c(scr_intext:scor_references), 
               names_to = "type", values_to = "count")

t$type <- factor(t$type, levels = c("scor_references", "berger_intext",
                                    "scr_intext"))
t %>% 
  filter(year > 1950) %>% 
  ggplot(aes(year, count)) + 
  geom_point(aes(color = type)) +
  geom_smooth(color = "black", se = F, span = 0.6) +
  facet_wrap(~type, ncol = 5) +
  geom_vline(xintercept = 1966, linetype = "dotted") +
  scale_color_discrete(guide = NULL) +
  #scale_y_log10() +
  labs(y = "Count", x = "Year") +
  scale_linetype(guide = NULL) +
  theme_minimal() +
  theme(plot.margin=unit(c(0.5,0.5,0.5,0.5), 'cm'))

ggsave("~/Desktop/scr_citations.jpg", width = 7.5, height = 4, units = "in")
