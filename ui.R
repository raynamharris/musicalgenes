shinyUI(
  fluidPage(
    # Application title
    titlePanel("Exploring gene expression in parental pigeons"),

    # titlePanel(title=div(img(src="expdesign.png"))),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        
        wellPanel(
          
          HTML(paste(h4("Transcriptional Symphony"))),
          
          p("Genes work together in concert to regulate behavior. 
            Wouldn't it be great if we could listen to this transcriptional symphony?
            In the video below, I play the sounds of prolactin during parental care on a keyboard.
            "),
          
          HTML('<iframe width="100%" height = "220px"  src="https://www.youtube.com/embed/PoKiIwIsLSo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
          
        ),
        
        wellPanel(
          HTML(paste(h4("Interactively explore the data"))),

          HTML(paste("This application allows you to explore RNA-seq data from a 
                     study designed to characterize changes 
                     in the hypothalamus, pituitary, and gonads of male and female pigeons 
                     (aka Rock Doves) during parental care. Stages sampled 
                     include non-breeding, nest-building, egg incubation, 
                     and nestling care. Select tissues, and sexes to plot
                     from the pulldown menu.")),

          HTML(paste(h4(" "))),
          
          selectInput(
            inputId = "gene",
            label = "Which gene?",
            choices = c(gene_names),
            selected = c("PRL"),
            multiple = FALSE
          ),
          
          tableOutput("genename"),

          selectInput(
            inputId = "tissue",
            label = "Which tissue?",
            choices = tissuelevels,
            selected = "pituitary",
            multiple = FALSE
          ),
          
         
          
          selectInput(
            inputId = "sex",
            label = "Chose one or both sexes to vizualize.",
            choices = sexlevels,
            selected = c("female", "male"),
            multiple = TRUE
          )
        ),
        
        
   
        wellPanel(
          
          
          HTML(paste(h4("Data availability"))),
          
          tags$a(
            href = "https://github.com/raynamharris/musicalgenes",
            "Source code available at GitHub @raynamharris/musicalgenes."
          ),
          
          p(""),
          
          tags$a(
            href = "https://macmanes-lab.github.io/DoveParentsRNAseq/",
            "Source data available at GitHub @macmanes-lab/DoveParentsRNAseq."
          )
        
          
          
          )
        
        
        
      ),

      ### main panel
      mainPanel(
        tabsetPanel(
         
          tabPanel(
            "Musical genes",
            fluidRow(
              p(h2("Musical genes: from data to sounds")),
              
              tags$img(src = "fig_musicalgenes.png", width = "100%"),
              
    
              p(""),
              
              p("On this tab of the Shiny app, you can generate the sounds interactively using R.
                We are working towards creating a 
                'symphony of gene expression over the course of parental care' using data, 
                but for now, you can only listen to one gene at a time. 
                In the image below, each note represents the mean value of gene expression 
                in a given tissue (can be changed) for female and male
                pigeons across the parental care cycle. "),
              
              p("If you can't hear the sound when you click the button, 
                download the file and play it locally.
                "),
              
              actionButton("button", "Listen to the sound of one gene 
                             during parental care in females then males.
                           "),
              
              downloadButton("wav_dln", label = "Download"),
              
              plotOutput("musicplot", width = "80%") ,
              
              
              
              
              p("Alternatlively, the notes can be printed as notes on a scale 
                  (from A to G to AA, with AA being the highest)."),
              
              tableOutput("musicalgenes") 
              
            )
          ),
          
          
          
           tabPanel(
            "Data-driven discovery",
            fluidRow(
              p(h2("Prolactin: Does is promote lacation and breast cancer?")),


              tags$img(src = "expdesign.png", width = "100%"),


              p("We recently confirmed that prolactin 
                (PRL) gene expression fluctuates throughout parental care 
                in a manner that is consistent with its role in promoting lactation 
                and maintaining parental behaviors.
                Using a data-driven approach, we identified about 100 genes whose expression 
                was correlated with PRL,
                including (BRCA1, which is associated with breast cancer).
           Exploring the relationship between PRL and other differentially 
                expressed genes could provide important insights into the 'symphony' of 
                gene expression 
                that regulates behavior at the organismal and cellular level."),


              p("The graph(s) provide a multi-faceted view of the data. 
        Each point represents the expression level of one gene from one sample. 
        The box plots show the mean and standard deviation of gene 
        expression for each parental time point. 
        The smoothed line helps convey how gene expression changes over time. "),
              
              
              p("The default plot shows the relationship between PRL 
                and whatever gene is selected from the pull-down menu. 
                Click 'BRCA1' to view the similarities and differences between
                BRCA1 and PRL."),

        
              
              
              plotOutput("boxPlot", width = "100%"),

              p("We used DESeq2 to caluculate differential gene expression 
        between sequential parental time points.         
        This table provides the log fold change and the p-value for 
                significantly changes between time points, separated by an '_'.
                If your gene of interest doesn't appear in the table,
                then it never significantly changed over the parental care cycle."),

              
              tableOutput("DEGtable"),
          
              # p("Here are the median values of gene expression for each group.
              #  These can be a useful reference when interpreting the
              #  statistics differences."),
              # tableOutput("summaryTable"),

              p("Finally, here is a scatter plot showing the linear relationship between 
        PRL and the gene of interest.
        Points are colored by tissue and the line is colored by sex. "),
              
              #verbatimTextOutput("cortestres"),

              plotOutput("scatterplot")
            )
          ),
          
          tabPanel(
            "Hypothesis-driven discovery",


            p(h2("Do internal mechanisms or external stimuli 
                 have a larger effect on gene expression?")),


            tags$img(src = "internalexternal_hypothesis.png", width = "100%"),

            p("Ultimately, our goal is to understand how internal mechanisms 
              (like a physiological clock) and external stimuli (the arrival of offspring)
              alter gene expression. Does the body prepare for parenthood or does it react to parenthood?"),

            p("t-Distributed Stochastic Neighbor Embedding (t-SNE) 
               is a technique for dimensionality reduction that is well suited 
               for the visualization of high-dimensional datasets.
               Samples that cluster together are similar in expression. 
               In the pituitary, we see that samples from incubation day and hatch cluster together,
               and we see samples from lay and incubation days 3 and 9 cluster.
               This suggests that internal mechanisms that prepare for chick arrival 
               have a greater effect on gene expression than changes in the external enviornment. 
               "),

            selectInput(
              inputId = "treatment",
              label = "Which parental stage?",
              choices = charlevels,
              selected = c("inc.d3", "inc.d9", "inc.d17", "hatch", "n5"),
              multiple = TRUE
            ),
            
            plotOutput("tsne"),
            
            p("If we look at the total number of differentially expressed genes that are different 
              between each sequential stage, we see additional evidence that that 
              gene expression in the pituitary on
              incubation day 17 and hatch are highly similar, suggesting that internal cues
              have a greater effect on gene expression than external stimuli.
              "),
            
            plotOutput("barplot") ,
            
            p("Finally, if we compare the number of genes that are differentially expressed
              between samples that are groupd by either their external environment 
              or their internal levels of prolactin (PRL) in the pitutiary, 
              we see that thousands of genes are differentially expressed between
              samples with low or high levels of PRL.
              "),
            
            tags$img(src = "fig3-1.png", width = "100%")
 
          ),
          
        
          tabPanel(
            "About",
            fluidRow(
              
              tags$img(src = "fig2_thumbnail.png", width = "100%"),
              
              
              
              
              
                
                HTML(paste(h4("Acknowledgments"))),
                
                
                p("This software application is a product of the 'Birds, Brains, and Banter (B3)'
                  Laboratory at the University of California at Davis.
                  This and related research is funded by the National Science Foundation,
                  in a grant to Rebecca Calisi and Matthew MacManes.
                  The software was written by Rayna Harris, 
                with Shiny assistance from Mauricio Vargas and Picasso.
                  Suzanne Austin, Andrew Lang, Victoria Farrar, April Booth, Tanner Feustel, and Rechelle Viernes 
                  contritubed to data collection, analysis, and interpretation.
                  Owen Marshall helped develop the musical gene avenue.")
                
               
              
              
            )
          )
          
          
        )
      )
    )
  )
)
