shinyUI(
  fluidPage(
    
    # Application title
    titlePanel("Interactively explore the transcriptional symphony of parental care in pigeons"),


    tags$head(includeScript("google-analytics.html")),

    tags$div(lang="en", class="header"),

    # Inputs for plots
    sidebarLayout(
      sidebarPanel(

        h4("Musical Genes"),   
          
          p("Temporally controlled changes in gene expression 
            are often described as a metaphoical symphony that is regulated by transcription factors. 
            What does this symphony of coordinated changes in gene expression sound like? 
            Data sonification is the presentation of data as sound. 
            Musical Genes is an app that allows user to interactively visualize and sonify gene expression 
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
        
        selectInput(
          inputId = "hormone",
          label = "Chose a hormone",
          choices = hormonelevels,
          selected = c("prolactin"),
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
          tabPanel("Transcriptional symphony", 
                   
                   h4("Transcriptional symphony"),   
                   
                   HTML('<center><img src="expdesign.png", width = "100%"></center>'),
                   
                   
          
          plotOutput("boxnmusicplot1", width = "100%"),
          
          
          
          actionButton("button1", "Listen to changes in gene expression between 
                       sequential reproductive and parental stages."),
          
        
          
          p(""), 
          
          tableOutput("orchestratable"),
          
          
          
          p("The top panel provides an overview of an experiment 
            designed to characterize the reproductive transcriptome
            of the bi-parental rock dove. 
            The box and whisker plots illustrate the median and range 
            of gene expression for any one of a hundred candidate genes. 
            The music notes to represent the mean for each group.
            In the future, I would really like to sonify data for multiple genes
             simultaneously using sounds from instruments found in an orchestra.
            I haven't figured out how to do this in R, 
            but here are some notes that can be played on your instrument of choice." )
        
         
          
          
        ),
                 
        
        tabPanel("Genes and hormones" ,
                 
                 
                 h4("Genes and hormones"),   
                 
                 HTML('<center><img src="expdesign.png", width = "100%"></center>'),
                 
                
                 p("Changes in gene expression can influence levels of ciruclating hormones. 
                   We also measured these four hormones across the stages of parental care 
                   and calculated weather they were correlated with gene expression 
                   (R^2 value provided in the table).
                   We can use scatter plots are often used to vizualze 
                   correlated changes in gene expression and hormone levels.
                   Chose a hormone and listen to how it's levels change as the 
                   selected gene increases in expression."),
                 
                 
                 tableOutput("correlations"),
                 
                 
                 
                 plotOutput("hormoneplots"),
                 
                
              
                 
                 p(""), 
                 
                 
                 
                 
                 actionButton("button4", 
                              "Listen to changes in hormone concentration as gene expression increases.")
                 
                 
                
                 
                 
                 ),
        
        tabPanel("About" ,
                 
                 h4("About"),    
                 
                 p("This app is a product of the 'Birds, Brains, and Banter (B3)'
                   Laboratory at the University of California at Davis.
                   This and related research is funded by the National Science Foundation,
                   in a grant to Rebecca Calisi and Matthew MacManes.
                   The webpage was created and written by Rayna Harris and Rebecca Calisi.  
                   Owen Marshall, Mauricio Vargas, Titus Brown, and 
                   Alexandra Colón Rodríguez contributed intellectually to the design. 
                   Suzanne Austin, Andrew Lang, Victoria Farrar, April Booth, 
                   Tanner Feustel, and Matthew MacManes contributed the 
                   experiment that is the foundation of this application. 
                   Before building this app, I used a keyboard to play
                   the sound of genes working together to regulate parental care. 
                   "),
                 
                 p("You can watch these videos to learn more about the inspiration 
                   behind this app and how to interactively
                   explore this dataset."),
                 
                 
                 HTML('<iframe width="75%" height = "400px" 
                      src="https://www.youtube.com/embed/PoKiIwIsLSo" 
                      frameborder="0" allow="accelerometer; autoplay; 
                      encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
                 
                
                 
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
                 )
                 

                 )
          )
      )
          
          
    )
  )
)
