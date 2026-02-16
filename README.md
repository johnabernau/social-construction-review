# Is Reality Still Socially Constructed?

Accompanying materials for manuscript "Is Reality Still Socially Constructed?" published 2026 in *The American Sociologist* (DOI link here). Licensing agreements from Constellate and JSTOR prevent sharing complete full-text data, but analysis scripts and secondary datasets are included here as available. 

## Study 1
Raw data for each journal (ASR, AJS, SF) were collected via Constellate, which exports extremely large csv files for metadata, unigrams, bigrams, and trigrams. The first three cleaning scripts cleaned and saved these as RData files. Subsequent analysis conducted in the attached scripts: 
- 20250304 start = cleaning and summary statistics of metadata
- 20250515 start2 = filtering text data based on clean metadata
- 20250516 analysis = searching for "social* construct" and plotting results
- 20250520 analysis = extra analyses, not reported in manuscript

The scr_df.RData file is the exported results after word-search results were bound together. 

## Study 2
After downloading the full JSTOR metadata file, I used the following scripts to:
- 20251205 jstor json meta stream = Stream the metadata file in using jsonlite, selecting for discipline "sociology"
- 20251217 journal_selection = Filter by "article", export "research_journals.csv" to manually select ones to keep, use this list to produce "bernau_request_ids2.txt" to submit in JSTOR request (see PDF of request confirmation).
- 20260116 jstor jsonfulltext stream = Stream fulltext json file and save as RData.
- 20260121 journals_tokeep = Filter final sample of journals to keep, join metadata and full-text, recode for journal title-changes, descriptive table of 18 journals, unlist full-text using for-loop, cleaning full-text, save as datasets for 1) articles, 2) *Contemporary Sociology* book reviews, and 3) other book reviews.
- 20260124 analysis = Bind these three together again for "social[:alpha* construct" word search, recode and / or remove incorrect / duplicate book reviews, export final table of descriptives for journals (see table2.csv), recoding (shorten) journal titles,  producing tabulations of SCR counts per journal year.
- 20260127 plotting = Final plotting and robustness checks
