function(input, output) {
  
  gene_filter <- reactive({ as.character(input$gene) })
  gene2_filter <- reactive({ as.character(input$gene2) })
  tissue_filter <- reactive({ as.character(input$tissue) })
  sex_filter <- reactive({ as.character(input$sex) })
  treatment_filter <- reactive({ as.character(input$treatment) })
  hormone_filter <- reactive({ as.character(input$hormone) })
  
  output$genedescrip <- renderTable({
    
    con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")
    
    df <- tbl(con, "descriptions") %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      collect() %>% 
      mutate(
        Description = replace_na(Description, "Not currrently available.")
      ) %>%
      select(Description) %>%
      rename("Gene description" = Description)
    
    dbDisconnect(con, shutdown = TRUE)
    
    df
    
  })
  
  output$genedisease <- renderTable({
    
    con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")
    
    df <- tbl(con, "disease") %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      select(diseases) %>%
      collect() %>%
      rename("Associated diseases" = diseases)
    
    dbDisconnect(con, shutdown = TRUE)
    
    df
    
  })
  
  output$goterms <- renderTable({
    
    con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")
    
    df <- tbl(con, "bpgo") %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      distinct(gene, name, gene_name, GOterm) %>%
      arrange(GOterm, gene, gene_name) %>%
      collect() %>% 
      group_by(gene_name) %>%
      summarize(GOterms = str_c(GOterm, collapse = "; ")) %>%
      select(GOterms) %>%
      rename("Gene Ontology: Associated Biological Processes" = GOterms)
    
    dbDisconnect(con, shutdown = TRUE)
    
    df
    
  })
  
  output$boxnmusicplot1 <- renderPlot({
    
    mysubtitle = paste(input$sex, input$tissue, input$gene, "expression", sep = " ")
    
    p1 <- candidatecounts %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      filter(treatment %in% charlevels) %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts)) +
      geom_boxplot(aes(fill = treatment), outlier.shape = NA, fatten = 2) +
      geom_point() +
      musicalgenestheme() +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels) +
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic")
      ) +
      labs(x = NULL, y = mysubtitle)  
    p1
  

    df <- candidatecounts %>%
      as.data.frame(candidatecounts) %>%
      filter(treatment %in% charlevels) %>%
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
      drop_na() 
  
    p2 <- df %>%  
      ggplot( aes(x = treatment, y = mean)) +
      geom_errorbar(aes(ymin = mean - se, 
                        ymax = mean + se), 
                    color = "white", 
                    width=0) +
      geom_image(aes(image=image), size = 0.1)+
      musicalgenestheme() + 
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none"
      ) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels,
                       labels = alllevels) +
      labs(y = NULL, x = NULL, subtitle = " ") 
    
    p <- plot_grid(p1,p2)
    p
    
  })
  
  observeEvent(input$button1, {
    
    audiotag <- function(filename){tags$audio(src = filename,	    
                                              type ="audio/wav", 
                                              controls = NA,	
                                              autoplay = T)}
    
    meanvalues <- candidatecounts %>%
      as.data.frame(.) %>%
      filter(treatment %in% charlevels) %>%
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
      mutate(scaled = scales:::rescale(mean, to = c(0,6))) %>%
      mutate(averaged = round(scaled,0) ) 
    
    sound <- sonify(x = meanvalues$mean, interpolation = "constant", duration = 3)
    
    # Saves file
    genename <- candidatecounts %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      distinct(gene) %>% pull(gene)
    
    wvname <- paste0( input$sex, input$tissue, genename, ".wav")
    writeWave(sound, paste0("www/", wvname))
    
    # Creates audiotag
    output$audiotag <- renderUI(audiotag(wvname))
    
    ## Dawnload handler
    output$wav_dln <- downloadHandler(
      filename = function(){
        paste0( input$sex, input$tissue, genename, ".wav")
      },
      content = function(filename){
        writeWave(sound, filename)
      }
    )
  })
  
  output$boxnmusicplot2 <- renderPlot({
    
    p1 <- candidatecounts %>%
      filter(treatment %in% rmlevels) %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      mutate(
        treatment = factor(treatment, levels = rmlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts)) +
      geom_boxplot(aes(fill = treatment), outlier.shape = NA, fatten = 2) +

      geom_point() +
      musicalgenestheme() +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels) +
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic")
      ) +
      labs(y = "gene expression", x = NULL, subtitle = " ") 
    p1
    
    
    df <- candidatecounts %>%
      filter(treatment %in% rmlevels) %>%
      mutate(
        treatment = factor(treatment, levels = rmlevels),
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
      musicalgenestheme() + 
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic")
      ) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels,
                       labels = alllevels) +
      labs(y = NULL, x = " ", subtitle = " ") 
    
    p <- plot_grid(p1,p2)
    p
    
  })
  
  observeEvent(input$button2, {
    
    audiotag <- function(filename){tags$audio(src = filename,	    
                                              type ="audio/wav", 
                                              controls = NA,	
                                              autoplay = T)}
    
     meanvalues <- candidatecounts %>%
       as.data.frame(.) %>%
     filter(treatment %in% rmlevels) %>%
      mutate(
        treatment = factor(treatment, levels = rmlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% c(!!as.character(input$gene)),
             tissue %in% !!as.character(input$tissue),
             sex %in% !!as.character(input$sex)) %>%
      group_by(sex, tissue, treatment) %>%
      summarize(mean = mean(counts, na.rm = TRUE) + 2) %>%
      arrange(sex, treatment)  %>%
      filter(treatment != "NA") %>%
      mutate(scaled = scales:::rescale(mean, to = c(0,6))) %>%
      mutate(averaged = round(scaled,0) ) 
    
     sound <- sonify(x = meanvalues$mean, interpolation = "constant", duration = 3)
     sound
     
     # Saves file
     genename <- candidatecounts %>%
       filter(gene_name %in% c(!!as.character(input$gene))) %>%
       distinct(gene) %>% pull(gene)
     
     wvname <- paste0("musicalgeneremoval", input$sex, input$tissue, genename, ".wav")
     writeWave(sound, paste0("www/", wvname))
     
     # Creates audiotag
     output$audiotag <- renderUI(audiotag(wvname))
     
     ## Dawnload handler
     output$wav_dln <- downloadHandler(
       filename = function(){
         paste0("musicalgeneremoval", input$sex, input$tissue, genename, ".wav")
       },
       content = function(filename){
         writeWave(sound, filename)
       }
     )
  })
  
  output$boxnmusicplot3 <- renderPlot({
    
    p1 <- candidatecounts %>%
      filter(treatment %in% timelevels) %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      mutate(
        treatment = factor(treatment, levels = timelevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts)) +
      geom_boxplot(aes(fill = treatment), outlier.shape = NA, fatten = 2) +
      
      geom_point() +
      musicalgenestheme() +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels) +
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic")
      ) +
      labs(y = "gene expression", x = NULL, subtitle = " ") 
    p1
    
    
    candidatecounts <- as.data.frame(candidatecounts)
    
    df <- candidatecounts %>%
      filter(treatment %in% timelevels) %>%
      mutate(
        treatment = factor(treatment, levels = timelevels),
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
      musicalgenestheme() + 
      theme(
        axis.text.x = element_text(color = "black", size = 16, 
                                   angle = 45, hjust = 0.5),
        legend.position = "none",
        plot.subtitle  = element_text(face = "italic")
      ) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels,
                       labels = alllevels) +
      labs(y = NULL, x = " ", subtitle = " ") 
    
    p <- plot_grid(p1,p2)
    p
    
  })
  
  observeEvent(input$button3, {
    
    audiotag <- function(filename){tags$audio(src = filename,	    
                                              type ="audio/wav", 
                                              controls = NA,	
                                              autoplay = T)}
    
    meanvalues <- candidatecounts%>%
      as.data.frame(.) %>%
      filter(treatment %in% timelevels) %>%
      mutate(
        treatment = factor(treatment, levels = timelevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% c(!!as.character(input$gene)),
             tissue %in% !!as.character(input$tissue),
             sex %in% !!as.character(input$sex)) %>%
      group_by(sex, tissue, treatment) %>%
      summarize(mean = mean(counts, na.rm = TRUE) + 2) %>%
      arrange(sex, treatment)  %>%
      filter(treatment != "NA") %>%
      mutate(scaled = scales:::rescale(mean, to = c(0,6))) %>%
      mutate(averaged = round(scaled,0) ) 
    
    sound <- sonify(x = meanvalues$mean, interpolation = "constant", duration = 3)
    
    # Saves file
    genename <- candidatecounts %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      distinct(gene) %>% pull(gene)
    
    wvname <- paste0("musicalgenetiming", input$sex, input$tissue, genename, ".wav")
    writeWave(sound, paste0("www/", wvname))
    
    # Creates audiotag
    output$audiotag <- renderUI(audiotag(wvname))
    
    ## Dawnload handler
    output$wav_dln <- downloadHandler(
      filename = function(){
        paste0("musicalgenetiming", input$sex, input$tissue, genename, ".wav")
      },
      content = function(filename){
        writeWave(sound, filename)
      }
    )
  })
  
  output$musicalgenes <- renderTable({

    notes <- candidatecounts %>%
      as.data.frame(.) %>%
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
    
    #genestoplay <- sample(gene_names, 14)
    
    genestoplay <- c("AR: androgen receptor",
                     "AVP: arginine vasopressin",
                     "AVPR1A: arginine vasopressin receptor 1A",
                     "CRHBP: corticotropin releasing hormone binding protein",
                     "ESR1: estrogen receptor 1",
                     "FOS: Fos proto-oncogene, AP-1 transcription factor subunit",
                     "GALR1: galanin receptor 1",
                     "GNRHR: gonadotropin releasing hormone receptor",
                     "OXT: oxytocin/neurophysin I prepropeptide",
                     "PGR: progesterone receptor",
                     "PRL: prolactin",
                     "PRLR: prolactin receptor",
                     "TH: tyrosine hydroxylase",
                     "VIP: vasoactive intestinal peptide")
    
    orchestratable <- candidatecountsdf %>%
      mutate(
        treatment = factor(treatment, levels = alllevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      filter(gene_name %in% genestoplay,
             tissue %in% !!as.character(input$tissue),
             sex %in% !!as.character(input$sex),
             treatment %in% charlevels) %>%
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
      select(gene_name, instrument, notes) %>%
      rename(
        'gene' = gene_name)
    orchestratable
  }))
  
  
  
  output$hormoneplots <- renderPlot({
    
    con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")
    hormones <- tbl(con, "hormones") %>% collect()
    dbDisconnect(con, shutdown = TRUE)
    
    myxlab = paste("log10( ", #input$sex, input$tissue, 
                   input$gene, " expr.)",
                   sep = " ")
    
    
    myylab = paste("log10( ", #input$sex, input$tissue, 
                   input$hormone, " conc.)",
                   sep = " ")
    
    
    p3 <- candidatecounts %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      mutate(id = sapply(strsplit(samples,'\\_'), "[", 1))  %>%
      select(-samples) %>%
      inner_join(hormones, 
                 by = "id")  %>%
      select(id, sex, treatment, tissue, gene, gene_name, counts, prl:e2t) %>%
      pivot_longer(cols = prl:e2t, 
                   names_to = "hormone", values_to = "conc") %>%
      mutate(hormone = factor(hormone),
             hormone=recode(hormone,  "prl" = "prolactin",
                         "e2t" ="sex steroids",
                         "cort" = "corticosterone",
                         "p4" = "progesterone"),
             hormone = factor(hormone, levels = hormonelevels)) %>%
      filter(hormone %in% !!as.character(input$hormone)) %>%
      filter(treatment %in% charlevels) %>%
      filter(treatment != "control") %>%
      mutate(treatment = factor(treatment, levels = charlevels)) %>%
      ggplot(aes(x = log10(counts), y = log10(conc))) +
        geom_point(aes( color = treatment)) +
        #geom_smooth(aes(color = sex), method = "lm") +
        musicalgenestheme() + 
        scale_color_manual(values = allcolors) +
        labs(x = myxlab,  y = myylab) +
        theme(legend.position = "none")
    
    
    myylab2 = paste("log10( ", #input$sex, input$tissue, 
                   input$gene, " expression)",
                   sep = " ")
    
    p1 <- candidatecounts %>%
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      collect() %>%
      filter(treatment %in% charlevels,
             treatment != "control") %>%
      mutate(
        treatment = factor(treatment, levels = charlevels),
        tissue = factor(tissue, levels = tissuelevels)
      ) %>% 
      drop_na() %>%
      ggplot(aes(x = treatment, y = counts)) +
      geom_boxplot(aes(fill = treatment, color = sex), outlier.shape = NA, fatten = 2) +
      geom_point() +
      musicalgenestheme() +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      scale_x_discrete(breaks = alllevels) +
      musicalgenestheme() +
      theme(legend.position = "none",
            axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_y_log10() +
      labs(x = "parental stage", y = myylab2)  
    
    
    myylab3 = paste("log10( ", #input$sex, input$tissue, 
                    input$hormone, " concentration)",
                    sep = " ")
    
    p2 <- hormones2 %>%
      filter(treatment %in% charlevels,
             sex %in% !!as.character(input$sex),
             name %in% !!as.character(input$hormone)) %>%
      ggplot(aes(x = treatment, y = value)) +
      
      geom_boxplot(aes(fill = treatment, color = sex)) +
      geom_point() +
      musicalgenestheme() +
      scale_fill_manual(values = allcolors) +
      scale_color_manual(values = allcolors) +
      theme(legend.position = "none",
            axis.text.x = element_text(angle = 45, hjust = 1)) +
      
      scale_y_log10() +
      labs(y = myylab3, x = "parental stage") 
    
    
    p <- plot_grid(p3,p1, p2, nrow = 1)
    p
    
    
    
    
  })
  
  
  
  output$correlations <- renderTable({
  
    
    
      
    correlations <- candidatecounts %>%
      
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      
      
      mutate(id = sapply(strsplit(samples,'\\_'), "[", 1))  %>%
      select(-samples) %>%
      inner_join(hormones, 
                 by = "id")  %>%
      select(id, sex, treatment, tissue, gene, gene_name, counts, prl:e2t) %>%
      pivot_longer(cols = prl:e2t, 
                   names_to = "hormone", values_to = "conc") %>%
      group_by(gene_name, hormone) %>%
      summarize(R2=cor(counts,conc))  %>%
      pivot_wider(names_from = hormone, values_from = R2) %>%
      select(gene_name, cort, p4, prl, e2t) %>%
      rename(
        'gene' = gene_name, 
        'corticosterone' = cort ,
        'progesterone' = p4,
        'prolactin' = prl,
        'sex steroids' = e2t
      )
    correlations
    
    
  })
  
  
  
  
  
  
  observeEvent(input$button4, {
    
    audiotag <- function(filename){tags$audio(src = filename,	    
                                              type ="audio/wav", 
                                              controls = T,	
                                              autoplay = T)}
    
    correlations <- candidatecounts %>%
      
      filter(
        gene_name %in% c(!!as.character(input$gene)),
        tissue %in% !!as.character(input$tissue),
        sex %in% !!as.character(input$sex)
      ) %>%
      
      mutate(id = sapply(strsplit(samples,'\\_'), "[", 1))  %>%
      select(-samples) %>%
      inner_join(hormones, 
                 by = "id")  %>%
      select(id, sex, treatment, tissue, gene, gene_name, counts, prl:e2t) %>%
      pivot_longer(cols = prl:e2t, 
                   names_to = "hormone", values_to = "conc") %>%
      
      mutate(hormone = factor(hormone),
             hormone=recode(hormone,  "prl" = "prolactin",
                            "e2t" ="sex steroids",
                            "cort" = "corticosterone",
                            "p4" = "progesterone"),
             hormone = factor(hormone, levels = hormonelevels)) %>%
      
      group_by(gene, hormone) %>%
      filter(treatment %in% charlevels,
             hormone %in% c(!!as.character(input$hormone))) %>%
      arrange(counts)
    
    sound <-  sonify(x = correlations$conc,  interpolation = "constant", duration = 9)
    
    
    # Saves file
    genename <- candidatecounts %>%
      filter(gene_name %in% c(!!as.character(input$gene))) %>%
      distinct(gene) %>% pull(gene)
    
    wvname <- paste0(input$sex, input$tissue, genename, input$hormone, ".wav")
    writeWave(sound, paste0("www/", wvname))
    
    # Creates audiotag
    output$audiotag <- renderUI(audiotag(wvname))
    
    ## Dawnload handler
    output$wav_dln2 <- downloadHandler(
      filename = function(){
        paste0(input$sex, input$tissue, genename, input$hormone, ".wav")
      },
      content = function(filename){
        writeWave(sound, filename)
      }
    )
    
  })

}