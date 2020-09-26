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
          
          p("Temporaly controlled changes in gene expression 
            are often described as a “transcriptional symphony.” 
              What does these transcriptional symphony of parental 
              care in parenting pigeons sound like?"),
          
            p("Data sonification is the presentation of data as sound. 
            Here, you can interactively visualize and sonify gene expression 
            to better understand the molecular mechanisms that regulate
            parental care behavior and other important phenotypes."),
          
          p("After choosing a gene, tissue and sex, click the 'sonify' 
            button to listen the mean value of gene expression."),
            
          selectInput(
            inputId = "gene",
            label = "Choose a gene.",
            choices = c(gene_names),
            selected = c("PRL: prolactin"),
            multiple = FALSE
          ),
          
          
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
          
          tableOutput("genedescrip"),
          
          
          tableOutput("goterms"),
          
          p("Many genes that are important for regulating reproduction and parental care have also be associated with diseases. Understanding how genes work together to regulate behavior could help us understand how they interact in disease. Below are a list of diseases associated with the gene of interest."),
          
          tableOutput("genedisease"),
          
          p("Descriptions, diseases, and biological processes associated with the human ortholog of the gene of interest are provided by the ",
            tags$a(
              href = "https://www.alliancegenome.org/downloads#gene-descriptions",
              "Alliance of Genome Resources.")
          ),
          
          
          
         p("Don't see your favorite gene?", 
           
           tags$a(
             href = "https://github.com/raynamharris/musicalgenes/issues/new?assignees=&labels=&template=request-a-gene.md&title=Gene+Request",
             "Check here to create a request."
           )
         )
        
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
          plotOutput("musicPlot", width = "100%"),
            
          p(" "),
          
          actionButton("button", "Sonify the average gene expression value."),
          
          downloadButton("wav_dln", label = "Download to play."),
          
          uiOutput("audiotag"),
          
         
          p(" "),
          
          p("In the above image, box and whisker plots illustrate the average and range of data for each group. Stars above the boxes indicate statistically significant changes in gene expression relative to either the nest-building control group or temporal controls. By plotting music notes instead of points, bars or graphs reduces the utility of the data for statistical reasoning but does allow the user to visualize the same pattern that is being used to create a tone via sonification. We can represent an averaged value of gene expression for each group as a music note that can be played by an instrument in an orchestra.")),
        
        wellPanel(  
          
          h4("Future directions"), 
          
          p("In the future, we would like to be able sonify data for multiple genes using sounds from instruments found in an orchestra." ),
          
          tableOutput("orchestratable")
          
          ),
        
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
