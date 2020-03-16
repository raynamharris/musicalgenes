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
            inputId = "gene",
            label = "Which gene?",
            choices = c(gene_names),
            selected = c("PRL"),
            multiple = FALSE
          ),
          

          selectInput(
            inputId = "tissue",
            label = "Which tissue?",
            choices = tissuelevels,
            selected = "pituitary",
            multiple = FALSE
          )
        ),
        wellPanel(
          actionButton("play", 
                       HTML("Listen to the sound of prolactin
                       <br/> in the female pituitary.")
                       ),
          
          p(""),
          p("Note: this only works if you run the app locally :(
            However, when it does work, it plays the mean
            mean value of gene expression over time for male and female pigeons. 
            This sound clip was made with the R package `sonify`.")
        )
      ),

      ### main panel
      mainPanel(
        tabsetPanel(
         
          tabPanel(
            "Musical genes",
            fluidRow(
              p(h2("Musical genes: from data to sounds")),
              
              tags$img(src = "musicalgenes.png", width = "100%"),
              
    
              p(""),
              p("Genes do not exert their actions alone; 
                they work in concert with other genes.
                We are working towards creating a 
                `symphony of gene expression over the course of parental care` using data!
                We often create figures and tables with R, 
                but we an also use R to genearte sound!
                This is one step towards making data science
                accessible to those with diminished eyesight.
                Here, each notes represents the mean value of gene expression 
                in a given tissue (can be changed) for female and male
                pigeons across the parental care cycle. "),
              
            
              tableOutput("genename"),
              
              plotOutput("musicplot", width = "100%") ,
              
              p("Alternatlively, the notes can be printed as notes on a scale 
                  (from A to G to AA, with AA being the highest)."),
              
              tableOutput("musicalgenes") ,
              
              p("Click the next tab for alternative vizualizations.")
              
            )
          ),
          
          
          
           tabPanel(
            "Prolactin: lactaction and cancer?",
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
                inputId = "sex",
                label = "Chose one or both sexes to vizualize.",
                choices = sexlevels,
                selected = c("female", "male"),
                multiple = TRUE
              ),

              plotOutput("boxPlot", width = "100%"),

              p("We used DESeq2 to caluculate differential gene expression 
        between sequential parental timepoints.         
        Our manuscript highlighted significant changes in prolactin (PRL) 
        in the pituitary between control and nest building, 
        incubation days 9 and 17, and between hatch and nestling care day 5. 
        With this tool, you can confirm those observation and 
        explored different genes of interest."),

              tableOutput("genename"),
              
            


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


            p(h2("Do internal mechanisms or external stimuli 
                 have a larger effect on gene expression?")),


            tags$img(src = "internalexternal_hypothesis.png", width = "100%"),



            p("t-Distributed Stochastic Neighbor Embedding (t-SNE) 
               is a technique for dimensionality reduction that is well suited 
               for the visualization of high-dimensional datasets.
               Samples that custer together are similar in expression. 
               In the pituitary, we see that samples from incubation day and hatch cluster,
               and we see samples from lay and incubation days 3 and 9 cluster.
               This suggests that internal mechanisms which prepare for chick arrival 
               have a greater effect on gene expression than changes in the external enviornament. 
               "),

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
