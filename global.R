# setup ----
options(shiny.maxRequestSize = 30 * 1024^2)

library(shiny)
library(sonify)
library(tuneR)
library(stringr)
library(scales)

library(dplyr)
library(tidyr)
library(forcats)
library(DBI)
library(RSQLite)
library(dbplyr)

library(ggplot2)
library(ggimage)
library(cowplot)
library(magick)



# experimental levels ----

charlevels <- c(
  "control", "bldg",
  "lay", "inc.d3", "inc.d9", "inc.d17",
  "hatch", "n5", "n9"
)

sexlevels <- c("female", "male")

tissuelevels <- c("hypothalamus", "pituitary", "gonad")

comparisonlevels <- c(
  "control_bldg", "bldg_lay", "lay_inc.d3",
  "inc.d3_inc.d9", "inc.d9_inc.d17", "inc.d17_hatch",
  "hatch_n5", "n5_n9"
)
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

## SQLite Pool Connection
con <- dbConnect(SQLite(), "data/musicalgenes.sqlite")

## candidate counts and differentiall expressed gene results

candidatecounts <- tbl(con, "candidatecounts")
alldeg <- tbl(con, "alldeg")

## Go terms associated with parental care
parentalbehavior <- tbl(con, "parentalbehavior")

parentalbehaviorgenes <- parentalbehavior %>%
  mutate(gene = toupper(gene)) %>%
  pull(gene)

## tsne data

tsne <- tbl(con, "tsne")

## get gene ids
gene_names <- candidatecounts %>%
  dplyr::distinct(gene) %>%
  dplyr::arrange(gene) %>%
  pull()


numberstonotes <- data.frame(
  averaged = c(0:7),
  note = c("A", "B",  "C",  "D", "E", "F",  "G", "AA")
)

hugo <- read.csv("data/hugo.csv") %>% dplyr::distinct(gene, name)
head(hugo)
