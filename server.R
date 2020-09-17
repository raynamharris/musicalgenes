function(input, output) {
  
  gene_filter <- reactive({ as.character(input$gene) })
  gene2_filter <- reactive({ as.character(input$gene2) })
  tissue_filter <- reactive({ as.character(input$tissue) })
  sex_filter <- reactive({ as.character(input$sex) })
  treatment_filter <- reactive({ as.character(input$treatment) })
  
  
  output$plot3D <- renderPlot({
  
    candidatedata <- candidatecounts %>%
        filter(gene_name %in% c(!!as.character(input$gene))) %>%
        mutate(bird = sapply(strsplit(samples,'\\_'), "[", 1)) %>%
        select(gene, sex,tissue,treatment, bird, counts)  %>%
        pivot_wider(names_from = tissue, values_from = counts) %>%
        select(bird, treatment, sex, gene, hypothalamus, pituitary, gonads) %>%
        mutate(sex = factor(sex)) %>%
        drop_na()
      
      colors <- c(colorschar, colorsmanip)
      colors <- colors[as.numeric(candidatedata$treatment)]
      
      shapes = c(17, 16) 
      shapes <- shapes[as.numeric(candidatedata$sex)]
      
      p <- scatterplot3d(candidatedata[,c(6,7,5)], 
                         color = colors, pch = shapes,
                         main = input$gene,
                         cex.symbols = 1.25)
      return(p)
    
  })
  
  
  output$genename <- renderTable({
    
    mygene <- hugo %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      select(gene, name)
    mygene
    
  })
  

  output$boxPlot <- renderPlot({
    
    mysubtitle = paste("Data from",input$sex, input$tissue, input$gene, sep = " ")
    
    p1 <- candidatecounts %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      mutate(
        treatment = factor(treatment, levels = alllevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts)) +
      
      geom_boxplot(aes(fill = treatment), outlier.shape = NA, fatten = 2) +
      #geom_jitter(alpha = 0.8) +
        theme_minimal(base_size = 16) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels) +
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic"),
        strip.background  = element_blank(),
        panel.grid.major  = element_blank(),  # remove major gridlines
        panel.grid.minor  = element_blank()  # remove minor gridlines)
      ) +
      labs(y = "gene expression", x = NULL, subtitle = mysubtitle) +
      geom_signif(comparisons = list( c("control", "bldg"),
                                      c("bldg", "lay"),
                                      c("lay", "inc.d3"),
                                      c("inc.d3", "inc.d9"),
                                      c("inc.d9", "inc.d17"),
                                      c("inc.d17", "hatch"),
                                      c("hatch", "n5"),
                                      c("n5", "n9")),  
                  map_signif_level=TRUE, step_increase = 0.1) +
      geom_signif(comparisons = list( c("inc.d3", "m.inc.d3"),
                                      c("inc.d9", "m.inc.d9"),
                                      c("inc.d17", "m.inc.d17"),
                                      c("hatch", "m.n2")),  
                  map_signif_level=TRUE, step_increase = 0.1) +
    geom_signif(comparisons = list(  c("inc.d9", "early"),
                                    c("inc.d17", "prolong"),
                                    c("hatch", "extend")),  
                map_signif_level=TRUE) 
    p1
  })
  
  
  output$musicPlot <- renderPlot({
    
    candidatecounts <- as.data.frame(candidatecounts)

    df <- candidatecounts %>%
      mutate(
        treatment = factor(treatment, levels = alllevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      group_by(treatment, tissue, gene_name, gene, sex)  %>% 
      summarize(mean = mean(counts, na.rm = T), 
                se = sd(counts,  na.rm = T)/sqrt(length(counts))) %>%
      dplyr::mutate(image = "www/musicnote.png")   %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>% 
      collect() %>%
      drop_na() 
    
  
    
    p2 <- df %>%  
      ggplot( aes(x = treatment, y = mean)) +
      geom_errorbar(aes(ymin = mean - se, 
                        ymax = mean + se), 
                    color = "white", 
                    width=0) +
      geom_image(aes(image=image), size = 0.1)+
      theme_minimal(base_size = 16) +
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic"),
        strip.background  = element_blank(),
        panel.grid.major  = element_blank(),  # remove major gridlines
        panel.grid.minor  = element_blank()
      ) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels,
                       labels = alllevels) +
      labs(y = "mean gene expression as music notes", x = NULL) +
      scale_y_continuous(n.breaks = 5, 
                         labels = c("E", "G",  "B",  "D",  "F"))
    
    p2
    
  })
  
  

  output$musicalgenes <- renderTable({
    
    ## average and rescale data
   
    candidatecountsdf <- as.data.frame(candidatecounts)
   
    notes <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = alllevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% c(!!as.character(input$gene)),
                     tissue %in% !!as.character(input$tissue),
                     sex %in% !!as.character(input$sex)) %>%
      group_by(sex, tissue, treatment, gene_name) %>%
      summarize(scaledmean = mean(counts, na.rm = TRUE) + 2) %>%
      ungroup() %>%
      arrange(sex,treatment,gene_name)  %>%
      filter(treatment != "NA") %>%
      mutate(scaledmean = round(scales:::rescale(scaledmean, to = c(0,6)),0)) %>%
      left_join(., numberstonotes, by = "scaledmean")   %>%
      select(sex, tissue, treatment, gene_name, note ) %>%
      #pivot_wider(names_from = treatment, values_from = note ) %>%
      
      #select(gene_name, alllevels, instument) %>%
      group_by(gene_name) %>%
      summarize(notes = str_c(note, collapse = "")) %>%
      mutate(instument = sample(orchestra, 1, replace=F))  %>%
      select(gene_name, instument, notes)
   notes
    
  })
  
  
  
  output$orchestratable <- renderTable(({
    
    candidatecountsdf <- as.data.frame(candidatecounts)
    
    genestoplay <- sample(gene_names, 14)
    
    
    orchestratable <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = alllevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% genestoplay,
             tissue %in% !!as.character(input$tissue),
             sex %in% !!as.character(input$sex)) %>%
      #filter(gene_name %in% genestoplay,
      #       sex == "female",
      #       tissue  == "pituitary") %>%
      group_by(sex, tissue, treatment, gene_name) %>%
      summarize(scaledmean = mean(counts, na.rm = TRUE) + 2) %>%
      ungroup() %>%
      arrange(sex,treatment,gene_name)  %>%
      filter(treatment != "NA") %>%
      group_by(gene_name) %>%
      mutate(scaledmean = round(scales:::rescale(scaledmean, to = c(0,6)),0)) %>%
      left_join(., numberstonotes, by = "scaledmean")   %>%
      select(sex, tissue, treatment, gene_name, note ) %>%
      #pivot_wider(names_from = treatment, values_from = note ) 
       group_by(gene_name) %>%
      summarize(notes = str_c(note, collapse = ""))
    
    numrows <- nrow(orchestratable)
    orchestra <- sample(orchestra, numrows)

    orchestratable$instrument <- orchestra
    
    orchestratable <- orchestratable %>%
      select(gene_name, instrument, notes)
    orchestratable
  }))
  
  

  
  ## new sonify attempt from https://github.com/zielinskipp/sonifier/blob/master/app.R and
  ## https://zielinskipp.shinyapps.io/sonifier/
  
  observeEvent(input$button, {
    
    audiotag <- function(filename){tags$audio(src = filename,
                                              type ="audio/wav", controls = NA,
                                              autoplay = T)}
    
    candidatecountsdf <- as.data.frame(candidatecounts)
    
    meanvalues <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = alllevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% c(!!as.character(input$gene)),
             tissue %in% !!as.character(input$tissue),
             sex %in% !!as.character(input$sex)) %>%
      group_by(sex, tissue, treatment) %>%
      summarize(mean = mean(counts, na.rm = TRUE) + 2) %>%
      arrange(sex, treatment)  %>%
      filter(treatment != "NA") %>%
      mutate(scaled = scales:::rescale(mean, to = c(0,7))) %>%
      mutate(averaged = round(scaled,0) ) 
    
    output$text <- renderText({
    
      paste0("Your input, ", input$gene, ", sounds like this:")})
    
      sound <- sonify(x = meanvalues$mean, interpolation = "constant", duration = 6)
    
      # Saves file
      genename <- candidatecountsdf %>%
        filter(gene_name %in% c(!!as.character(input$gene))) %>%
        distinct(gene) %>% pull(gene)
                 
      wvname <- paste0(input$sex, input$tissue, genename, ".wav")
      writeWave(sound, paste0("www/", wvname))
    
    # Creates audiotag
    output$audiotag <- renderUI(audiotag(wvname))
    
    ## Dawnload handler
    output$wav_dln <- downloadHandler(
      filename = function(){
        paste0("musicalgene", input$gene, input$tissue, ".wav")
      },
      content = function(filename){
        writeWave(sound, filename)
      }
    )
  })
}
