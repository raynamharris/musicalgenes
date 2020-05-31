function(input, output) {
  
  gene_filter <- reactive({ as.character(input$gene) })
  gene2_filter <- reactive({ as.character(input$gene2) })
  tissue_filter <- reactive({ as.character(input$tissue) })
  sex_filter <- reactive({ as.character(input$sex) })
  treatment_filter <- reactive({ as.character(input$treatment) })
  
  
  output$genename <- renderTable({
    
    mygene <- hugo %>%
      filter(gene %in% c(!!as.character(input$gene))) 
    mygene
    
  })
  
  output$genename2 <- renderTable({
    
    mygene <- hugo %>%
      filter(gene %in% c(!!as.character(input$gene2))) 
    mygene
    
  })
  
  
  output$boxPlot <- renderPlot({
    
    mysubtitle = paste("Data:",input$sex, input$tissue, input$gene, sep = " ")
    
    p1 <- candidatecounts %>%
      filter(
        gene %in% c(!!as.character(input$gene)),
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
      theme_minimal(base_size = 16) +
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
      labs(y = "gene expression", x = NULL) +
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
      group_by(treatment, tissue, gene, sex)  %>% 
      summarize(mean = mean(counts, na.rm = T), 
                se = sd(counts,  na.rm = T)/sqrt(length(counts))) %>%
      #dplyr::mutate(scaled = rescale(mean, to = c(0, 7))) %>%
      dplyr::mutate(image = "www/musicnote.png")   %>%
      filter(
        gene %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>% 
      collect() %>%
      drop_na() %>%
      ggplot( aes(x = treatment, y = mean)) +
      geom_errorbar(aes(ymin = mean - se, 
                        ymax = mean + se), color = "white", width=0) +
      geom_image(aes(image=image), size = 0.15)+
      theme_void(base_size = 16) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = charlevels) +
      theme(legend.position = "none") +
      theme(axis.title.y = element_text(color = "black", angle = 90),
            plot.caption = element_text(face = "italic", size = 16)) +
      labs(y = "music notes", caption = mysubtitle)

    plot_grid(p1,p2, rel_heights = c(1.4,1), ncol = 1, align = "v")
  })
  
  

  observeEvent(input$play, {
    insertUI(
      selector = "#play",
      where = "afterEnd",
      ui = tags$audio(
        src = "PRLfemalepituitary.mp3",
        type = "audio/mp3",
        autoplay = NA, controls = NA,
        style = "display:none;"
      )
    )
  })

  output$DEGtable <- renderTable({
    alldeg %>%
      filter(
        gene %in% c("PRL", !!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      mutate(
        tissue = factor(tissue, levels = tissuelevels),
        direction = factor(direction, levels = charlevels),
        comparison = factor(comparison, levels = comparisonlevels)
      ) %>% 
      mutate(lfcpadj = paste(round(lfc, 2), scientific(padj, digits = 3), sep = ", ")) %>%
      select(sex, tissue, comparison, gene, lfcpadj) %>%
      arrange(comparison) %>%
      pivot_wider(names_from = comparison, values_from = lfcpadj)
  })

  output$summaryTable <- renderTable({
    reactivecandidatecounts <- candidatecounts %>%
      filter(
        gene %in% c("PRL", !!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      drop_na() %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      group_by(sex, tissue, treatment, gene) %>%
      summarize(expression = mean(counts)) %>%
      pivot_wider(names_from = gene, values_from = expression)
    reactivecandidatecounts
  })

  output$scatterplot <- renderPlot({
    
    mysubtitle = paste("Data:",input$sex, input$tissue, sep = " ")
    

    df <- candidatecounts %>%
      filter(
        gene %in% c(!!as.character(input$gene2), !!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      select(sex:counts) %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      pivot_wider(names_from = gene, values_from = counts)  
    
    df %>% ggplot(aes_string(x = input$gene, y = input$gene2)) +
      geom_point(aes(color = treatment)) +
      geom_smooth(method = "lm", aes(color = sex)) +
      #facet_wrap(~tissue, ncol = 1, scales = "free") +
      theme_classic(base_size = 16) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      theme(legend.position = "none",
            axis.title = element_text(face = "italic"),
            plot.caption = element_text(face = "italic", size = 16)) +
      guides(color = guide_legend(nrow = 2)) +
      labs(caption = mysubtitle) 
  })

  
 outputPrint <- renderPrint({
   

   
 }) 
  

  output$tsne <- renderPlot({
    tsne_df <- tsne %>%
      filter(
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex),
        treatment %in% !!as.character(input$treatment)
      ) %>%
      collect()
    
    tsne_df$tissue <- factor(tsne_df$tissue, levels = c("hypothalamus", "pituitary", "gonads"))
    tsne_df <- tsne_df %>% mutate(tissue = fct_recode(tissue, "gonad" = "gonads"))
    
    tsne_df %>% 
      ggplot(aes(x = V1, y = V2, color = treatment)) +
      geom_point() +
      stat_ellipse() +
      theme_classic(base_size = 14) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      theme(legend.position = "none") +
      facet_wrap(~ sex, scales = "free") +
      labs(x = 'tSNE 1', y = "tSNE 2", subtitle = input$tissue)
  })
  
  
  output$barplot <- renderPlot({
    
  
    p <- alldeg %>%
     filter(tissue %in% !!as.character(input$tissue),
            #direction %in% !!as.character(input$treatment),
            sex %in% !!as.character(input$sex)) %>%
      collect() %>%
      mutate(
        comparison = factor(comparison, levels = comparisonlevels)
      ) %>% 
      ggplot(aes(x = comparison,  fill = direction)) +
      geom_bar(position = "dodge") +
      facet_wrap(~sex) +
      theme_classic(base_size = 14) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "none")  +
      guides(fill = guide_legend(nrow = 1)) +
      labs(x = "Sequential parental care stage comparisons", 
           y = "Total DEGs",
           subtitle = input$tissue) +
      scale_fill_manual(values = allcolors,
                        name = " ",
                        drop = FALSE) +
      scale_color_manual(values = allcolors) +
      geom_text(stat='count', aes(label=..count..), vjust =-0.5, 
                position = position_dodge(width = 1),
                size = 2, color = "black")  
    p
    
  })
  
  
  
  output$musicalgenes <- renderTable({
    
    ## average and rescale data
   
    candidatecountsdf <- as.data.frame(candidatecounts)
   
    meanvalues <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene %in% c(!!as.character(input$gene)),
                     tissue %in% !!as.character(input$tissue),
                     sex %in% !!as.character(input$sex)) %>%
      group_by(sex, tissue, treatment) %>%
      summarize(mean = mean(counts, na.rm = TRUE) + 2) %>%
      arrange(sex, treatment)  %>%
      filter(treatment != "NA") %>%
      #mutate(scaled = scales:::rescale(mean, to = c(0,7))) %>%
      mutate(scaled = mean) %>%
      mutate(averaged = round(scaled,0) ) 
      
    notes <- left_join(meanvalues, numberstonotes, by = "averaged")   %>%
      select(sex, tissue, treatment, note ) %>%
      pivot_wider(names_from = sex, values_from = note ) %>%
      mutate(treatment = factor(treatment, levels = charlevels)) %>%
      pivot_longer(-c(tissue, treatment),  names_to = "sex", values_to = "note") %>%
      pivot_wider(names_from = treatment, values_from = note)
    
    notes
    
    ## sonify datat
    #musicalgenes <-  sonify(x = meanvalues$mean, interpolation = "constant")
  })

  
  ## new sonify attempt from https://github.com/zielinskipp/sonifier/blob/master/app.R and
  ## https://zielinskipp.shinyapps.io/sonifier/
  
  observeEvent(input$button, {
    
    audiotag <- function(filename){tags$audio(src = filename,
                                              type ="audio/wav", controls = NA)}
    
    candidatecountsdf <- as.data.frame(candidatecounts)
    
    meanvalues <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene %in% c(!!as.character(input$gene)),
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
    wvname <- paste0(input$sex, input$tissue, input$gene, ".wav")
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
