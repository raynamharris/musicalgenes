function(input, output) {
  output$boxPlot <- renderPlot({
    reactivedf <- df %>%
      dplyr::filter(
        gene %in% c("PRL", input$gene),
        tissue %in% input$tissue,
        sex %in% input$sex
      ) %>%
      drop_na()

    p <- ggplot(reactivedf, aes(x = treatment, y = counts, color = sex)) +
      geom_boxplot(aes(fill = treatment)) +
      geom_point() +
      geom_smooth(aes(x = as.numeric(treatment))) +
      facet_wrap(tissue ~ gene, scales = "free_y", ncol = 2) +
      theme_classic(base_size = 16) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        strip.text.x = element_text(face = "italic")
      ) +
      labs(y = "gene expression", x = NULL)
    p
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
    df2 %>%
      dplyr::filter(
        gene %in% c("PRL", input$gene),
        tissue %in% input$tissue,
        sex %in% input$sex
      ) %>%
      mutate(lfcpadj = paste(round(lfc, 2), scientific(padj, digits = 3), sep = ", ")) %>%
      select(sex, tissue, comparison, gene, lfcpadj) %>%
      arrange(comparison) %>%
      pivot_wider(names_from = comparison, values_from = lfcpadj)
  })


  output$summaryTable <- renderTable({
    reactivedf <- df %>%
      dplyr::filter(
        gene %in% c("PRL", input$gene),
        tissue %in% input$tissue,
        sex %in% input$sex
      ) %>%
      drop_na() %>%
      group_by(sex, tissue, treatment, gene) %>%
      summarize(expression = median(counts)) %>%
      pivot_wider(names_from = gene, values_from = expression)
    reactivedf
  })


  output$scatterplot <- renderPlot({
    df %>%
      dplyr::filter(
        gene %in% c("PRL", input$gene),
        tissue %in% input$tissue,
        sex %in% input$sex
      ) %>%
      select(sex:counts) %>%
      pivot_wider(names_from = gene, values_from = counts) %>%
      ggplot(aes_string(x = "PRL", y = input$gene)) +
      geom_point(aes(color = treatment)) +
      geom_smooth(method = "lm", aes(color = sex)) +
      facet_wrap(~tissue, ncol = 1, scales = "free") +
      theme_classic(base_size = 14) +
      scale_fill_manual(values = allcolors, guide = FALSE) +
      scale_color_manual(values = allcolors) +
      theme(legend.position = "bottom")
  })
  
  
output$cortestres <- renderPrint({
  
  gene <- df %>%
    dplyr::filter(
      gene %in% c("PRL",input$gene) ,
      tissue %in% input$tissue,
      sex %in% input$sex
    ) %>%
    select(sex:counts) %>%
    pivot_wider(names_from = gene, values_from = counts)   %>%
    select(-sex, -tissue, -treatment, -samples)
  
  print(paste("gene 1 is", names(gene[1]), sep = " "))
  print(paste("gene 2 is", names(gene[2]), sep = " "))
  
  res <- cor.test(gene[[1]], gene[[2]], method = "pearson")
  return(res)
  })
  

  
  output$tsne <- renderPlot({
    
    tsne %>%
      dplyr::filter( tissue %in%  input$tissue,
                     sex %in% input$sex,
                     treatment %in% input$treatment) %>%
      ggplot(aes(x = V1, y = V2, color = treatment)) +
      geom_point() +
      stat_ellipse() +
      theme_classic(base_size = 14) +
      scale_fill_manual(values = allcolors, guide=FALSE) +
      scale_color_manual(values = allcolors)  +
      theme(legend.position = "none") +
      facet_wrap(tissue~sex, scales = "free") +
      labs(x = 'tSNE 1', y = "tSNE 2")
  })
  
  
  output$barplot <- renderPlot({
    
    p <- allDEGs %>%
      filter(tissue %in% input$tissue,
             comparison %in% input$treatment,
             sex %in% input$sex) %>%
      ggplot(aes(x = comparison,  fill = direction)) +
      geom_bar(position = "dodge") +
      #facet_wrap(tissue~sex) +
      theme_classic(base_size = 14) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "none")  +
      guides(fill = guide_legend(nrow = 1)) +
      labs(x = "Sequential parental care stage comparisons", 
           y = "Total DEGs",
           subtitle = " ") +
      scale_fill_manual(values = allcolors,
                        name = " ",
                        drop = FALSE) +
      scale_color_manual(values = allcolors) +
      geom_text(stat='count', aes(label=..count..), vjust =-0.5, 
                position = position_dodge(width = 1),
                size = 2, color = "black")  
    p
    
  
  })
}
