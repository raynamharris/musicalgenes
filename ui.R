shinyUI(
  fluidPage(
    # Application title
    titlePanel("Exploring gene expression in parental pigeons."),

    # titlePanel(title=div(img(src="expdesign.png"))),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        wellPanel(
          HTML(paste(h4("Interactively explore transcriptional changes associated parental care transitions."))),

          HTML(paste("This application allows you to explore RNA-seq data from a 
                     study designed to characterize changes 
                     in the hypothalamus, pituitary, and gonads of male and female pigeons 
                     (aka Rock Doves) over the course of parental care. Stages sampled 
                     include non-breeding, nest-building, egg incuation, 
                     and nestling care. Select tissues, and sexes to plot from the pull down menu.")),

          HTML(paste(h4(" "))),

          selectInput(
            inputId = "tissue",
            label = "Which tissue?",
            choices = tissuelevels,
            selected = "pituitary",
            multiple = TRUE
          ),
          selectInput(
            inputId = "sex",
            label = "Which sex?",
            choices = sexlevels,
            selected = c("female"),
            multiple = TRUE
          )
        ),
        wellPanel(
          HTML(paste(
            h4("Listen to the sound of gene expression changing over time!"),
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
              p(h2("Prolactin (PRL) gene expression during parental 
                   care and it implication for breast cancer research")),


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


              p("These two graphs provide a mutli-faceted view of the data. 
        Each point represents the expression level of one gene from one sample. 
        The box plots show the mean and standard deviation of gene 
        expression for each parental timepoint. 
        The smoothed line helps convey how gene expression changes over time.
        The default plots shows the relationship between PRL and BRCA1 
        in the female pituitary, 
        but you can compare any differentailly expressed gene to PRL."),

              selectInput(
                inputId = "gene",
                label = "Chose a gene to compare to PRL.",
                choices = c(gene_names),
                selected = c("BRCA1"),
                multiple = FALSE
              ),

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
 
              
              #verbatimTextOutput("cortestres"),
                
 
              tags$a(
                href = "https://github.com/raynamharris/musicalgenes",
                "Source code available at GitHub @raynamharris/musicalgenes"
              ),

              p("To cite this tool, please cite....")
            )
          ),
          tabPanel(
            "Internal versus external hypothesis",


            p(h2("Do internal mechanisms or external stimuli have a larger effect on gene expression?")),


            tags$img(src = "internalexternal_hypothesis.png", width = "100%"),



            p("In Figure 1 of our manuscript, we show many tSNE plots to give a broad overview of the data. 
                     However, zooming in on a few specific timepoints and tissues is useful. 
                     Here, we zoom in to show that indeed, samples from the pituitary on 
                     incubation day 17 cluster more closely with hatch and nestling care 
                     day 5 samples than with incubation days 3 and 9. This suggest that, 
                     in the pituitary, internal mechanisms that prepare for chick arrival 
                     have the greatest effect on gene expression rather than suggesting 
                     that gene expression responds to changes in the external enviornament. 
                     You can chose to view more or fewer group using the pull-down menus on the left."),

            selectInput(
              inputId = "treatment",
              label = "Which parental stage?",
              choices = charlevels,
              selected = c("inc.d3", "inc.d9", "inc.d17", "hatch", "n5"),
              multiple = TRUE
            ),
            plotOutput("tsne")
 
          )
        )
      )
    )
  )
)
