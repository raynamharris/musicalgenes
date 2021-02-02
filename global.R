# setup ----

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

# data from database (from prep-data.R) ----

con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")

# candidate counts and differentiall expressed gene results
# from https://github.com/macmanes-lab/DoveParentsRNAseq

hugo <- tbl(con, "hugo") %>% collect()
candidatecounts <- tbl(con, "candidatecounts") %>% collect()
hormones <- tbl(con, "hormones") %>% collect()

dbDisconnect(con, shutdown = TRUE)

# more data ----

# gene names and descriptions
gene_names <- candidatecounts %>%
  dplyr::distinct(gene_name) %>%
  dplyr::arrange(gene_name) %>%
  pull()
gene_names2 <- gene_names

# sample info
birds <- read_csv("data/00_birds.csv") %>%
  mutate(id = str_to_lower(bird)) %>%
  select(id, sex, treatment)  %>% 
  arrange(id)

# hormones for hormone only plots

hormones2 <- hormones  %>% 
  left_join(., birds) %>%
  mutate(treatment = factor(treatment, levels = alllevels),
         sex = factor(sex, levels = sexlevels)) %>%
  filter(treatment != "control") %>%
  pivot_longer(cols = prl:e2t) %>%
  filter(!(name == "cort" & value > 100)) %>%
  drop_na() %>%
  mutate(name = factor(name),
         name=recode(name,  "prl" = "prolactin",
                           "e2t" ="sex steroids",
                     "cort" = "corticosterone",
                     "p4" = "progesterone"),
         name = factor(name, levels = hormonelevels))
hormones2
