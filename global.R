# setup ----
options(shiny.maxRequestSize = 30 * 1024^2)

library(shiny)
library(shinydashboard)
library(sonify)
library(tuneR)
library(scales)
library(tidyverse)
library(DBI)
library(duckdb)
library(dbplyr)
library(ggimage)
library(cowplot)
library(magick)
library(ggpubr)
library(corrr)


# experimental levels and colors ----

source("attributes.R")


# gene names and descriptions
con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

# data ----

candidatecounts <- tbl(con, "candidatecounts") %>% 
  left_join(tbl(con, "hugo"), ., by = "gene")  %>%
  mutate(
    gene = toupper(gene),
    gene_name = paste(gene, name, sep = ": ")
  ) %>% 
  collect()

description <- tbl(con, "description") %>% collect()
hugo <- tbl(con, "hugo") %>% collect()

## candidate counts and differentiall expressed gene results

# data from https://github.com/macmanes-lab/DoveParentsRNAseq


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
               "saxophone")

orchestra <- sort(orchestra)
