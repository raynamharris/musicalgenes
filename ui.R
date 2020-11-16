shinyUI(
  fluidPage(
    
    # Application title
    titlePanel("Musical Genes: Visualize and sonify gene expression"),

    # titlePanel(title=div(img(src="expdesign.png"))),
  
    tags$head(includeScript("google-analytics.html")),

    tags$div(lang="en", class="header"),

    # Inputs for plots
    sidebarLayout(
      sidebarPanel(

          h4("Interactive data exploration"), 
          
          p("Temporally controlled changes in gene expression 
            are often described as a symphony that is regulated by transcription factors. 
            What does this symphony of coordinated changes (or cacophony of 
            discoordinated changes) in gene expression sound like? 
            Data sonification is the presentation of data as sound. 
            Here, you can interactively visualize and sonify gene expression 
            to better understand the molecular mechanisms that regulate
            parental care behavior and other important phenotypes."),
          
          selectInput(
            inputId = "sex",
            label = "Chose female or male.",
            choices = sexlevels,
            selected = c("female"),
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
            inputId = "gene",
            label = "Choose a gene.",
            choices = c(gene_names),
            selected = c("PRL: prolactin"),
            multiple = FALSE
          ),
          
         tableOutput("genedescrip"),
         
         tableOutput("goterms"),
         
         tableOutput("genedisease"),
         
         p("After choosing a gene, tissue and sex, click the 'sonify' 
           button to listen the mean value of gene expression."),
         
         p("Don't see your favorite gene?", 
           
           tags$a(
             href = "https://github.com/raynamharris/musicalgenes/issues/new?assignees=&labels=&template=request-a-gene.md&title=Gene+Request",
             "Request it here."
           )
         ),
         
         
         
         p("The biological processes and diseases associated with the selected 
           gene of interest are provided by the ",
           tags$a(
             href = "https://www.alliancegenome.org/downloads#gene-descriptions",
             "Alliance of Genome Resources.")
         )
          

      ),

      ### main panel
      mainPanel(
        
        tabsetPanel(
          tabPanel("Musical Genes", 
                   
                   h4("Musical Genes"),      
            
          
          plotOutput("boxnmusicplot1", width = "100%"),
          
          actionButton("button1", "Listen to changes in gene expression between 
                       sequential reproductive and parental stages."),
          
          p(""),
          
          plotOutput("boxnmusicplot2", width = "100%"),
          
          actionButton("button2", "Listen to changes in gene expression change 
                       in response to offspring removal."),
          
          p(""),
          
          plotOutput("boxnmusicplot3", width = "100%"),
          
          actionButton("button3", "Listen to changes in gene expression change 
                       in response to offspring replace"),
          
          uiOutput("audiotag"),
          
          p(""),
          
          HTML('<center><img src="expdesign.png", width = "100%"></center>'),
          
          
          p(""),
        
          p("The top panel provides an overview of an experiment 
            designed to characterize the reproductive transcriptome
            of the bi-parental rock dove. 
            The box and whisker plots illustrate the median and range 
            of gene expression for any one of a hundred candidate genes. 
            The music notes to represent the mean for each group.")
        
        ),
        
        
      
        
        tabPanel("Hormonal Symphony" ,
                 
                 h4("Hormonal Symphony"),      
                 
                 
                 
                 plotOutput("hormoneplots"),
                 
                 p("There is an intricate interplay between genes and hormones.
                   Genes directly or indirectly encode hormones and the receptors they bind to,
                   and hormones can module to the expression levels of many genes.
                   Here, we show the correlation pattern between the gene of interest and four hormones
                   (prolactin (prl), corticosterone (cort), progesterone (p4), 
                   and estradiol (e2) in females or testosterone (t) in males." ),
                 
                 
                 p("To better understand the correlation, 
                    these graphs show how the hormones change over time 
                    and in response to manipuation." ),
                 
                 plotOutput("statichormones1"),
                 
                 plotOutput("statichormones2"),
                 
                 plotOutput("statichormones3"),
                 
                 p("As a reminder, here is the experimental design and a graphic description
                   of each treatment," ),
                 
                 HTML('<center><img src="expdesign.png", width = "100%"></center>')
                 
                 ),
      
        
        tabPanel("Transcriptional Symphony" ,
                 
                 h4("Transcriptional Symphony"),    
                 
 
                 
                 p("In the future, we would like to be able sonify data for multiple genes or 
                   hormones simultaneously using sounds from instruments found in an orchestra." ),
                 
                 tableOutput("orchestratable")
                   ),
        
        tabPanel("About" ,
                 
                 h4("About"),    
                 
                 p("Before building this app, I used a keyboard to play
                   the sound of genes working together to regulate parental care. 
                   You can watch these videos to learn more about the inspiration 
                   behind this app."),
                 
                 
                 HTML('<iframe width="75%" height = "400px" 
                      src="https://www.youtube.com/embed/PoKiIwIsLSo" 
                      frameborder="0" allow="accelerometer; autoplay; 
                      encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
                 
                 p("This video tutorial is a little out of date, 
                   but it give you an idea of how to interactively
                   explore this dataset."),
                 
                 HTML('<iframe width="75%" height="400px" 
                      src="https://www.youtube.com/embed/bQWDiI2oZdI" 
                      frameborder="0" allow="accelerometer; autoplay; 
                      encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
                   
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
                 ),
                  
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
)
