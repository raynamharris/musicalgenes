library(DBI)
library(RSQLite)
library(dplyr)
library(readr)
library(forcats)
library(readr)

con <- dbConnect(SQLite(), "data/musicalgenes.sqlite")

charlevels <- c(
  "control", "bldg",
  "lay", "inc.d3", "inc.d9", "inc.d17",
  "hatch", "n5", "n9"
)

maniplevels <- c("m.inc.d3" ,  "early" ,  "m.inc.d9" , "m.inc.d17", "prolong" ,  "m.n2", "extend")

alllevels <- c("control", "bldg", "lay", "inc.d3", "m.inc.d3" ,  
               "inc.d9", "m.inc.d9" , "early" ,
               "inc.d17",  "m.inc.d17", "prolong", 
               "hatch",  "m.n2", "extend",
               "n5",  
               "n9")

sexlevels <- c("female", "male")

tissuelevels <- c("hypothalamus", "pituitary", "gonad")

comparisonlevels <- c(
  "control_bldg", "bldg_lay", "lay_inc.d3",
  "inc.d3_inc.d9", "inc.d9_inc.d17", "inc.d17_hatch",
  "hatch_n5", "n5_n9"
)

alllevels <- c("control", "bldg", "lay", "inc.d3", "m.inc.d3" ,  
               "inc.d9", "m.inc.d9" , "early" ,
               "inc.d17",  "m.inc.d17", "prolong", 
               "hatch",  "m.n2", "extend",
               "n5",  
               "n9")


# experimental colors
colorschar <- c(
  "control" = "#cc4c02",
  "bldg" = "#fe9929",
  "lay" = "#fed98e",
  "inc.d3" = "#78c679",
  "inc.d9" = "#31a354",
  "inc.d17" = "#006837",
  "hatch" = "#08519c",
  "n5" = "#3182bd",
  "n9" = "#6baed6"
)

colorssex <- c("female" = "#969696", "male" = "#525252")

colorstissue <- c(
  "hypothalamus" = "#d95f02",
  "pituitary" = "#1b9e77",
  "gonads" = "#7570b3"
)

allcolors <- c(colorschar, colorssex, colorstissue)

# data ----

## candidate counts
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

## differentiall expressed gene results
alldeg <- read_csv("./data/allDEG.csv") %>%
  mutate(
    tissue = factor(tissue, levels = tissuelevels),
    direction = factor(direction, levels = charlevels),
    comparison = factor(comparison, levels = comparisonlevels)
  )

dbWriteTable(
  con,
  "alldeg",
  alldeg,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

## Go terms associated with parental care
parentalbehavior <- read_table("data/GO_term_parentalbehavior.txt")
names(parentalbehavior) <- "allGO"

parentalbehavior <- parentalbehavior %>%
  mutate(
    id = sapply(strsplit(allGO, "	"), "[", 1),
    gene = sapply(strsplit(allGO, "	"), "[", 2),
    name = sapply(strsplit(allGO, "	"), "[", 3),
    GO = sapply(strsplit(allGO, "	"), "[", 6)
  )

parentalbehavior$allGO <- NULL

dbWriteTable(
  con,
  "parentalbehavior",
  parentalbehavior,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)

tsne <- read_csv("data/tsne.csv")
tsne$tissue <- factor(tsne$tissue, levels = c("hypothalamus", "pituitary", "gonads"))
tsne <- tsne %>% mutate(tissue = fct_recode(tissue, "gonad" = "gonads"))

dbWriteTable(
  con,
  "tsne",
  tsne,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = TRUE
)


