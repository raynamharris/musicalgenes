shinyUI(
  fluidPage(
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
          
          
          HTML(paste(h4("Plot gene expression"))),
          selectInput(
            inputId = "gene",
            label = "Which gene?",
            choices = c(gene_names),
            selected = c("BRCA1"),
            multiple = FALSE
          ),
          selectInput(
            inputId = "tissue",
            label = "Which tissue(s)?",
            choices = tissuelevels,
            selected = "pituitary",
            multiple = TRUE
          ),
          selectInput(
            inputId = "sex",
            label = "Which sex(es)?",
            choices = sexlevels,
            selected = c("female"),
            multiple = TRUE
          )
        ),
        wellPanel(
          HTML(paste(
            h4("Play gene expression"),
            "<i>Note: Not currently working :(</i> 
           Listen to mean value of gene expression over time. 
           Each sound represents the mean value of expression for the 
          gene in each tissue and sex, following the plot from left to right. "
          )),
          actionButton("play", "Listen")
        )
      ),
      
      ### main panel
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Prolactin & breast cancer",
            fluidRow(
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
              
              
              # p("Here are the median values of gene expression for each group.
              #  These can be a useful reference when intrepreting the
              #  statistics differences."),
              # tableOutput("summaryTable"),
              
              p("Finally, here is a scatter plot showing the correlation between 
        PRL and the gene of interest.
        The default scatter plot shows that BRCA1 is positively 
        correlated with PRL."),
              
              plotOutput("scatterplot"),
              
              tags$a(
                href = "https://github.com/raynamharris/musicalgenes",
                "Source code available at GitHub @raynamharris/musicalgenes"
              ),
              
              p("To cite this tool, please cite....")
            )
          ),
          tabPanel(
            "Other",
            h5("This is where I could tell another story with data.")
          )
        )
      )
    )
  )
)
