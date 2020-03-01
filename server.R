#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(sonify)
library(cowplot)

### setup themes
source("themes.R")

### get data

df <- read_csv("./candidatecounts.csv")
df$treatment <- factor(df$treatment, levels = charlevels)
df$tissue <- factor(df$tissue, levels = tissuelevels)

## plot data

candidategenes <- c("PRL", "PRLR", "AVPR1B", "MYC",
                    "MAP2KA",   "MSH", "PALB2",
                    "BRCA1")

expdesign <- png::readPNG("../DoveParentsRNAseq/figures/images/fig1a_fig1a.png")
expdesign <- ggdraw() +  draw_image(expdesign, scale = 1)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$boxPlot <- renderPlot({
    
     p <- df %>% dplyr::filter(gene %in% input$variable ) %>%
        dplyr::filter(treatment %in% charlevels,
                      tissue %in% tissuelevels,
                      sex %in% sexlevels) %>%
        ggplot(aes(x = treatment, y = counts, color = sex)) +
        geom_boxplot(aes(fill = treatment)) + 
        geom_smooth(method = 'loess', 
                    aes(x = as.numeric(treatment)), se = F) +
      #geom_jitter() +
        facet_grid(tissue~gene, scales = "free_y") + 
        theme_classic(base_size = 16) +
        scale_fill_manual(values = allcolors, guide=FALSE) +
        scale_color_manual(values = allcolors) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1),
              legend.position = "bottom",
              strip.text.x = element_text(face = "italic")) +
      labs(y = "variance stabilized expression")
    plot_grid(expdesign, p, nrow = 2,  rel_heights = c(0.25,1))

  })
  
})


