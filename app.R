library(shiny)
library(tidyverse)
library(cowplot)
library(sonify)

options(shiny.maxRequestSize=30*1024^2)

source("./global.R")

### get data

df <- read_csv("./data/candidatecounts.csv")

df2 <- read_csv("./data/allDEG.csv")
df3 <- read_csv("./data/allDEG2.csv")

df2 %>% filter(gene %in% c("PRL")) %>%
  ggplot(aes(x = lfc, y = logpadj, 
             shape = tissue, color = direction,
             label = comparison)) +
  geom_point() +
  geom_text()

df2$tissue <- factor(df2$tissue, levels = tissuelevels)

df2$direction <- factor(df2$direction, levels = charlevels)


df2 %>% filter(gene %in% c( "AVP", "AVPR1A", "BRINP1", "CREBRF", "DBH", "DRD1",
                            "GNAQ", "HUBB", "KALRN", "MBD2", "NPAS1", "NPAS3", 
                            "NR3C1", "OPRK1", "OXT", "OXTR", "PRL", "PREN", "ZFX")) %>%
  ggplot(aes(x = lfc, y = logpadj, 
             shape = tissue, color = direction,
             label = comparison,
             alpha = sex)) +
  geom_point(size = 3) +
  geom_text(size = 3, angle = 45) +
  scale_color_manual(values = allcolors) +
  scale_alpha_manual(values = c(1,0.75)) +
  facet_wrap(~gene) +
  theme_classic() +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "italic")) +
  labs(x = "log fold change (lfc)", y = "log-10 adjusted p-value") +
  geom_vline(xintercept = 0, color = "grey", linetype = "dashed") +
  ylim(-2,12.5) +
  xlim(-3,4)


 parentalbehavior <- read_table("data/GO_term_parentalbehavior.txt")
names(parentalbehavior)[1] <- "allGO"

parentalbehavior$id <- sapply(strsplit(parentalbehavior$allGO,'\t'), "[", 1)
parentalbehavior$gene <- sapply(strsplit(parentalbehavior$allGO,'\t'), "[", 2)
parentalbehavior$name <- sapply(strsplit(parentalbehavior$allGO,'\t'), "[", 3)
parentalbehavior$GO <- sapply(strsplit(parentalbehavior$allGO,'\t'), "[", 6)
parentalbehavior$allGO <- NULL

parentalbehaviorgenes <- parentalbehavior %>% 
  mutate(gene = str_to_upper(gene)) %>%  pull(gene)
parentalbehaviorgenes


df4 <- df2 %>% filter(gene %in% parentalbehaviorgenes) %>%
  select(sex:gene) %>%
  group_by(sex, tissue, gene) %>% 
  summarize(stages = str_c(direction, collapse = " "))  %>%
  pivot_wider(values_from = stages, names_from = gene) 
df4

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
                    selected = c("BRCA1", "MYC"),
                    multiple = TRUE),
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
      
      tags$img(src = "expdesign.png", width = "100%"),
      plotOutput("boxPlot", width = "100%"),
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
      ggplot( aes(x = treatment, y = counts, color = sex)) +
      geom_boxplot(aes(fill = treatment)) + 
      geom_smooth(aes(x = as.numeric(treatment))) +
      facet_grid(tissue~gene) + 
      theme_classic(base_size = 16) +
      scale_fill_manual(values = allcolors, guide=FALSE) +
      scale_color_manual(values = allcolors) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "bottom",
            strip.text.x = element_text(face = "italic")) +
      labs(y = "gene expression", x = NULL)
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