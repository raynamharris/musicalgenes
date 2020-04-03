shinyUI(
  fluidPage(
    # Application title
    titlePanel("Musical Genes: a Shiny app for the visualization and sonification of the gene expression during parental care."),

    # titlePanel(title=div(img(src="expdesign.png"))),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        
        wellPanel(
          
          HTML(paste(h4("Transcriptional Symphony"))),
          
          p("Genes work together in concert to regulate behavior. 
            What does this 'transcriptional symphony' sound like?
            This app allows you to interactively visualize and sonify 
            (or plot and play) gene expression
            to better understand the biology of parental care.
            "),
          
          
          selectInput(
            inputId = "gene",
            label = "Which gene?",
            choices = c(gene_names),
            selected = c("BRCA1"),
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
            label = "Which sex?",
            choices = sexlevels,
            selected = c("female", "male"),
            multiple = TRUE
          ), 
          
          
          tags$img(src = "https://codeabbey.github.io/data/chords_of_music.jpg", width = "100%")
          
          
          
          
        ),
        
        
   
        wellPanel(
          
          
          
          HTML(paste(h4("Open source software for reproducible research"))),
          
          
          p("Shiny code:"),
          
          tags$a(
            href = "https://github.com/raynamharris/musicalgenes",
            "@raynamharris/musicalgenes"
          ),
          
          p(" "),
          
          p("Research compendium:"),
          
          tags$a(
            href = "https://macmanes-lab.github.io/DoveParentsRNAseq/",
            "@macmanes-lab/DoveParentsRNAseq"
          )
          )
        
        
        
      ),

      ### main panel
      mainPanel(
        tabsetPanel(
         
          tabPanel(
            "Sonify gene expression",
            fluidRow(
              p(h2("Sonify gene expression")),
              
              tags$img(src = "fig_musicalgenes.png", width = "100%"),
              
    
              p(""),
              
              p("Data sonification is the presentation of data as sound.
                We are sonifying data to illustrate the 
                symphony of gene expression changes that occur 
                during parental care in male and female pigeons. 
                Currently, you can only listen to one gene at a time,
                but we hope to soon play many genes at once.

                "),
              
              p("If you can't hear the sound when you click the button, 
                download the file and play it locally.
                "),
              
              
              actionButton("button", "Listen to the sound of gene expression 
                             during parental care.
                           "),
              
              downloadButton("wav_dln", label = "Download"),
              
              plotOutput("musicplot", width = "80%") ,
              
              p("While listening, you can follow along with this 
              visualization of the data, where  each note represents 
                the mean value of gene expression 
                in a given tissue for female and male
                pigeons across the parental care cycle. 
                "),
              
  
             
              
              p(" Before I built this app, I used a keyboard to play 
                  the sound of prolactin in the female pituitary 
                working in concert other genes to regulate parental care. 
                You can watch that video here and learn a little more about our experiment. 
              In addition to sonifying the data as sound and
                  plotting the data as notes on a scale,
                  we can also convert count to letters
                  (from A to G to AA, with AA being the highest)
                a print them in a table that can be used 
                to aid playing the data any instrument."),
              
              tableOutput("musicalgenes") ,
              
  

            p(" "),
              
              HTML('<iframe width="80%" height = "300px" 
                   src="https://www.youtube.com/embed/PoKiIwIsLSo" 
                   frameborder="0" allow="accelerometer; autoplay; 
                   encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
              
              
              
              
            )
          ),
          
          
          
           tabPanel(
            "Visualize gene expression",
            fluidRow(
              p(h2("Visualize gene expression")),


              tags$img(src = "expdesign.png", width = "100%"),


              p("Prolactin", em("PRL"), "stimulates lacation and parental care. 
               Identifying genes whose expression is correlated with", em("PRL"), 
               "can help us understand what genes work in concert to regulate
                parental care behaviors and other physiological processes.  
               "),


              p("Here, you can interactively compare 
              one of 50 genes-of-interest gene of interest to PRL
              to see if they are correlated. 
        In these graphs, each point represents the expression 
        level of one gene from one sample. 
        The box plots show the mean and standard deviation of gene 
        expression for each parental time point."),
              
              
              p("We recommend selecting", em("BRCA1"), 
                "to view the striking similarity between", em("PRL"),
                "and ", em("BRCA1"), ", a gene that has been implicated in breast cancer.
                Then, go back and listen to", em("BRCA1")),
              
              plotOutput("boxPlot", width = "100%"),
              
              plotOutput("scatterplot"),

              p("Even though it may look and sound like gene expression 
                is changing over time, these changes may or may not be
              statistically significant. The table below shows the 
              log fold change and p-value from `DESeq2` for each
                sequential parental time point comparison (separated by an '_'.) 
                If your gene of interest doesn't appear in the table,
                then it never significantly changed over the parental care cycle."),

              
              
              
              
              tableOutput("DEGtable"),
          
              # p("Here are the median values of gene expression for each group.
              #  These can be a useful reference when interpreting the
              #  statistics differences."),
              # tableOutput("summaryTable"),

              p("Finally, here is a scatter plot showing the linear relationship between 
        PRL and the gene of interest.
        Points are colored by tissue and the line is colored by sex. ")
            
              #verbatimTextOutput("cortestres")
              
              
            )
          ),
          
          
        
          tabPanel(
            "About",
            fluidRow(
              p(h2("About")),
              
              tags$img(src = "fig_thumbnail.png", width = "80%"),
              
              
              
              p("Genes work together in concert to regulate behavior. What does this 'transcriptional symphony' sound like? Data sonification is the presentation of data as sound. Musical Genes is a Shiny app that allows users to interactively visualize and sonify (or plot and play) gene expression to better understand the biology of parental care. The user can choose a gene from this pulldown menu and listen to how it changes over time with the R packages `sonify` and `tuneR`. We also represent the levels of gene expression as notes on a scale that could be played on an instrument like a piano or guitar. Finally, we provide additional visualizations that provide insight into genes that might work in concert to regulate biological processes of biomedical relevance. Exploration of this data could provide additional insights of biological processes that of biomedical relevance all while making beautiful music. "),
              
              
              
              p("This software application is a product of the 'Birds, Brains, and Banter (B3)'
                  Laboratory at the University of California at Davis.
                This and related research is funded by the National Science Foundation,
                in a grant to Rebecca Calisi and Matthew MacManes.
                The software was created and written by Rayna Harris and Rebecca Calisi.  Owen Marshall, Mauricio Vargas, Titus Brown, and Alexandra Colón Rodríguez contributed intellectually to the design. 
                Suzanne Austin, Andrew Lang, Victoria Farrar, April Booth, Tanner Feustel, and Matthew MacManes contributed the experiment that is the foundation of this application."),
              
              
              p(" Watch this high-speed video to see how to 
                interactively explore and listen to the data."),
              
              
              HTML('<iframe width="80%" height = "300px"
                   src="https://www.youtube.com/embed/bQWDiI2oZdI" 
                   frameborder="0" allow="accelerometer; autoplay; 
                   encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')

            )
          )
          
          
        )
      )
    )
  )
)
