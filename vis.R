# Install visNetwork if not already installed
# install.packages("visNetwork")
library(igraph)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(visNetwork)
# Load data
data <- read.csv("collab_test.csv")
data1 <- read.csv("dept_list_updated.csv")
# Select relevant columns and merge data
c1 <- select(data1, col1, dept1)
c2 <- select(data1, col2, dept2)
data <- left_join(data, c1, by = "dept1")
data <- left_join(data, c2, by = "dept2")
# Prepare edge list data
gpt <- select(data, fac1, fac2, col1, col2)
edges_gpt <- gpt %>%
  group_by(fac1, fac2) %>%
  summarise(int = n(), .groups = 'drop')
# Unique colleges
unique_colleges <- unique(c(gpt$col1, gpt$col2))
# Define UI for Shiny app
header <- dashboardHeader(title = tagList(icon("paperclip"), "Collaboration"))
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Graphs A1", icon = icon("chart-bar"), tabName = "stats"),
    selectInput("college", "Select College(s):", choices = unique_colleges, selected = unique_colleges, multiple = TRUE)
    )
)

body <- dashboardBody(
  tabItems(
    tabItem("stats", fluidRow(
      column(width = 9, visNetworkOutput("network", height = "700px")),
      column(width = 3, uiOutput("legend"))  # Add this line for the legend
    ))
  )
)

# Define server for Shiny app
server <- function(input, output, session) {
  
  # Reactive value to store nodes and edges
  rv <- reactiveValues(nodes_df = NULL, edges_df = NULL)
  
  output$network <- renderVisNetwork({
    req(input$college)
    
    # Filter nodes and edges by selected college(s)
    selected_faculty <- gpt %>%
      filter(col1 %in% input$college | col2 %in% input$college)
    
    # Create filtered edge list
    filtered_edges <- edges_gpt %>%
      filter((fac1 %in% selected_faculty$fac1 & fac2 %in% selected_faculty$fac2) |
               (fac1 %in% selected_faculty$fac2 & fac2 %in% selected_faculty$fac1))
    
    # Create graph object
    g_gpt <- graph_from_data_frame(d = filtered_edges, directed = FALSE)
    
    # Define vertex attributes
    g_gpt_sum_coms <- cluster_louvain(g_gpt)
    V(g_gpt)$community <- g_gpt_sum_coms$membership
    
    # Assign colleges to nodes
    nodes <- selected_faculty %>%
      pivot_longer(cols = c(fac1, fac2), names_to = "fac_column", values_to = "name") %>%
      mutate(college = if_else(fac_column == "fac1", col1, col2)) %>%
      select(name, college) %>%
      distinct()
    V(g_gpt)$college <- nodes$college[match(V(g_gpt)$name, nodes$name)]
    
    # Ensure all nodes have a shape
    college_to_shape <- c("CoAg" = "star", "CoB" = "circle", "CoEd" = "plus",
                          "CoET" = "paperclip", "CoNHS" = "diamond", "Other" = "square")
    V(g_gpt)$shape <- college_to_shape[V(g_gpt)$college]
    
    # Create nodes and edges data frames for visNetwork
    rv$nodes_df <- data.frame(id = V(g_gpt)$name,
                              label = V(g_gpt)$name,
                              group = V(g_gpt)$community,
                              shape = V(g_gpt)$shape,
                              college=V(g_gpt)$college,
                              degree = degree(g_gpt),
                              betweenness = betweenness(g_gpt),
                              closeness = closeness(g_gpt),
                              eigenvector = eigen_centrality(g_gpt)$vector)
    
    rv$edges_df <- data.frame(from = filtered_edges$fac1,
                              to = filtered_edges$fac2,
                              width = filtered_edges$int)
    
    # Create visNetwork plot
    visNetwork(rv$nodes_df, rv$edges_df) %>%
      visNodes(color = list(background = "lightblue", border = "darkblue")) %>%
      visEdges(color = "orange") %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
      visInteraction(navigationButtons = TRUE) %>%
      visEvents(selectNode = "function(nodes) {
        var node = nodes.nodes[0];
        Shiny.onInputChange('selected_node', node);
      }")
  })
  
  # Create legend for community and college
  output$legend <- renderUI({
    req(rv$nodes_df)
    
    # Unique community and college names

    colleges <- unique(rv$nodes_df$college)
  
    college_to_shape <- c("CoAg" = "star", "CoB" = "circle", "CoEd" = "plus",
                          "CoET" = "paperclip", "CoNHS" = "diamond", "Other" = "square")
    
    # College Legend with shapes
    college_legend <- tags$div(
      tags$h4("College Legend"),
      lapply(names(college_to_shape), function(college) {
        tags$div(
          style = paste("padding: 5px;"),
          tags$span(college, style = "padding-left: 5px;"),
          tags$span(icon(college_to_shape[college]), style = paste("padding-left: 10px; font-size: 20px;"))
        )
      })
    )
    
    tags$div( college_legend)
  })
  
  
  observeEvent(input$selected_node, {
    req(rv$nodes_df)
    
    node_id <- input$selected_node
    node_data <- subset(rv$nodes_df, id == node_id)
    
    showModal(modalDialog(
      title = paste("Node Information:", node_data$label),
      
      # Adding spacing between elements using tags$br()
      tags$p(tags$strong("Name:"), node_data$label),
      tags$p(tags$strong("Degree:"), node_data$degree),
      tags$p(tags$strong("Betweenness:"), node_data$betweenness),
      tags$p(tags$strong("Closeness:"), round(node_data$closeness, 2)),
      tags$p(tags$strong("Eigenvector:"), round(node_data$eigenvector, 2)),
      tags$p(tags$strong("College:"), node_data$college),
      tags$p(tags$strong("Community:"), node_data$group),
      
      easyClose = TRUE,
      footer = NULL
    ))
    
  })
}


  # Create Shiny app
  ui <- dashboardPage(skin = "black", header, sidebar, body)
  shinyApp(ui, server)