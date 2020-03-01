library(shiny)
library(tidyverse)
library(cowplot)
library(sonify)

## setup before

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

#df <- read_csv("./data/candidatecounts.csv")


geneids <- read_csv("./data/00_geneinfo.csv")

vsd_path <- "./data/"   # path to the data
vsd_files <- dir(vsd_path, pattern = "*vsd.csv") # get file names
vsd_pathfiles <- paste0(vsd_path, vsd_files)
vsd_files

allvsd <- vsd_pathfiles %>%
  setNames(nm = .) %>% 
  map_df(~read_csv(.x), .id = "file_name")  %>% 
  dplyr::rename("gene" = "X1") %>% 
  pivot_longer(cols = L.G118_female_gonad_control:y98.o50.x_male_pituitary_inc.d3, 
               names_to = "samples", values_to = "counts") 

## plot data

candidategenes <- c("PRL", "PRLR", "AVPR1B", "MYC",
                    "MAP2KA",   "MSH", "PALB2", "BRCA1")

expdesign <- png::readPNG("www/expdesign.png")
expdesign <- ggdraw() +  draw_image(expdesign, scale = 1)



### get gene names
gene_names <- geneids %>% dplyr::distinct(Name) %>% 
  dplyr::arrange(Name) %>% pull()

## ui
ui <- fluidPage(
  
  # Application title
  titlePanel("Gene expression in parental pigeons"),
  
 # titlePanel(title=div(img(src="expdesign.png"))),
  
  # Sidebar with a slider input for boxplot
  sidebarLayout(
    sidebarPanel(
      wellPanel( 
        HTML(paste(h4("Plot gene expression"))),
        HTML(paste("Select a gene from the pull down menu. 
                   View its expression in one or more tissues or sexes.")),
        selectInput(inputId = "gene",
                    label = "Which gene",
                    choices = c(gene_names),
                    selected = "PRL",
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
    
    df  <- allvsd %>%
      filter(gene %in% input$gene) %>%
      dplyr::mutate(sextissue = sapply(strsplit(file_name, '_vsd.csv'), "[", 1)) %>%
      dplyr::mutate(sextissue = sapply(strsplit(sextissue, './data/'), "[", 2)) %>%
      dplyr::mutate(sex = sapply(strsplit(sextissue, '\\_'), "[", 1),
                    tissue = sapply(strsplit(sextissue, '\\_'), "[", 2),
                    treatment = sapply(strsplit(samples, '\\_'), "[", 4)) %>%
      dplyr::mutate(treatment = sapply(strsplit(treatment, '.NYNO'), "[", 1)) %>%
      dplyr::select(sex, tissue, treatment, gene, samples, counts) %>%
      filter(tissue %in% input$tissue, sex %in% input$sex) 
    
    df$treatment <- factor(df$treatment, levels = charlevels)
    df$tissue <- factor(df$tissue, levels = tissuelevels)
    
    
    p <- df %>% dplyr::filter(gene %in% input$gene ) %>%
      dplyr::filter(treatment %in% charlevels,
                    tissue %in% input$tissue,
                    sex %in% input$sex) %>%
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