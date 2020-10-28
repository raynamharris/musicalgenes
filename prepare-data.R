library(DBI)
library(duckdb)
library(tidyverse)

source("attributes.R")

con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

# hugo ----
hugo <- read_csv("data/hugo.csv") %>%
  distinct(gene, name)

dbWriteTable(
  con,
  "hugo",
  hugo %>% distinct(),
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# candidate counts ----
candidatecounts <- read_csv("./data/candidatecounts.csv") %>%
  mutate(
    treatment = factor(treatment, levels = alllevels),
    tissue = factor(tissue, levels = tissuelevels)
  ) %>%
  filter(treatment %in% alllevels) %>%
  na.omit() %>%
  left_join(., hugo, by = "gene")  %>%
  mutate(
    gene = toupper(gene),
    gene_name = paste(gene, name, sep = ": ")
  )
  

dbWriteTable(
  con,
  "candidatecounts",
  candidatecounts,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# get list of candidate genes 
# filter all subsequent tables by candidate genes to make db faster

candidategenes <- candidatecounts %>%
  select(gene) %>% distinct(gene) %>% arrange(gene) %>% pull(gene)
candidategenes

# differential expressed gene results ----
alldeg <- read_csv("./data/allDEG.csv") %>%
  mutate(
    tissue = factor(tissue, levels = tissuelevels),
    direction = factor(direction, levels = charlevels),
    comparison = factor(comparison, levels = comparisonlevels)
  ) %>% 
  select(-X1) %>%
  filter(gene %in% candidategenes) 

dbWriteTable(
  con,
  "alldeg",
  alldeg,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)


# disease ----
disease <- read_tsv("./data/DISEASE-ALLIANCE_HUMAN_29.tsv",
                    skip = 19, col_names = F) %>%
  distinct(X5,X8) %>%
  rename(gene = X5, disease = X8) %>%
  arrange(gene, disease) %>%
  filter(gene %in% candidategenes) %>%
  group_by(gene) %>%
  summarize(diseases = str_c(disease, collapse = "; ")) %>%
  full_join(., hugo, by = "gene") %>% 
  mutate(gene_name = paste(gene, name, sep = ": ")) %>%
  select(gene, name, gene_name, diseases)

dbWriteTable(
  con,
  "disease",
  disease,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# description ----
descriptions <- read_tsv("./data/GENE-DESCRIPTION-TSV_HUMAN_18.tsv",
                        skip = 14, col_names = F) %>%
  rename(GO = X1, gene = X2, Description = X3) %>%
  filter(gene %in% candidategenes)  %>%
  full_join(., hugo, by = "gene") %>% 
  mutate(gene_name = paste(gene, name, sep = ": "))

dbWriteTable(
  con,
  "descriptions",
  descriptions,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

# GO TERMS ----
goterms <- read_tsv("./data/go_terms.mgi", col_names = F) %>%
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

bpgo <- read_tsv("./data/gene_association.mgi",
                 skip = 24, col_names = F) %>%
  select(X3, X9, X5) %>%
  rename(gene = X3, ontology = X9, GOid = X5) %>%
  filter(ontology == "P") %>%
  full_join(., goterms, by = "GOid") %>%
  mutate(gene = toupper(gene)) %>%
  full_join(., hugo, ., by = "gene")  %>%
  filter(gene %in% candidategenes) %>%
  mutate(gene_name = paste(gene, name, sep = ": "))

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

dbDisconnect(con, shutdown = T)
