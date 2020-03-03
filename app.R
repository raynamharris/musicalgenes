library(shiny)
library(tidyverse)
library(cowplot)
library(sonify)
library(stringr)
library(scales)

options(shiny.maxRequestSize=30*1024^2)

source("./global.R")

### get data

## candidate counts
df <- read_csv("./data/candidatecounts.csv")
#df <- data.table::fread("data/DEGcounts.csv")
df$treatment <- factor(df$treatment, levels = charlevels)
df$tissue <- factor(df$tissue, levels = tissuelevels)


## differentiall expressed gene results
df2 <- read_csv("./data/allDEG.csv")  
df2$tissue <- factor(df2$tissue, levels = tissuelevels)
df2$direction <- factor(df2$direction, levels = charlevels)
df2$comparison <- factor(df2$comparison, levels = comparisonlevels)

## Go terms
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




## get gene ids
gene_names <- df %>% 
  dplyr::distinct(gene) %>% 
  dplyr::arrange(gene) %>% pull()

## ui
ui <- fluidPage(
  
  # Application title
  titlePanel("Exploring gene expression in parental pigeons."),
  
 # titlePanel(title=div(img(src="expdesign.png"))),
  
  # Inputs for boxplot
  sidebarLayout(
    sidebarPanel(
      wellPanel( 
        HTML(paste(h4("Plot gene expression"))),
        HTML(paste("Select a genes, tissues, and sexes to plot from the pull down menu.")),
        selectInput(inputId = "gene",
                    label = "Which gene?",
                    choices = c(gene_names),
                    selected = c("BRCA1"),
                    multiple = FALSE),
        selectInput(inputId = "tissue",
                    label = "Which tissue(s)?",
                    choices = tissuelevels,
                    selected = "pituitary",
                    multiple = TRUE),
        selectInput(inputId = "sex",
                    label = "Which sex(es)?",
                    choices = sexlevels,
                    selected = c("female"),
                    multiple = TRUE)),
      wellPanel( 
        HTML(paste(h4("Play gene expression"), 
          "<i>Note: Not currently working :(</i> 
           Listen to mean value of gene expression over time. 
           Each sound represents the mean value of expression for the 
          gene in each tissue and sex, following the plot from left to right. ")),
        actionButton("play", "Listen"))),
    
  ### main panel
    mainPanel(
      
      tabsetPanel(
        tabPanel("Prolactin & breast cancer",
                 mainPanel(
      
      p("We recently confirmed that prolactin 
        (PRL) gene expression fluctuates throughout parental care 
        in a manner that is consistent with its role in promoting lactation 
        and maintaining parental behaviors.
        Interestingly, we identified about 100 genes whose expression 
        was correlated with PRL,
        including (BRCA1, which is associated with breast cancer).
        Additionally, we identified thousands of genes whose expression 
        changed over 
        the course of parental care.
        Exploring the relationship between PRL and other differentially 
        expressed genes could provide important insights into the `symphony` of 
        gene expression 
        that regulates behavior at the organismal and cellular level."),
      
      p("This application allows you to explore RNA-seq data from a 
        study designed to characterize changes 
        in the hypothalamus, pituitary, and gonads of male and female pigeons 
        (aka Rock Doves) over the course of parental care. Stages sampled 
        include non-breeding, nest-building, egg incuation, 
        and nestling care."),
      tags$img(src = "expdesign.png", width = "100%"),
      
      p(h4("Plot gene expression")),
      
      p("These two graphs provide a mutli-faceted view of the data. 
        Each point represents the expression level of one gene from one sample. 
        The box plots show the mean and standard deviation of gene 
        expression for each parental timepoint. 
        The smoothed line helps convey how gene expression changes over time.
        The default plots shows the relationship between PRL and BRCA1 
        in the female pituitary, 
        but you can compare any differentailly expressed gene to PRL."),
      
      plotOutput("boxPlot", width = "100%"),
      
      p("We used DESeq2 to caluculate differential gene expression 
        between sequential parental timepoints.         
        Our manuscript highlighted significant changes in prolactin (PRL) 
        in the pituitary between control and nest building, 
        incubation days 9 and 17, and between hatch and nestling care day 5. 
        With this tool, you can confirm those observation and 
        explored different genes of interest."),
      
      tableOutput("DEGtable"),
      
      
      p("Here are the median values of gene expression for each group. 
        These can be a useful reference when intrepreting the 
        statistics differences."),
      tableOutput("summaryTable"),
      
      p("Finally, here is a scatter plot showing the correlation between 
        PRL and the gene of interest.
        The default scatter plot shows that BRCA1 is positively 
        correlated with PRL."),
      
      plotOutput("scatterplot"),
      
      tags$a(href="https://github.com/raynamharris/musicalgenes", 
             "Source code available at GitHub @raynamharris/musicalgenes"),
      
      p("To cite this tool, please cite....")
                 )),
  tabPanel("Other",
           h5 ("This is where I could tell another story with data.") )
  ))))







#### server
server <- function(input, output){
  
  output$boxPlot <- renderPlot({
    
    
    reactivedf <- df  %>%
      dplyr::filter(gene %in% c("PRL", input$gene),
                    tissue %in%  input$tissue,
                    sex %in% input$sex) %>%
      drop_na() 
    
      p <- ggplot(reactivedf, aes(x = treatment, y = counts, color = sex)) +
      geom_boxplot(aes(fill = treatment)) + 
      geom_point() +
      geom_smooth(aes(x = as.numeric(treatment))) +
      facet_wrap(tissue~gene, scales = "free_y") + 
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
  
  
  
  output$DEGtable <- renderTable({
    

    df2 %>%
      dplyr::filter(gene %in% c("PRL", input$gene),
                    tissue %in%  input$tissue,
                    sex %in% input$sex) %>%
      mutate(lfcpadj = paste(round(lfc,2), scientific(padj, digits = 3), sep = ", ")) %>%
      select(sex, tissue, comparison, gene, lfcpadj) %>%
      arrange(comparison) %>%
      pivot_wider(names_from = comparison, values_from = lfcpadj)
  
  })
  
  
  output$summaryTable <- renderTable({
    
    reactivedf <- df  %>%
      dplyr::filter(gene %in% c("PRL", input$gene),
                    tissue %in%  input$tissue,
                    sex %in% input$sex) %>%
      drop_na()  %>%
      group_by(sex, tissue, treatment, gene) %>%
      summarize(expression = median(counts)) %>%
      pivot_wider(names_from = gene, values_from = expression)
    reactivedf
  })

  
  output$scatterplot <- renderPlot({
    
    df %>%
      dplyr::filter(gene %in% c("PRL", input$gene),
                    tissue %in%  input$tissue,
                    sex %in% input$sex) %>%
      select(sex:counts)  %>%
      pivot_wider(names_from = gene, values_from = counts) %>%
      ggplot(aes_string(x = "PRL", y = input$gene)) +
      geom_point(aes(color = treatment)) +
      geom_smooth(method = "lm" ,aes(color = sex)) +
      facet_wrap(~tissue, ncol = 1, scales = "free") + 
      theme_classic(base_size = 14) +
      scale_fill_manual(values = allcolors, guide=FALSE) +
      scale_color_manual(values = allcolors)  +
      theme(legend.position = "bottom")
    
  })
  
  
  
}

## shiny
shinyApp(ui = ui, server = server)