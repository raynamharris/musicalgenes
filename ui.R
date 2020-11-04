shinyUI(
  fluidPage(
    
    # Application title
    titlePanel("Musical Genes: Visualize and sonify gene expression"),

    # titlePanel(title=div(img(src="expdesign.png"))),
  
    tags$head(includeScript("google-analytics.html")),

    tags$div(lang="en", class="header"),

    # Inputs for boxplot
    sidebarLayout(
      sidebarPanel(
        
        
          
          h4("Molecular Symphony"), 
          
          p("Temporally controlled changes in gene expression 
            are often described as a symphony that is regulated by transcription factors. 
            What does this symphony of coordinated changes (or cacophony of 
            discoordinated changes) in gene expression sound like? 
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
          
         p("After choosing a gene, tissue and sex, click the 'sonify' 
            button to listen the mean value of gene expression."),
          
         p("Don't see your favorite gene?", 
           
           tags$a(
             href = "https://github.com/raynamharris/musicalgenes/issues/new?assignees=&labels=&template=request-a-gene.md&title=Gene+Request",
             "Check here to create a request."
           )
         ),
        
          
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
         
         h4("Learn more"),       
         
         p("Before building this app, I used a keyboard to play 
           the sound of genes working together to regulate parental care. 
           You can watch these videos to learn more about the inspiration behind this app."),
         
         
         HTML('<iframe width="95%" height = "200px" 
              src="https://www.youtube.com/embed/PoKiIwIsLSo" 
              frameborder="0" allow="accelerometer; autoplay; 
              encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
         
        
        

        HTML('<iframe width="95%" height="200px" 
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
      
        
      ),

      ### main panel
      mainPanel(
        
        tabsetPanel(
          tabPanel("Transcriptional Symphony", 
                   
                   h4("Transcriptional symphony"),      
              

          HTML('<center><img src="fig_musicalgenes.png", width = "100%"></center>'),
              
          
          p(""),
          
          plotOutput("boxPlot", width = "100%"),
          plotOutput("musicPlot", width = "100%"),
            
          p(" "),
          
          actionButton("button", "Sonify the average gene expression value."),
          
          downloadButton("wav_dln", label = "Download wav file."),
          
          uiOutput("audiotag"),
          
         
          p(" "),
          
          p("In the top image, box and whisker plots illustrate the median and range of data 
	    for each group. Below that, we use music notes to represent the mean for each group. 
	    You can imagine playing these notes on an instrument of your choice."),
        
        h4("Significant changes in gene expression (after testing for multiple hypotheses)."),
      
        p("These gene expression values were calculated using RNA sequencing (RNA-seq),
          which measures thousands of genes at once. 
          The table below summarizes the comparisons for this gene, tissue, and sex that survived multiple hypothesis testing. If the table is empty, then no comparisons were significant (adjusted p-value < 0.1)."),
        
        tableOutput("allsigdegs")
        
        ),
        
        tabPanel("Hormonal symphony" ,
                 
                 h4("Hormonal symphony"),      
                 
                 p("There is an intricate interplay between genes and hormones.
                   Genes directly or indirectly encode hormones and the receptors they bind to,
                   and hormones can module to the expression levels of many genes.
                   Here, we show the correlation pattern between the gene of interest and four hormones
                   (prolactin (prl), corticosterone (cort), progesterone (p4), 
                   and estradiol (e2) in females or testosterone (t) in males." ),
                 
                 plotOutput("hormoneplots")
                 ),
        
        tabPanel("Gene Information",
                 
                 h4("Gene information"),  
                
                 p("What biological processes and diseases are associated with the gene of interest?
                    The following descriptions, diseases, and biological processes associated with the selected 
                   gene of interest are provided by the ",
                   tags$a(
                     href = "https://www.alliancegenome.org/downloads#gene-descriptions",
                     "Alliance of Genome Resources.")
                 ),
                   
                 tableOutput("genedescrip"),
                 
                 tableOutput("goterms"),
                 
                 tableOutput("genedisease")
                 ),
        
        tabPanel("Future Directions" ,
                 
                 h4("Future directions"),    
                 
                 p("In the future, we would like to be able sonify data for multiple genes or hormones simultaneously using sounds from instruments found in an orchestra." ),
                 
                 tableOutput("orchestratable")
                   )
          )
      )
          
          
    )
  )
)
