library(shiny)
library(tidyverse)
library(cowplot)
library(sonify)
library(stringr)
library(scales)
library(forcats)

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


tsne <- read_csv("data/tsne.csv")
tsne$tissue <- factor(tsne$tissue, levels = c("hypothalamus", "pituitary", "gonads"))
tsne <- tsne %>% mutate(tissue = fct_recode(tissue, "gonad" = "gonads"))

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
        
        
        HTML(paste("This application allows you to explore RNA-seq data from a 
        study designed to characterize changes 
          in the hypothalamus, pituitary, and gonads of male and female pigeons 
          (aka Rock Doves) over the course of parental care. Stages sampled 
          include non-breeding, nest-building, egg incuation, 
          and nestling care. Select a genes, tissues, and sexes to plot from the pull down menu.")),
        

        HTML(paste(h4("Interactive exploration and analysis of gene expression. "))),
      
        selectInput(inputId = "tissue",
                    label = "Which tissue? Hipothalamus, pituitary or gonads?",
                    choices = tissuelevels,
                    selected = "pituitary",
                    multiple = TRUE),
        selectInput(inputId = "sex",
                    label = "Which sex? Female or male?",
                    choices = sexlevels,
                    selected = c("female"),
                    multiple = TRUE)),
      wellPanel( 
        HTML(paste( h4("Play gene expression"), 
          "<i>Note: Not currently working :(</i> 
           Listen to mean value of gene expression over time. 
           Each sound represents the mean value of expression for the 
          gene in each tissue and sex, following the plot from left to right. ")),
        actionButton("play", "Listen"))),
    
  ### main panel
    mainPanel(
      
      tabsetPanel(
        tabPanel("Prolactin & breast cancer",
                 fluidRow(
       p(h2("Prolactin (PRL) gene expression during parental care and it implication for breast cancer research")),
      
       
       tags$img(src = "expdesign.png", width = "100%"),
       
       
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
      
      
      
    
    
      p("These graphs provide a mutli-faceted view of the data. 
        Each point represents the expression level of one gene from one sample. 
        The box plots show the mean and standard deviation of gene 
        expression for each parental timepoint. 
        The smoothed line helps convey how gene expression changes over time.
        The default plots shows the relationship between PRL and BRCA1 
        in the female pituitary, 
        but you can compare any differentailly expressed gene to PRL."),
      
      selectInput(inputId = "gene",
                  label = "In addition to PRL, which gene do you want to view?",
                  choices = c(gene_names),
                  selected = c("BRCA1"),
                  multiple = FALSE),
      
     

      plotOutput("boxPlot", width = "100%"),
      
      p("We used DESeq2 to caluculate differential gene expression 
        between sequential parental timepoints.         
        Our manuscript highlighted significant changes in prolactin (PRL) 
        in the pituitary between control and nest building, 
        incubation days 9 and 17, and between hatch and nestling care day 5. 
        With this tool, you can confirm those observation and 
        explored different genes of interest."),
      
      tableOutput("DEGtable"),
      
      
     # p("Here are the median values of gene expression for each group. 
      #  These can be a useful reference when intrepreting the 
      #  statistics differences."),
     # tableOutput("summaryTable"),
      
      p("Finally, here is a scatter plot showing the correlation between 
        PRL and the gene of interest.
        The default scatter plot shows that BRCA1 is positively 
        correlated with PRL."),
      
      plotOutput("scatterplot"),
      
      tags$a(href="https://github.com/raynamharris/musicalgenes", 
             "Source code available at GitHub @raynamharris/musicalgenes"),
      
      p("To cite this tool, please cite....")
                 )),
  tabPanel("Internal versus external hypothesis",
           
           
           p(h2("Do internal mechanisms or external stimuli have a larger effect on gene expression?")),
           
           
           tags$img(src = "internalexternal_hypothesis.png", width = "100%"),
           
           
           
           p("In Figure 1, of our manuscript, we show many tSNE plots to give a broad overview of the data. However, zooming in on a few specific timepoints and tissues is useful. Here, we zoom in to show that indeed, samples from the pituitary on incubation day 17 cluster more closely with hatch and nestling care day 5 samples than with incubation days 3 and 9. This suggest that, in the pituitary, internal mechanisms that prepare for chick arrival have the greatest effect on gene expression rather than suggesting that gene expression responds to changes in the external enviornament. You can chose to view more or fewer group using the pull-down menus on the left."),
           
           
           
        
           selectInput(inputId = "treatment",
                       label = "Which parental stage?",
                       choices = charlevels,
                       selected = c("inc.d3", "inc.d9", "inc.d17", "hatch", "n5"),
                       multiple = TRUE),
            plotOutput("tsne"))
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
  
  
  output$tsne <- renderPlot({
    
    tsne %>%
      dplyr::filter( tissue %in%  input$tissue,
                    sex %in% input$sex,
                    treatment %in% input$treatment) %>%
      ggplot(aes(x = V1, y = V2, color = treatment)) +
      geom_point() +
      stat_ellipse() +
      theme_classic(base_size = 14) +
      scale_fill_manual(values = allcolors, guide=FALSE) +
      scale_color_manual(values = allcolors)  +
      theme(legend.position = "none") +
      facet_wrap(tissue~sex, scales = "free")
     
  })
  
  
  
}

## shiny
shinyApp(ui = ui, server = server)