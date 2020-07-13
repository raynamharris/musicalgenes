shinyUI(
  fluidPage(
    # Application title
    titlePanel("Musical Genes: Visualize and sonifiy gene expression in parenting pigeons"),

    # titlePanel(title=div(img(src="expdesign.png"))),
  
    
    tags$div(lang="en", class="header"),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        
        wellPanel(
          
          p("A metaphorical 'transcriptional symphony' of genes 
            'working in concert' is thought to regulate behavior. 
            What does this symphony sound like?
            Data sonification is the presentation of data as sound. 
            Here, you can interactively visualize and sonify gene expression 
            to better understand the molecular mechanisms that regulate
            parental care behavior and other important phenotypes."),
            
          selectInput(
            inputId = "gene",
            label = "Pick a gene.",
            choices = c(gene_names),
            selected = c("DRD1"),
            multiple = FALSE
          ),
          
          tableOutput("genename"),
          
          selectInput(
            inputId = "tissue",
            label = "Pick a tissue.",
            choices = tissuelevels,
            selected = "hypothalamus",
            multiple = FALSE
          ),
          
          
          
          selectInput(
            inputId = "sex",
            label = "Chose female or male.",
            choices = sexlevels,
            selected = c("female"),
            multiple = FALSE
          ),
          
          p("The box-and-whisker plot median and range of gene expression at difference stages of reproduction, from building nests and incubating eggs to nurturing baby chicks. The music notes represent the mean for each group and correspond to the tone played in the downloaded .wav file.")
        
        ),
        
        wellPanel(
          
          
          p("Genes that are positively or negatively correlated increase and decrease their expression in syncrony. Genes with positive correlations are often co-regulated by the same transcription factor."),
          
          selectInput(
            inputId = "gene2",
            label = "Pick another gene.",
            choices = c(gene_names),
            selected = c("HTR2C"),
            multiple = FALSE
          ),
          
          tableOutput("genename2")
          
        ),
        
        wellPanel(
          
          HTML(paste(h4("Open source software for reproducible research"))),
          
          
          p("The code for this webpage is", 
            
            tags$a(
              href = "https://github.com/raynamharris/musicalgenes",
              "@raynamharris/musicalgenes"
            )
          ),
          

          
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
              
          h4("Listen"),       

              HTML('<center><img src="fig_musicalgenes.png", width = "100%"></center>'),
              
              plotOutput("boxPlot", width = "100%"),
             
             
          
             actionButton("button", "Sonify the average gene expression value."),
        
             
             downloadButton("wav_dln", label = "Download to play."),
             
             uiOutput("audiotag"),

          p(" "),
          
          p("You can play these notes on the instrument of your choice."),
          
          p(" "),
          
          tableOutput("musicalgenes")),
        
        wellPanel(
          
             h4("Explore"),          
             
             plotOutput("scatterplot", width = "100%"),
          

             
          h4("Learn more"),       
             
             p("Before building this app, used a keyboard to play 
               the sound of genes working together to regulate parental care. 
               You can watch this video to learn more about the inspiration behind this app."),
          

          HTML('<iframe width="80%" height = "300px" 
                  src="https://www.youtube.com/embed/PoKiIwIsLSo" 
               frameborder="0" allow="accelerometer; autoplay; 
               encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
      
          
          h4("Credit"), 
          
          p("This app is a product of the 'Birds, Brains, and Banter (B3)'
               Laboratory at the University of California at Davis.
            This and related research is funded by the National Science Foundation,
            in a grant to Rebecca Calisi and Matthew MacManes.
          The webpage was created and written by Rayna Harris and Rebecca Calisi.  
                Owen Marshall, Mauricio Vargas, Titus Brown, and 
            Alexandra Colón Rodríguez contributed intellectually to the design. 
            Suzanne Austin, Andrew Lang, Victoria Farrar, April Booth, 
            Tanner Feustel, and Matthew MacManes contributed the 
            experiment that is the foundation of this application.")
  
              
             )
          )
          
          
    )
  )
)
