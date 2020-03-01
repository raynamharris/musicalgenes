#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

gene_names <- df %>% distinct(gene) %>% pull()

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Gene expression in parental pigeons"),
 
  # Sidebar with a slider input for boxplot
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "variable",
                  label = "candidate gene",
                  choices = c(gene_names),
                  selected = "PRL",
                  multiple = FALSE)
    ),
    
    # boxplot
    mainPanel(
       plotOutput("boxPlot", height = "750px")
    )
  )
))


