
plotcandidatecounts <- function(df, whichtstages, 
                                whichsex, whichtissue){
  myylab = paste(whichsex, whichtissue, "gene expression" , sep = " ")
  
  p <- df %>%
    dplyr::filter(treatment %in% whichtstages,
                  tissue %in% whichtissue,
                  sex %in% whichsex) %>%
    ggplot(aes(x = treatment, y = counts, color = sex)) +
    geom_boxplot(aes(fill = treatment)) + 
    geom_smooth(aes(x = as.numeric(treatment)), se = F) +
    facet_wrap(~gene, scales = "free_y") + 
    theme_classic() +
    scale_fill_manual(values = allcolors, guide=FALSE) +
    scale_color_manual(values = allcolors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "bottom",
          #axis.title.x = element_blank(),
          strip.text = element_text(face = "italic")) +
    labs(y = myylab, x = "Parental stages") 
  print(p)
}

df %>% filter(gene %in% c("PRL")) %>%
  plotcandidatecounts(charlevels, "female", "pituitary") 

df %>% filter(gene %in% c("BRCA1" , "PRL", "MYC")) %>%
  plotcandidatecounts(charlevels,  "female", "pituitary") 

### play sounds

sonifycandidatecounts <- function(df, whichgene, whichtissue, whichsex){
  
  medianvalues <- df %>%
    dplyr::filter(gene %in% input$variable,
                  tissue %in% whichtissue,
                  sex %in% whichsex) %>%
    filter(treatment != "NA" ) %>%
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

sonifycandidatecounts(df, "BRCA1","pituitary", "female")
sonifycandidatecounts(df, "MYC","pituitary", "female")
sonifycandidatecounts(df, "PRL","pituitary", "female")

sonifycandidatecounts(df, "BRCA1","hypothalamus", "male")
sonifycandidatecounts(df, "MYC","hypothalamus", "male")
sonifycandidatecounts(df, "PRL","hypothalamus", "male")


