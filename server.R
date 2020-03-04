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
      facet_wrap(tissue ~ gene, scales = "free_y") +
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
      facet_wrap(tissue~sex, scales = "free")
  })
}
