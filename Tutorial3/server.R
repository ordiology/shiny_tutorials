# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Server Side Code
#
# Tutorial 3: Customising Shiny
# Demonstrates the customisation of a Shiny App, explores
# reactivity and introduces DT (DataTable.js).
#
# Author: Louise Ord
# Date: 13-02-2019
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


server <- function(input, output) {
  
  # 1. Reactive Functions ----
  
  # Subset the data according to the input x and y variables
  selectedData <- reactive({
    
    # Return all data in the columns named input$xcol, input$ycol and "Species".
    dataset[, .SD, .SDcols = c(input$xcol, input$ycol, "Species")]
    
  })
  
  # k-means clustering function
  clusters <- reactive({
    kmeans(selectedData()[,1:2], centers=input$clusters)
  })
  
  # Collate all the summary stats into a table  
  summaryStats <- reactive({
    
    # Create a table of counts by cluster with a column for each species
    count_table  <- data.table::dcast(data.table(selectedData(), cluster = clusters()$cluster),
                                      cluster ~ factor(Species),
                                      drop = FALSE, # Keep missing levels in output
                                      fill = 0L, # Fill missing values with zeroes instead of NAs
                                      fun = length, # Count
                                      value.var = "cluster") # Value to count
    
    
    # Change the name of the species columns
    data.table::setnames(count_table, c("setosa", "versicolor", "virginica")[c("setosa", "versicolor", "virginica") %in% names(count_table)], 
                         c("Setosa Count", "Versicolor Count", "Virginica Count")[c("setosa", "versicolor", "virginica") %in% names(count_table)])
    
    # Create a summary table that merges the count_table onto cluster statistics
    summary_table <- data.table(cluster = seq(1:input$clusters), Size = clusters()$size, clusters()$centers, 
                                `Within Cluster SS` = clusters()$withinss, 
                                key = "cluster")[count_table][, -c("cluster")]
 
    print("hello")
    print(summary_table)
    
       
    # Change the name of the x and y variable columns
    data.table::setnames(summary_table, 2:3, paste0("Average ", names(summary_table[, 2:3])))
    
    # Quote columns 2 to 4 to 3 significant figures
    summary_table[ , (2:4) := lapply(.SD, function(x) format(round(x, 1), nsmall = 1)), .SDcols = 2:4]
    
    # Transpose the table -- using data.frame because it maintains row names    
    summary_table <- t(as.data.frame(summary_table))
    
    # Change the column names 
    colnames(summary_table) <- seq(1:input$clusters)
    
    colnames(summary_table) <- paste0('<span style="color:', palette_blue[1:input$clusters],'">', colnames(summary_table),'</span>')
    
    
    # Return the table
    return(summary_table)
  })
  
  
  # 2. Render Functions ----
  
  ### Create renderUI functions for iris images sized to available space
  
  # Setosa
  output$setosa <- renderUI({ 
    HTML('<center><img src="images/iris_setosa_baby_blue.jpg" width=100%></center>')
  })
  # Versicolor
  output$versicolor <- renderUI({ 
    HTML('<center><img src="images/iris_versicolor_kermesina.jpg" width=100%></center>')
  })
  # Virginica
  output$virginica <- renderUI({ 
    HTML('<center><img src="images/iris_virginica_sumpfprinzessin.jpg" width=100%></center>')
  })
  
  
  ### Plots
  
  # Iris data plot, coloured by k-means cluster
  output$kmeans <- renderPlot(height = 380, {
    
    # Set the margins of the plot (mar) and the amount relative to the default that all text
    # and symbols should be scaled by (cex)
    par(mar = c(4.6, 4.1, 0, 1), cex = 1.5)
    
    # This plots the data using closed circle symbols (pch) and selecting the colour (col) for each point depending 
    # on its given cluster. The colour palette (palette_blue) is pre-defined in the global environment.
    plot(selectedData()[,1:2], col =  palette_blue[clusters()$cluster], pch = 19)
    
    # highlight the selected rows from the table
    s = input$table_rows_selected
    if (length(s)) points(selectedData()[,1:2][s, , drop = FALSE], pch = 1, lwd = 4, 
                          cex = 1.6, col = "#cc0081")    
    
    
    # Points are overlayed for each cluster center. These points are plotted as crosses of line width lwd and
    # scaled once again (cex)
    if (length(clusters())) points(clusters()$centers, pch = 4, lwd = 4, cex = 2)
    
  })
  
  # Iris data plot, coloured by species
  output$species <- renderPlot(height = 380, {
    
    # The top margin is widened to allow placement of a legend
    par(mar = c(4.6, 4.1, 0, 1), cex = 1.5)
    # This plot is similar to the one above but the points are now coloured by species using the pre-defined 
    # palette palette_red
    plot(selectedData()[,1:2], col =  palette_red[selectedData()[, as.numeric(Species)]], pch = 19)
    
    # highlight the selected rows from the table
    s = input$table_rows_selected
    if (length(s)) points(selectedData()[,1:2][s, , drop = FALSE], pch = 1, lwd = 4, 
                          cex = 1.6, col = "#cc0081")    
    
    # The mean value for each of the chosen x and y variables is determined by species and then the "Species" 
    # column is removed from the data
    species_means <- selectedData()[, lapply(.SD, mean), .SDcols = c(input$xcol, input$ycol), 
                                    by="Species"][, Species := NULL]
 
    # Crosses are plotted for these mean values by species
    points(data.table(species_means[, .SD, .SDcols = input$xcol], 
                      species_means[, .SD, .SDcols = input$ycol]), pch = 4, lwd = 4, cex = 2)
    
  })
  
  # The species legend 
  output$legend <- renderPlot(height=20, {
    
    # The next bit is over plotted (new=T) and can be rendered outside the boundary of the plot (xpd=T)    
    par(mar=c(0,0,0,0))
    
    # An empty chart is plotted with limits from 0 to 1. Coordinates can easily determined in this plot frame.
    plot(x=NA, y=NA, xlim=c(0,1), ylim=c(0,1), xlab="", ylab = "", axes = F)
    
    # The legend is plotted in the centre of the chart. It contains a point for each species name in
    # the corresponding colour. The legend is laid out in a 3 column grid (ncol) and does not have a box 
    # around it (bty="n"). The legend text and colour palette are reversed (rev()) for aesthetic reasons.
    legend("center", legend = rev(levels(dataset[, Species])), text.width = 0.125, col = rev(palette_red), 
           pch = 19, bty = "n", ncol=3, cex = 1.25)
    
  })
  
  ### Input data table
  
  # The variable output$table is assigned to be the output of a render function that creates a table
  # from the selectedData() with an additional Cluster column
  output$table <- DT::renderDT({
    table_data <- data.table(selectedData(), Cluster = clusters()$cluster)
    datatable(table_data,
              style = 'Bootstrap',  # Bootstrap style
              class = 'table-condensed', # Condensed format
              filter = 'top', # Add column filter boxes to the top of the table
              options = list(
                pageLength = 6, # Sets the page length to 6 entries 
                dom='tp', # Shows the table and then pagination options
                columnDefs = list(
                  list(width = '20%', targets = '_all') # All columns are 20% of the available width
                ) 
              ),  
              colnames = c('K-means Cluster' = 'Cluster'), # Rename the Cluster column to 'K-means Cluster'
              escape = FALSE # For html formatting
    ) %>% 
    formatStyle('K-means Cluster',
                color = styleEqual(seq(1:input$clusters), palette_blue[1:input$clusters]),
                fontWeight = 'bold'
    ) %>% 
    formatStyle('Species',
                color = styleEqual(levels(dataset[, Species]),  palette_red),
                fontWeight = 'bold'
    ) 
  }, server = FALSE)
  

  # Table Proxy
  # The function datatableProxy() creates a proxy object that can be used to manipulate an existing DataTables 
  # instance in a Shiny app
  table_proxy = DT::dataTableProxy('table')
    
  ### Summary Stats

  # Render summary stats table
  output$summary <- DT::renderDT({
      summaryStats()
    },
    style = 'Bootstrap',  # Bootstrap style
    class = 'table-condensed', # Condensed format
    selection = 'none', # Disable row selection
    escape = F, # For html formatting
    options = list(
      dom='t', # Shows just the table
      ordering = F # disable column ordering
    ),
  server = FALSE)
  
  # Cluster count
  output$count <- renderPrint({
    HTML("Statistics for ", input$clusters, " k-means clusters")
  })
  
  
  # Between cluster sum of squares as a percentage of the total sum of squares
  output$btwnssVtotss <- renderPrint({
    h4("Between cluster sum of squares / total sum of squares = ", 
       paste0(round(clusters()$betweenss/clusters()$totss*100, digits=2), "%"))
  })
  
  
  # 3. Event handlers ----
  
  # Event handlers observe changes to reactive elements and trigger an action

  # This event handler observes any changes to the clear selections button and removes any row selections in the
  # table
  observeEvent(input$clear_selections, {
    # The next two lines can be uncommented for the purposes of debugging the code
    # print("I've clicked on the clear selections button:")
    # print(input$clear_selections)
    table_proxy %>% DT::selectRows(NULL)
  })
  
}