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

source("attributes.R")

# data ----

con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

# candidate counts and differentiall expressed gene results
# from https://github.com/macmanes-lab/DoveParentsRNAseq

candidatecounts <- tbl(con, "candidatecounts") %>% collect()


# gene names and descriptions
gene_names <- candidatecounts %>%
  dplyr::distinct(gene_name) %>%
  dplyr::arrange(gene_name) %>%
  pull()
gene_names2 <- gene_names

dbDisconnect(con, shutdown = TRUE)

