# setup ----
options(shiny.maxRequestSize = 30 * 1024^2)

library(shiny)

library(shinydashboard)

library(sonify)
library(tuneR)
library(stringr)
library(scales)

library(tidyverse)
library(forcats)
library(DBI)
library(duckdb)
library(dbplyr)

library(ggplot2)
library(ggimage)
library(cowplot)
library(magick)

library(ggpubr)

library(scatterplot3d) 

library(corrr)

citation("sonify") ## for gene expression analysis

# experimental levels ----

charlevels <- c(
  "control", "bldg",
  "lay", "inc.d3", "inc.d9", "inc.d17",
  "hatch", "n5", "n9"
)

charlabels <- c(
  "control", "nest\nbuilding\n(bldg)",
  "1st egg\nlaid\n(lay)", "incubation\nday3\n(inc.d3)", 
  "incubation\nday9\n(inc.d9)", "incubation\nday17\n(inc.d17)",
  "2nd chick\nhatched\n(hatch)", "nestling\ncare day 5\n(n5)", 
  "nestling\ncare day 9\n(n9)"
)

alllevels <- c("control", "bldg", "lay", "inc.d3", "m.inc.d3" ,  
               "inc.d9", "m.inc.d9" , "early" ,
               "inc.d17", "m.inc.d17", "prolong" , 
               "hatch",  "m.n2", "extend",
               "n5",  
               "n9")

sexlevels <- c("female", "male")

tissuelevel <- c("hypothalamus", "pituitary", "gonad")
tissuelevels <- c("hypothalamus", "pituitary", "gonads")

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

colorsmanip <- c("m.inc.d3" = "#CDCDCD", 
                 "m.inc.d9" = "#959595", 
                 "m.inc.d17" = "#626262",
                 "m.n2" = "#262625", 
                 "early" = "#cbc9e2", 
                 "prolong" = "#9e9ac8" , 
                 "extend" = "#6a51a3" )

colorssex <- c("female" = "#969696", "male" = "#525252")

colorstissue <- c(
  "hypothalamus" = "#d95f02",
  "pituitary" = "#1b9e77",
  "gonads" = "#7570b3"
)

allcolors <- c(colorschar, colorsmanip, colorssex, colorstissue)

# gene names and descriptions
con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

# GO terms
goterms <- tbl(con, "goterms") %>% collect()

# genes associated with bilogical process (BP) GO terms 
bpgo <- tbl(con, "bpgo") %>%
  full_join(., tbl(con, "goterms"), by = "GOid") %>%
  left_join(tbl(con, "hugo"), ., by = "gene")  %>%
  mutate(
    gene = toupper(gene),
    gene_name = paste(gene, name, sep = ": ")
  ) %>% 
  distinct(gene, name, gene_name, GOterm) %>%
  arrange(GOterm, gene, gene_name) %>%
  collect() %>% 
  group_by(gene_name) %>%
  summarize(GOterms = str_c(GOterm, collapse = "; "))

# data ----

## candidate counts and differentiall expressed gene results

# data from https://github.com/macmanes-lab/DoveParentsRNAseq
candidatecounts <- tbl(con, "candidatecounts") %>%
  filter(treatment %in% alllevels) %>%
  left_join(., tbl(con, "description"), by = "gene") %>% 
  inner_join(., tbl(con, "hugo"), by = "gene") %>% 
  collect() %>% 
  mutate(
    gene_name = paste(gene, name, sep = ": "),
    treatment = factor(treatment, levels = alllevels),
    tissue = factor(tissue, levels = tissuelevels)
  )

## get gene ids
gene_names <- tbl(con, "candidatecounts") %>% 
  distinct(gene) %>%
  left_join(
    ., tbl(con, "hugo")
  ) %>% 
  mutate(gene_name = paste(gene, name, sep = ": ")) %>% 
  collect() %>% 
  drop_na() %>%
  dplyr::distinct(gene_name) %>%
  dplyr::arrange(gene_name) %>%
  pull()

dbDisconnect(con, shutdown = TRUE)

gene_names2 <- gene_names

numberstonotes <- data.frame(
  scaledmean = c(0:6),
  note = c("A", "B",  "C",  "D", "E", "F",  "G")
)

orchestra <- c("violin", 
               "french horn", "clarinet", "bassoon", "oboe",
               "trumpet", "trombone", "tuba",
               "upright bass", "viola", "cello",
               "piano", "keyboard",
               "saxaphone")

orchestra <- sort(orchestra)
