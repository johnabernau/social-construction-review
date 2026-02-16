# Fri Jan 16 09:05:40 2026 ------------------------------
# streaming JSTOR / JSON
# File received after JSTOR request

require(jsonlite)
require(tidyverse)



#loading v1: just reads in as df
# names = iid / full_text / references
my_data <- file("/Users/jberna5/Desktop/jstor_fulltext_20260116.jsonl")
jstor_full <- stream_in(my_data, pagesize = 5000) # takes ~5 min
names(jstor_full)
save(jstor_full, file = "~/Desktop/jstor_sociology_full.RData")
jstor_full[10:20,] %>% View()

# jstor_full$full_text[1] # This causes R to freeze


# After streaming / saving, use this:
load("~/Desktop/jstor_sociology_full.RData")


