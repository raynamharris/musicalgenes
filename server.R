function(input, output) {
  
  gene_filter <- reactive({ as.character(input$gene) })
  gene2_filter <- reactive({ as.character(input$gene2) })
  tissue_filter <- reactive({ as.character(input$tissue) })
  sex_filter <- reactive({ as.character(input$sex) })
  treatment_filter <- reactive({ as.character(input$treatment) })
  
  
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
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts)) +
      geom_boxplot(aes(fill = treatment), outlier.shape = NA, fatten = 2) +
      #geom_jitter(aes(color = sex), position=position_dodge(0.8)) +
      theme_minimal(base_size = 14) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = charlevels) +
      theme(
        axis.text.x = element_blank(),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic"),
        strip.background  = element_blank(),
        panel.grid.major  = element_blank(),  # remove major gridlines
        panel.grid.minor  = element_blank()  # remove minor gridlines)
      ) +
      labs(y = "gene expression", x = NULL, subtitle = mysubtitle) +
      geom_signif(comparisons = list( c( "control", "bldg"),
                                      c( "bldg", "lay"),
                                      c( "lay", "inc.d3"),
                                      c("inc.d3", "inc.d9"),
                                      c( "inc.d9", "inc.d17"),
                                      c( "inc.d17", "hatch"),
                                      c("hatch", "n5"),
                                      c( "n5", "n9")),  
                  map_signif_level=TRUE) 
    
    candidatecounts <- as.data.frame(candidatecounts)

    p2 <- candidatecounts %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
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
      drop_na() %>%
      ggplot( aes(x = treatment, y = mean)) +
      geom_errorbar(aes(ymin = mean - se, 
                        ymax = mean + se), color = "white", width=0) +
      geom_image(aes(image=image), size = 0.15)+
      theme_void(base_size = 14) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = charlevels,
                       labels = charlabels) +
      theme(legend.position = "none") +
      theme(axis.title.y = element_text(color = "black", angle = 90),
            axis.text.x = element_text(color = "black", size = 10),
            plot.caption = element_text(face = "italic", size = 16)) +
      labs(y = "music notes")

    plot_grid(p1,p2, rel_heights = c(1.4,1), ncol = 1, align = "v")
  })
  
  

  output$musicalgenes <- renderTable({
    
    ## average and rescale data
   
    candidatecountsdf <- as.data.frame(candidatecounts)
   
    notes <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% c(!!as.character(input$gene)),
                     tissue %in% !!as.character(input$tissue),
                     sex %in% !!as.character(input$sex)) %>%
      group_by(sex, tissue, treatment, gene) %>%
      summarize(scaledmean = mean(counts, na.rm = TRUE) + 2) %>%
      ungroup() %>%
      arrange(sex,treatment,gene)  %>%
      filter(treatment != "NA") %>%
      mutate(scaledmean = round(scales:::rescale(scaledmean, to = c(0,6)),0)) %>%
      left_join(., numberstonotes, by = "scaledmean")   %>%
      select(sex, tissue, treatment, gene, note ) %>%
      pivot_wider(names_from = treatment, values_from = note ) %>%
      mutate(instument = sample(orchestra, 1, replace=F)) %>%
      select(gene, charlevels, instument)# %>%
      #unite("notes", control:n9, remove = FALSE, sep = "")
   notes
    
  })

  
  ## new sonify attempt from https://github.com/zielinskipp/sonifier/blob/master/app.R and
  ## https://zielinskipp.shinyapps.io/sonifier/
  
  observeEvent(input$button, {
    
    audiotag <- function(filename){tags$audio(src = filename,
                                              type ="audio/wav", controls = NA,
                                              autoplay = T)}
    
    candidatecountsdf <- as.data.frame(candidatecounts)
    
    meanvalues <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
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
