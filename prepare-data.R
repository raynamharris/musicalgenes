library(DBI)
library(duckdb)
library(tidyverse)

source("attributes.R")

con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

# candidate counts ----
candidatecounts <- read_csv("./data/candidatecounts.csv") %>%
  mutate(
    treatment = factor(treatment, levels = alllevels),
    tissue = factor(tissue, levels = tissuelevels)
  ) %>%
  filter(treatment %in% alllevels) %>%
  na.omit()

dbWriteTable(
  con,
  "candidatecounts",
  candidatecounts,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# differential expressed gene results ----
alldeg <- read_csv("./data/allDEG.csv") %>%
  mutate(
    tissue = factor(tissue, levels = tissuelevels),
    direction = factor(direction, levels = charlevels),
    comparison = factor(comparison, levels = comparisonlevels)
  )

alldeg <- select(alldeg, -X1)

dbWriteTable(
  con,
  "alldeg",
  alldeg,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# hugo ----
hugo <- read_csv("data/hugo.csv")

dbWriteTable(
  con,
  "hugo",
  hugo %>% distinct(),
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# disease ----
disease <- read_tsv("data/DISEASE-ALLIANCE_HUMAN_29.tsv",
                    skip = 19, col_names = F) %>%
  distinct(X5,X8) %>%
  rename(gene = X5, disease = X8) %>%
  arrange(gene, disease) %>%
  group_by(gene) %>%
  summarize(Diseases = str_c(disease, collapse = "; "))

dbWriteTable(
  con,
  "disease",
  disease,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# description ----
description <- read_tsv("data/GENE-DESCRIPTION-TSV_HUMAN_18.tsv",
                        skip = 14, col_names = F) %>%
  rename(GO = X1, gene = X2, Description = X3)

dbWriteTable(
  con,
  "description",
  description,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# GO TERMS ----
goterms <- read_tsv("data/go_terms.mgi", col_names = F) %>%
  filter(X1 == "Biological Process") %>%
  select(X2, X3) %>%
  rename(GOid = X2, GOterm = X3)

dbWriteTable(
  con,
  "goterms",
  goterms,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# bpgo ----

bpgo <- read_tsv("data/gene_association.mgi",
                 skip = 24, col_names = F) %>%
  select(X3, X9, X5) %>%
  rename(gene = X3, ontology = X9, GOid = X5) %>%
  filter(ontology == "P")

dbWriteTable(
  con,
  "bpgo",
  bpgo,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

dbDisconnect(con, shutdown = T)

# testing ----

con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

dbListTables(con)

dplyr::tbl(con, "alldeg")

dbDisconnect(con, shutdown = T)
