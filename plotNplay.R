library(tidyverse)
library(sonify)

### setup themes
charlevels <- c("control", "bldg", 
                "lay", "inc.d3", "inc.d9", "inc.d17", 
                "hatch", "n5", "n9")
sexlevels <- c("female", "male")
tissuelevels <- c("hypothalamus", "pituitary", "gonad")

colorschar <-  c("control" = "#cc4c02", 
                 "bldg"= "#fe9929", 
                 "lay"= "#fed98e", 
                 "inc.d3"= "#78c679", 
                 "inc.d9"= "#31a354", 
                 "inc.d17"= "#006837", 
                 "hatch"= "#08519c",
                 "n5"= "#3182bd", 
                 "n9"= "#6baed6")
sexcolors <- c("female" = "#969696", "male" = "#525252")
colorstissue <- c("hypothalamus" = "#d95f02",
                  "pituitary" = "#1b9e77",
                  "gonads" =  "#7570b3")
allcolors <- c(colorschar, sexcolors, colorstissue)

### get data

df <- read_csv("./candidatecounts.csv")
df$treatment <- factor(df$treatment, levels = charlevels)
df$tissue <- factor(df$tissue, levels = tissuelevels)


## plot data

candidategenes <- calisigenes <- c("PRL", "PRLR", "AVPR1B", "MYC",
                                   "MAP2KA",   "MSH", "PALB2", "BRCA1")

plotcandidatecounts <- function(df, whichtstages, whichsex, whichtissue){
  
  myylab = paste(whichtissue, "gene expression" , sep = "")
  
  p <- df %>%
    dplyr::filter(treatment %in% whichtstages,
                  tissue %in% whichtissue,
                  sex %in% whichsex) %>%
    ggplot(aes(x = treatment, y = counts, fill = treatment, color = sex)) +
    geom_boxplot() + facet_wrap(~gene, scales = "free_y") + 
    theme_classic() +
    scale_fill_manual(values = allcolors) +
    scale_color_manual(values = allcolors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "none",
          #axis.title.x = element_blank(),
          strip.text = element_text(face = "italic")) +
    labs(y = myylab, x = "Parental stages") 
  print(p)
}

plotcandidatecounts(df, charlevels, "female", "pituitary") 
plotcandidatecounts(df, charlevels, "male", "pituitary") 

### play sounds

sonifycandidatecounts <- function(df, whichgene, whichtissue, whichsex){
  
  medianvalues <- df %>%
    dplyr::filter(gene %in% whichgene,
                  tissue %in% whichtissue,
                  sex %in% whichsex) %>%
    group_by(treatment, sex, tissue) %>%
    summarize(median = median(counts, na.rm = TRUE),
              sdev = sd(counts, na.rm = TRUE)) %>%
    arrange(tissue,sex,treatment)  %>%
    filter(treatment != "NA" )
  
  sonification <- sonify(x = medianvalues$median,
                         interpolation = "constant")
  print(medianvalues)
  return(sonification)
}

sonifycandidatecounts(df, "AVPR1B","pituitary", "female")
sonifycandidatecounts(df, "BRCA1","pituitary", "female")
sonifycandidatecounts(df, "MYC","pituitary", "female")
sonifycandidatecounts(df, "PALB2","pituitary", "female")
sonifycandidatecounts(df, "PRL","pituitary", "female")
sonifycandidatecounts(df, "PRLR","pituitary", "female")

sonifycandidatecounts(df, "AVPR1B","pituitary", "male")
sonifycandidatecounts(df, "BRCA1","pituitary", "male")
sonifycandidatecounts(df, "MYC","pituitary", "male")
sonifycandidatecounts(df, "PALB2","pituitary", "male")
sonifycandidatecounts(df, "PRL","pituitary", "male")
sonifycandidatecounts(df, "PRLR","pituitary", "male")
