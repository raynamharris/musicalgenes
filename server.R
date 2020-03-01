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
library(cowplot)
library(sonify)


### setup themes
# experimental levels
charlevels <- c("control", "bldg", 
                "lay", "inc.d3", "inc.d9", "inc.d17", 
                "hatch", "n5", "n9")
sexlevels <- c("female", "male")
tissuelevels <- c("hypothalamus", "pituitary", "gonad")

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
colorstissue <- c("hypothalamus" = "#d95f02",
                  "pituitary" = "#1b9e77",
                  "gonads" =  "#7570b3")
allcolors <- c(colorschar, colorssex, colorstissue)

### get data

df <- read_csv("./data/candidatecounts.csv")
df$treatment <- factor(df$treatment, levels = charlevels)
df$tissue <- factor(df$tissue, levels = tissuelevels)

## plot data

candidategenes <- c("PRL", "PRLR", "AVPR1B", "MYC",
                    "MAP2KA",   "MSH", "PALB2", "BRCA1")

expdesign <- png::readPNG("./data/expdesign.png")
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
  
  observeEvent(input$play, {
    insertUI(selector = "#play",
             where = "afterEnd",
             ui = tags$audio(src = "PRLfemalepituitary.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")  
    )
  })
  
  
})


