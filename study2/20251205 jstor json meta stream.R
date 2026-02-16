# Fri Dec  5 12:52:22 2025 ------------------------------
# streaming JSTOR / JSON

install.packages("jsonlite")
install.packages("nycflights13")
require(jsonlite)
require(tidyverse)

# example
#stream large dataset to file and back
library(nycflights13)
stream_out(flights, file(tmp <- tempfile()))
flights2 <- stream_in(file(tmp))
unlink(tmp)
all.equal(flights2, as.data.frame(flights))



#loading v1
con_out <- file(tmp <- tempfile(), open = "wb")
my_data <- file("/Users/jberna5/Desktop/jstor_metadata_2025-12-05.jsonl")

jstor_meta <- stream_in(my_data, handler = function(df){
  df <- filter(df, is_part_of == "American Journal of Sociology")
  stream_out(df, con_out, pagesize = 1000)
}, pagesize = 5000)

close(con_out)
mydata <- stream_in(file(tmp))
# examine
count(mydata, content_subtype)
names(mydata)




#loading v2: extracting all sociology
con_out <- file(tmp <- tempfile(), open = "wb")
my_data <- file("/Users/jberna5/Desktop/jstor_metadata_2025-12-05.jsonl")

jstor_meta <- stream_in(my_data, handler = function(df){
  df <- filter(df, grepl("sociology", tolower(discipline_names)))
  stream_out(df, con_out, pagesize = 1000)
}, pagesize = 5000)

close(con_out)
mydata <- stream_in(file(tmp))
# examine
count(mydata, content_subtype)
count(mydata, is_part_of)
names(mydata)

# saving data
save(mydata, file = "~/Desktop/jstor_sociology_meta.RData")
rm(mydata)
load("~/Desktop/jstor_sociology_meta.RData")


research <- mydata %>% 
  filter(content_subtype == "research-article")

research_journals <- research %>% count(is_part_of, languages)
