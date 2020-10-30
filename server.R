function(input, output) {
  
  gene_filter <- reactive({ as.character(input$gene) })
  gene2_filter <- reactive({ as.character(input$gene2) })
  tissue_filter <- reactive({ as.character(input$tissue) })
  sex_filter <- reactive({ as.character(input$sex) })
  treatment_filter <- reactive({ as.character(input$treatment) })
  
  
  output$allsigdegs <- renderTable({
  
  con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")
    
  df <- tbl(con, "alldeg") %>% 
    left_join(
      tbl(con, "hugo") %>% 
        dplyr::distinct(gene, name) %>% 
        mutate(gene_name = paste(gene, name, sep = ": "))
    ) %>% 
    select(sex, tissue, comparison, gene, gene_name, lfc, padj) %>%
    filter(
      gene_name %in% c(!!as.character(input$gene)),
      tissue %in% !!as.character(input$tissue),
      sex %in% !!as.character(input$sex)
    )  %>%
    filter(comparison  %in% 
             c("control_bldg", "bldg_lay",  "bldg_inc.d3",  
               "bldg_inc.d9",   "bldg_inc.d17",  
               "bldg_hatch", "bldg_n5", "bldg_n9",
               "bldg_lay",  "lay_inc.d3",  
               "inc.d3_inc.d9",   "inc.d9_inc.d17",  
               "inc.d17_hatch", "hatch_n5", "n5_n9",
               "inc.d3_m.inc.d3", "inc.d9_m.inc.d9",
               "inc.d17_m.inc.d17",  "hatch_m.n2" ,
               "inc.d9_early","inc.d17_prolong", "hatch_early",
               "hatch_prolong", "hatch_extend")
    ) %>% 
    collect() %>% 
    mutate(reference = sapply(strsplit(as.character(comparison), '\\_'), "[", 1),
           treatment = sapply(strsplit(as.character(comparison), '\\_'), "[", 2)) %>%
    mutate(group = paste(sex, tissue, sep = " "),
           group = paste(gene, group, sep = " in the ")) %>%
    rename("gene expression" = 'group') %>%
    select(reference, treatment, lfc, padj, "gene expression")
  
  dbDisconnect(con, shutdown = TRUE)
  
  df
  
  })
  
  

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
                                      c("bldg", "inc.d3"),
                                      c("bldg", "inc.d9"),
                                      c("bldg", "inc.d17"),
                                      c("bldg", "hatch"),
                                      c("bldg", "n5"),
                                      c("bldg", "n9")),  
                  map_signif_level=TRUE, step_increase = 0.1,
                  margin_top = 0.05) +
      geom_signif(comparisons = list( c("inc.d3", "m.inc.d3"),
                                      c("inc.d9", "m.inc.d9"),
                                      c("inc.d17", "m.inc.d17"),
                                      c("hatch", "m.n2")),  
                  map_signif_level=TRUE, step_increase = 0.1,
                  margin_top = 0.05) +
    geom_signif(comparisons = list(  c("inc.d9", "early"),
                                    c("inc.d17", "prolong"),
                                    c("hatch", "extend")),  
                map_signif_level=TRUE, margin_top = 0.05) 
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
      labs(y = "mean gene expression as music notes", x = NULL) 
    
    p2
    
  })
  
  
  
  output$hormoneplots <- renderPlot({
    
    con <- dbConnect(duckdb(), "data/musicalgenes.duckdb")
    hormones <- tbl(con, "hormones") %>% collect()
    dbDisconnect(con, shutdown = TRUE)
    
    
    mysubtitle = paste("Data from",input$sex, input$tissue, input$gene, sep = " ")
    
    candidatecounts %>%
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
      mutate(treatment = factor(treatment, levels = alllevels)) %>%
      ggplot(aes(x = log10(counts), y = log10(conc))) +
      geom_point(aes( color = treatment)) +
      geom_smooth(aes(color = sex), method = "lm") +
      facet_wrap(~hormone, nrow = 1, scales = "free_y") +
      theme_minimal(base_size = 16) + 
      scale_color_manual(values = allcolors) +
      labs(x = "log10(gene expression)", y = "log10(hormone concentration)",
           subtitle = mysubtitle)
        
    
    
    
    
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