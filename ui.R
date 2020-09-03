shinyUI(
  fluidPage(
    
    # Application title
    titlePanel("Musical Genes: Visualize and sonifiy gene expression in parenting pigeons"),

    # titlePanel(title=div(img(src="expdesign.png"))),
  
    tags$head(includeScript("google-analytics.html")),

    tags$div(lang="en", class="header"),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        
        wellPanel(
          
          h4("Transcriptional symphony"), 
          
          p("Temporal and spatially controlled changes in gene expression 
            are often described as a “symphony of gene expression.” 
                What does these transcriptional symphony of parental 
                  care in parenting pigeons sound like?
              Data sonification is the presentation of data as sound. 
            Here, you can interactively visualize and sonify gene expression 
            to better understand the molecular mechanisms that regulate
            parental care behavior and other important phenotypes."),
            
          selectInput(
            inputId = "gene",
            label = "Choose a gene.",
            choices = c(gene_names),
            selected = c("PRL: prolactin"),
            multiple = FALSE
          ),
          
         # tableOutput("genename"),
          
          selectInput(
            inputId = "tissue",
            label = "Choose a tissue.",
            choices = tissuelevels,
            selected = "pituitary",
            multiple = FALSE
          ),
          
          
          
          selectInput(
            inputId = "sex",
            label = "Chose female or male.",
            choices = sexlevels,
            selected = c("female"),
            multiple = FALSE
          ),
          
          p("After choosing a gene, tissue and sex, click the 'sonify' button to listen the mean value of gene expression.")
        
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
              
          h4("Listen to the sound of gene expression changing over time"),      
          
              HTML('<center><img src="fig_musicalgenes.png", width = "100%"></center>'),
              
          
          p(""),
          
              plotOutput("boxPlot", width = "100%"),
             
            

          p(" "),
          
          actionButton("button", "Sonify the average gene expression value."),
          
          
          downloadButton("wav_dln", label = "Download to play."),
          
          uiOutput("audiotag"),
          
          p(" "),
          
          
          
          tableOutput("musicalgenes"),
          
          p(" "),
          
          p("Box and whisker plots illustrate the average and range of data for each group. Stars above the boxes indicate statistically significant changes in gene expression between sequential time points. Plotting music notes instead of points, bars or graphs reduces the utility of the data for statistical reasoning but does allow the user to visualize the same pattern that is being used to create a tone via sonification. We can represent an averaged value of gene expression for each group as a music note that can be played by an instrument in an orchestra.")),
          
        
        
        wellPanel(
          h4("Learn more"),       
             
             p("Before building this app, I used a keyboard to play 
               the sound of genes working together to regulate parental care. 
               You can watch these videos to learn more about the inspiration behind this app."),
          

          HTML('<iframe width="47.5%" height = "200px" 
                  src="https://www.youtube.com/embed/PoKiIwIsLSo" 
               frameborder="0" allow="accelerometer; autoplay; 
               encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
          
          
          
          
         HTML('<iframe width="47.5%" height="200px" 
               src="https://www.youtube.com/embed/ssGuxnD_NCo" 
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
