# setup ----
library(shiny)
library(tidyverse)
library(sonify)
library(stringr)
library(scales)

options(shiny.maxRequestSize = 30 * 1024^2)

# experimental levels ----

charlevels <- c(
  "control", "bldg",
  "lay", "inc.d3", "inc.d9", "inc.d17",
  "hatch", "n5", "n9"
)

sexlevels <- c("female", "male")

tissuelevels <- c("hypothalamus", "pituitary", "gonad")

comparisonlevels <- c("control_bldg", "bldg_lay","lay_inc.d3", 
                      "inc.d3_inc.d9", "inc.d9_inc.d17","inc.d17_hatch",
                      "hatch_n5", "n5_n9")
# experimental colors
colorschar <-  c("control" = "#cc4c02", 
                 "bldg"= "#fe9929", 
                 "lay"= "#fed98e", 
                 "inc.d3"= "#78c679", 
                 "inc.d9"= "#31a354", 
                 "inc.d17"= "#006837", 
                 "hatch"= "#08519c",
                 "n5"= "#3182bd", 
                 "n9"= "#6baed6")

colorssex <- c("female" = "#969696", "male" = "#525252")

colorstissue <- c(
  "hypothalamus" = "#d95f02",
  "pituitary" = "#1b9e77",
  "gonads" = "#7570b3"
)

allcolors <- c(colorschar, colorssex, colorstissue)

# data ----
## candidate counts
df <- read_csv("./data/candidatecounts.csv") %>% 
  mutate(
    treatment = factor(treatment, levels = charlevels),
    tissue = factor(tissue, levels = tissuelevels)
  )

## differentiall expressed gene results
df2 <- read_csv("./data/allDEG.csv") %>% 
  mutate(
    tissue = factor(tissue, levels = tissuelevels),
    direction = factor(direction, levels = charlevels),
    comparison = factor(comparison, levels = comparisonlevels)
  )

## Go terms associated with parental care
parentalbehavior <- read_table("data/GO_term_parentalbehavior.txt")
names(parentalbehavior) <- "allGO"

parentalbehavior <- parentalbehavior %>% 
  mutate(
    id = sapply(strsplit(allGO, "	"), "[", 1),
    gene= sapply(strsplit(allGO, "	"), "[", 2),
    name = sapply(strsplit(allGO, "	"), "[", 3),
    GO = sapply(strsplit(allGO, "	"), "[", 6)
  )

parentalbehavior$allGO <- NULL

parentalbehaviorgenes <- parentalbehavior %>%
  mutate(gene = str_to_upper(gene)) %>%
  pull(gene)

## tsne data

tsne <- read_csv("data/tsne.csv")
tsne$tissue <- factor(tsne$tissue, levels = c("hypothalamus", "pituitary", "gonads"))
tsne <- tsne %>% mutate(tissue = fct_recode(tissue, "gonad" = "gonads"))


## get gene ids
gene_names <- df %>%
  dplyr::distinct(gene) %>%
  dplyr::arrange(gene) %>%
  pull()


