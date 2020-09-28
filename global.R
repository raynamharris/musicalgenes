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
library(RSQLite)
library(dbplyr)

library(ggplot2)
library(ggimage)
library(cowplot)
library(magick)

library(ggpubr)
library(readr)

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
hugo <- read.csv("data/hugo.csv") %>% 
  dplyr::distinct(gene, name) %>% 
  mutate(gene_name = paste(gene, name, sep = ": ")) 
head(hugo)

disease <- read_tsv("data/DISEASE-ALLIANCE_HUMAN_29.tsv",
                    skip = 19, col_names = F) %>%
  distinct(X5,X8) %>%
  rename(gene = X5, disease = X8) %>%
  arrange(gene, disease) %>%
  group_by(gene) %>%
  summarize(Diseases = str_c(disease, collapse = "; ")) %>%
  full_join(hugo,., by = "gene") 
head(disease)

description <- read_tsv("data/GENE-DESCRIPTION-TSV_HUMAN_18.tsv",
                        skip = 14, col_names = F) %>%
  rename(GO = X1, gene = X2, Description = X3) %>%
  full_join(., disease, by = "gene") %>%
  mutate(Description = replace_na(Description, 
                                  "Not currrently available."),
         Diseases = replace_na(Diseases, 
                               "Not a marker for any known diseases."))
head(description)

# GO terms

goterms <- read_tsv("data/go_terms.mgi", col_names = F) %>%
  filter(X1 == "Biological Process") %>%
  select(X2, X3) %>%
  rename(GOid = X2, GOterm = X3) 
head(goterms)

# genes associated with bilogical process (BP) GO terms 
bpgo <- read_tsv("data/gene_association.mgi",
                   skip = 24, col_names = F) %>%
  select(X3, X9, X5) %>%
  rename(gene = X3, ontology = X9, GOid = X5) %>%
  filter(ontology == "P") %>%
  full_join(., goterms, by = "GOid") %>%
  mutate(gene = toupper(gene)) %>%
  left_join(hugo, ., by = "gene")  %>%
  distinct(gene, name, gene_name, GOterm) %>%
  arrange(GOterm, gene, gene_name) %>%
  group_by(gene_name) %>%
  summarize(GOterms = str_c(GOterm, collapse = "; ")) 
tail(bpgo)






# data ----

## SQLite Pool Connection
con <- dbConnect(SQLite(), "data/musicalgenes.sqlite")

## candidate counts and differentiall expressed gene results

#candidatecounts <- tbl(con, "candidatecounts") %>%
#  as_tibble(.) %>%
#  left_join(., hugo, by = "gene") 

# data from https://github.com/macmanes-lab/DoveParentsRNAseq
candidatecounts <- read_csv("./data/candidatecounts.csv") %>%
  mutate(
    treatment = factor(treatment, levels = alllevels),
    tissue = factor(tissue, levels = tissuelevels)
  ) %>%
  filter(treatment %in% alllevels) %>%
  na.omit() %>%
  left_join(., description, by = "gene") 
head(candidatecounts)


## all differentially expressed genes (degs)

#alldeg <- tbl(con, "alldeg")
alldeg <- read_csv("www/alldeg.csv") %>%
  left_join(., hugo) %>%
  mutate(reference = sapply(strsplit(as.character(comparison), '\\_'), "[", 1),
         treatment = sapply(strsplit(as.character(comparison), '\\_'), "[", 2)) %>%
  select(sex, tissue, comparison, gene, gene_name, 
         reference, treatment, lfc, padj, posneg) %>%
  filter(comparison  %in% 
           c("control_bldg", "bldg_lay",  "bldg_inc.d3",  
             "bldg_inc.d9",   "bldg_inc.d17",  
             "bldg_hatch", "bldg_n5", "bldg_n9",
             "bldg_lay",  "lay_inc.d3",  
             "inc.d3_inc.d9",   "inc.d9_inc.d17",  
             "inc.d17_hatch", "hatch_n5", "n5_n9",
             "inc.d3_m.inc.d3", "inc.d9_m.inc.d9",
             "inc.d17_m.inc.d17",  "hatch_m.n2" ,
             "inc.d9_early","inc.d17_prolong", "hatch_early",
             "hatch_prolong", "hatch_extend")
           ) 


## Go terms associated with parental care
parentalbehavior <- tbl(con, "parentalbehavior")

parentalbehaviorgenes <- parentalbehavior %>%
  mutate(gene = toupper(gene)) %>%
  pull(gene)

## tsne data

tsne <- tbl(con, "tsne")

## get gene ids
gene_names <- candidatecounts %>%
  drop_na() %>%
  dplyr::distinct(gene_name) %>%
  dplyr::arrange(gene_name) %>%
  pull()
gene_names

gene_names2 <- candidatecounts %>%
  drop_na() %>%
  dplyr::distinct(gene_name) %>%
  dplyr::arrange(gene_name) %>%
  pull()

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
orchestra
