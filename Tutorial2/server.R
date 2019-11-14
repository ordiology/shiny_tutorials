# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Server Side Code
#
# Tutorial 2: Developing Shiny
# Demonstrates the basics of layout and reactivity in a Shiny App
#
# Author: Louise Ord
# Date: 14-01-2019
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


server <- function(input, output) {
  
  # 1. Reactive Functions ----
  
  # The reactive function selectedData() subsets the data according to the input x and y variables
  # This function therefore depends on the reactive variables input$xcol and input$ycol.
  # It will be run once when where it is first called when the application is opened and then only 
  # recalculates its output if the value of either input$xcol or input$ycol changes.
  selectedData <- reactive({
    
    # The next line can be uncommented for the purposes of debugging the code
    # print("Inside the selectedData reactive expression")
    
    # Writing things inside the square brackets of a data.table is like querying it, in analogy to SQL.
    # We can query a Subset of Data, .SD. 
    # .SD is by itself a data.table that holds the data for the current group that can be defined using 
    # a by condition. If no by condition is set, all the data is returned.
    # Here we are asking to return all data in the columns named input$xcol, input$ycol and "Species".
    dataset[, .SD, .SDcols = c(input$xcol, input$ycol, "Species")]
    
  })
  
  # The reactive function clusters() returns the output of the R stats k-means clustering function
  # This function depends on the reactive function selectedData() and the reactive variable input$clusters.
  # It will be run once where it is first called when the application is opened and then only recalculates 
  # its output if the value of either selectedData() or input$clusters changes.
  clusters <- reactive({
    
    # The next line can be uncommented for the purposes of debugging the code
    # print("Inside the clusters reactive expression")
    
    # kmeans() takes as input the data that is columns 1 to 2 of the reactive function selectedData() 
    # and the number of centers that is.
    kmeans(selectedData()[,1:2], centers=input$clusters)
  })
  
  # 2. Render Functions ----
  # Render functions are a type of reactive function. They execute once when the application opens and then will 
  # recompute when reactive variables inside them change value
  
  # The variable output$kmeans is the output of a render function that creates a plot of height 290px
  output$kmeans <- renderPlot(height = 290, {

    # The next line can be uncommented for the purposes of debugging the code
    # print("Inside the kmeans render plot function")
    
    # This plot is written in base R but could be replaced with a ggplot function instead

    # The par function allows base R plotting functions to be explored or set
    # Here we set the margins of the plot (mar) and the amount relative to the default that all text
    # and symbols should be scaled by (cex)
    par(mar = c(5.1, 4.1, 0, 1), cex = 1.5)

    # This plots the data using closed circle symbols (pch) and selecting the colour (col) for each point depending 
    # on its given cluster. The colour palette (palette_blue) is pre-defined in the global environment.
    plot(selectedData()[,1:2], col =  palette_blue[clusters()$cluster], pch = 19)

    # Points are overlayed for each cluster center. These points are plotted as crosses of line width lwd and
    # scaled once again (cex)
    points(clusters()$centers, pch = 4, lwd = 4, cex = 2)

  })

  # The variable output$species is the output of a render function that creates a plot of height 290px
  output$species <- renderPlot(height = 290, {

    # The next line can be uncommented for the purposes of debugging the code
    # print("Inside the species render plot function")
    
    # The top margin is widened to allow placement of a legend
    par(mar = c(5.1, 4.1, 0, 1), cex = 1.5)
    # This plot is similar to the one above but the points are now coloured by species using the pre-defined 
    # palette palette_red
    plot(selectedData()[,1:2], col =  palette_red[selectedData()[, as.numeric(Species)]], pch = 19)
    
    # The mean value for each of the chosen x and y variables is determined by species and then the "Species" 
    # column is removed from the data
    species_means <- selectedData()[, lapply(.SD, mean), .SDcols = names(selectedData()[, 1:2]), 
                                    by="Species"][, Species := NULL]
    # Crosses are plotted for these mean values by species
    points(species_means, pch = 4, lwd = 4, cex = 2)

  })
  
  # The species legend could be included in the species plot above but that plot rerenders each time the 
  # x and y variables change. This means the legend is redrawn every time the user interacts with the app. 
  # By making the legend a separate render plot, it becomes static as it doesn't depend on any reactive 
  # variables and is therefore drawn just once.
  output$legend <- renderPlot(height=20, {

    # The next bit is over plotted (new=T) and can be rendered outside the boundary of the plot (xpd=T)    
    par(mar=c(0,0,0,0))
    
    # An empty chart is plotted with limits from 0 to 1. Coordinates can easily determined in this plot frame.
    plot(x=NA, y=NA, xlim=c(0,1), ylim=c(0,1), xlab="", ylab = "", axes = F)
    
    # The legend is plotted in the centre right of the chart. It contains a point for each species name in
    # the corresponding colour. The legend is laid out in a 3 column grid (ncol) and does not have a box 
    # around it (bty="n"). The legend text and colour palette are reversed (rev()) for aesthetic reasons.
    legend("right", legend = rev(levels(dataset[, Species])), text.width = 0.125, col = rev(palette_red), 
           pch = 19, bty = "n", ncol=3, cex = 1.25)
    
  })
  
  # The variable output$table is assigned to be the output of a render function that creates a table
  # from the selectedData() with an additional Cluster column
  output$table <- renderTable({
    data.table(selectedData(), Cluster = clusters()$cluster)
  })
  
  
  # Some text in the UI must be delivered through functions on the server side as what is displayed depends on
  # the current values of reactive variables
  
  # The variable output$size is assigned to be the output of a render function that is text
  output$size <- renderPrint({
    # This text is html formatted using an h3 header tag
    h3(input$clusters, "k-means clusters of size:", paste(clusters()$size, collapse=", "))
  })

  # The variable output$means is assigned to be the output of a render function that is text
  output$means <- renderPrint({
    # This returns the mean x and y values by cluster
    clusters()$centers   
  })
  
  # A Cluster column is added to the selected data and it is cast as a data.table that contains a count by species 
  # and cluster
  output$separation <- renderPrint({
    dcast(data.table(selectedData(), Cluster = clusters()$cluster)[, .(count = .N), by=.(Species, Cluster)], 
          Species~Cluster, value.var="count")
  })
  
  # This is the within cluster sum of squares
  output$withinss <- renderPrint({
    clusters()$withinss
  })
  
  # This is the between cluster sum of squares as a percentage of the total sum of squares
  output$btwnssVtotss <- renderPrint({
    h4("Between cluster sum of squares / total sum of squares = ", 
       paste0(round(clusters()$betweenss/clusters()$totss*100, digits=2), "%"))
  })
}