shinyUI(
  fluidPage(
    # Application title
    titlePanel("Musical Genes: Visualizing and sonifiying gene expression in parenting pigeons"),

    # titlePanel(title=div(img(src="expdesign.png"))),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        
        wellPanel(
          
          p("Prolactin", em("(PRL)"), "works in concert with other genes 
            to regulate lactation and parental behavior. 
            What does this 'transcriptional symphony' sound like?
            Interactively visualize and sonify gene expression from parenting pigeons
            to better understand the biology of parental care and 
            make beautiful music."),
          
          
          selectInput(
            inputId = "gene",
            label = "Pick a gene to compare to prolactin.",
            choices = c(gene_names),
            selected = c("BRCA1"),
            multiple = FALSE
          ),
          
          tableOutput("genename"),
          
          selectInput(
            inputId = "tissue",
            label = "Pick a tissue.",
            choices = tissuelevels,
            selected = "pituitary",
            multiple = FALSE
          ),
          
          
          
          selectInput(
            inputId = "sex",
            label = "Pick a sex.",
            choices = sexlevels,
            selected = c("female", "male"),
            multiple = TRUE
          ),
          
          # actionButton("button", "Sonify gene expression."),
          
          p("To listen average value of gene each group, click download."),
          
          downloadButton("wav_dln", label = "Download")
          
        ),
        
        wellPanel(
          
          HTML(paste(h4("Open source software for reproducible research"))),
          
          
          p("The code for this webpage is", 
          
            tags$a(
              href = "https://github.com/raynamharris/musicalgenes",
              "@raynamharris/musicalgenes"
            )
            ),
          
          
          p(" "),
          
          p("The data and code (or research compendium) behind the science are",
            
            tags$a(
              href = "https://macmanes-lab.github.io/DoveParentsRNAseq/",
              "@macmanes-lab/DoveParentsRNAseq"
              
              )
          )
          )
      
        
      ),

      ### main panel
      mainPanel(
        
        wellPanel(
              

              HTML('<center><img src="expdesign.png", width = "75%"></center>'),
              
              plotOutput("boxPlot", width = "100%"),
              
              p(""),
              
              
              
             # HTML('<center><img src="fig_musicalgenes.png", width = "75%"></center>'),
 
              p(""),
             
             
             
             p("Data sonification is the presentation of data as sound. 
              'Musical Genes' is a Shiny app that allows users to interactively 
                visualize and sonify (or plot and play) gene expression to better 
                understand the 'transcrptional symphony' that regulates parental care. 
                The user can choose a gene from this pulldown menu and 
                listen to how it changes over time with the R packages `sonify` and `tuneR`.
The boxplots above show variation in gene expression over time. 
                "),
             
             
             
             p("This tool is a product of the 'Birds, Brains, and Banter (B3)'
               Laboratory at the University of California at Davis.
               This and related research is funded by the National Science Foundation,
               in a grant to Rebecca Calisi and Matthew MacManes.
               The webpage was created and written by Rayna Harris and Rebecca Calisi.  
                Owen Marshall, Mauricio Vargas, Titus Brown, and 
                  Alexandra Colón Rodríguez contributed intellectually to the design. 
               Suzanne Austin, Andrew Lang, Victoria Farrar, April Booth, 
                Tanner Feustel, and Matthew MacManes contributed the 
               experiment that is the foundation of this application."),
             
             
             HTML(paste(h4("Parental care on piano"))),
             
             
             
             p(" "),
            
            p("I also use a keyboard to play 
               the sound of prolactin in the female pituitary 
              working in concert other genes to regulate parental care. 
              You can watch that video here and learn more about our experiments."),
             
             HTML('<iframe width="80%" height = "300px" 
                  src="https://www.youtube.com/embed/PoKiIwIsLSo" 
                  frameborder="0" allow="accelerometer; autoplay; 
                  encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
             
             
             p("")
              
             )
          )
          
          
    )
  )
)
