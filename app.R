library(shiny)
library(tidyverse)
library(cowplot)
library(sonify)

options(shiny.maxRequestSize=30*1024^2)

source("./global.R")

### get data

df <- read_csv("./data/candidatecounts.csv")


## get gene ids
gene_names <- df %>% 
  dplyr::distinct(gene) %>% 
  dplyr::arrange(gene) %>% pull()

## ui
ui <- fluidPage(
  
  # Application title
  titlePanel("Gene expression in parental pigeons"),
  
 # titlePanel(title=div(img(src="expdesign.png"))),
  
  # Inputs for boxplot
  sidebarLayout(
    sidebarPanel(
      wellPanel( 
        HTML(paste(h4("Plot gene expression"))),
        HTML(paste("Select a gene from the pull down menu. 
                   View its expression in one or more tissues or sexes.")),
        selectInput(inputId = "gene",
                    label = "Which gene",
                    choices = c(gene_names),
                    selected = c("PRL", "PRLR", "BRCA1"),
                    multiple = FALSE),
        selectInput(inputId = "tissue",
                    label = "Which tissue(s)?",
                    choices = tissuelevels,
                    selected = "pituitary",
                    multiple = TRUE),
        selectInput(inputId = "sex",
                    label = "Which sex(es)?",
                    choices = sexlevels,
                    selected = "female",
                    multiple = TRUE)
      ),
      wellPanel( 
        HTML(
          paste(h4("Play gene expression"), 
          "Listen to mean value of gene expression over time. 
                Each sound represents the mean value of expression for the 
          gene in each tissue and sex, following the plot from left to right. <i>Note: Prototype limited to PRL in female pituitary.</i> "
          )
        ),
        actionButton("play", "Listen")
      )),
    
    # boxplot
    mainPanel(
      
      tags$img(src = "expdesign.png", width = "500px"),
      plotOutput("boxPlot", width = "500px"),
      p("Note: Plots may take a few seconds to load. Thanks for your patience."),
      tags$a(href="https://github.com/raynamharris/musicalgenes", "Source code available at GitHub @raynamharris/musicalgenes")
    )
  )
  
)

## server
server <- function(input, output){
  
  output$boxPlot <- renderPlot({
    
    df$treatment <- factor(df$treatment, levels = charlevels)
    df$tissue <- factor(df$tissue, levels = tissuelevels)
    
    
    p <- df  %>%
      dplyr::filter(gene %in% input$gene,
                    tissue %in%  input$tissue,
                    sex %in% input$sex) %>%
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts, color = sex)) +
      geom_boxplot(aes(fill = treatment)) + 
      facet_grid(tissue~gene, scales = "free_y") + 
      theme_classic(base_size = 16) +
      scale_fill_manual(values = allcolors, guide=FALSE) +
      scale_color_manual(values = allcolors) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "bottom",
            strip.text.x = element_text(face = "italic")) +
      labs(y = "gene expression")
    p
  })
  
  observeEvent(input$play, {
    insertUI(selector = "#play",
             where = "afterEnd",
             ui = tags$audio(src = "PRLfemalepituitary.mp3", 
                             type = "audio/mp3", 
                             autoplay = NA, controls = NA,
                             style="display:none;")  
    )
  })
  
}

## shiny
shinyApp(ui = ui, server = server)