# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# User Interface
#
# Tutorial 2: Developing Shiny
# Demonstrates the basics of layout and reactivity in a Shiny App
#
# Author: Louise Ord
# Date: 14-01-2019
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Define user interface (UI) for application that plots random distributions 
ui <- fluidPage(
  
  # Application title
  # This is given the html header tag h1 so that it is formatted as a primary heading. 
  # There are other header tags in HTML too, like h2, h3, h4... these are used variously in these tutorials.
  titlePanel(h1("Classifying iris flowers with k-means clustering"), windowTitle = "Tutorial 2: Developing Shiny"),

  # Help text can be used to inform the user and can take html tags for formatting; 
  # tags$em marks text that has a stress emphasis.
  helpText(h5("Edgar Anderson's 1936 iris data has intrigued scientists for decades. The data was assembled 
              by Anderson in 1935 and famously analysed by Roger Fisher in his 1936 paper", 
              tags$em("The use of multiple measurements in taxonomic problems."), 
              "The data set consists of 50 samples from each of three species of Iris (Iris setosa, Iris 
              virginica and Iris versicolor). Four features were measured from each sample; the length and 
              the width of the sepals and petals, in centimetres. Based on the combination of these four 
              features, Fisher developed a linear discriminant model to distinguish the species from each other.")),
  
  helpText(h4("Explore how well k-means clustering distinguishes these species of iris:")),
  
  # The Shiny sidebar layout function expects a sidebar panel and main panel as input
  sidebarLayout(

    # The sidebar is the control centre for application inputs
    # In Shiny, the width of an area is a maximum of 12. So by specifying width=4 for the sidebar panel,
    # we are telling Shiny it needs to take up 1/3 of the available space.
    sidebarPanel(width=4,
                 
      # This creates a select input drop down menu control box that the user can choose from
      # The column heading names for all columns in the dataset except the "Species" column are used for the 
      # input variables
      selectInput(inputId = "xcol", label = "X Variable", choices = names(dataset[, -c("Species")])),
      # In this next select input control box, the second column name is chosen to be the default selected value 
      # rather than the first
      selectInput(inputId = "ycol", label = "Y Variable", choices = names(dataset[, -c("Species")]), selected = names(dataset)[2]),
      
      # This creates a numeric select input drop down menu control box
      # Maximum and minimum values are fixed at 1 and 7 respectively and the default selected value is set to be 3.
      numericInput(inputId = "clusters", label = "Cluster count", value = 3, min = 2, max = 7),
      
      # This submitButton is optional. 
      # When submitButton is present, the user's input to the ui is actioned when the button is pressed.
      # Task: See what happens to the application when you comment out this submitButton 
      # (remember to also comment out the comma from the line above).
      submitButton(text = "Apply Changes")
    ),
    
    # The main panel of the sidebar layout contains the body of the application
    mainPanel(
      
      # TabsetPanel() is a Shiny layout function that creates a set of tabs.
      # The function takes a function for each tab panel as input.
      tabsetPanel(
        
        # This first tab panel is defined using the tabPanel() function and is titled "Plots"
        tabPanel("Plots",
                 
                 # Horizontal space in a Shiny app can be split into fluidRows; each row will size to its content
                 fluidRow(
                   
                   # Vertical space can be split into columns; 
                   # How much of the width of a Shiny element is allocated to each column can be specified.
                   
                   # This column takes up half the available space; 6 out of a total of 12
                   column(6,
                          
                          # Headings can be placed anywhere in a Shiny UI
                          h4("K-means clusters:"),
                          
                          # This is an output function that creates the plot output$kmeans
                          # It is sized at height 350px
                          plotOutput("kmeans", height = "290px")
                   ),

                   column(6,
                          
                          h4("Species:"),
                          plotOutput("species", height = "290px")
                   )
                 ),
 
                 # The legend is placed in its own fluid row below the plots                
                 fluidRow(
                   plotOutput("legend", height = "20px")
                 )
        ),
        
        # The second tab panel is titled "Table" and displays output$table
        tabPanel("Table", tableOutput("table")),
        
        # The final tab panel is titled "Summary" and contains summary statistics text
        tabPanel("Summary", 
                 
                 fluidRow(
                   
                   column(12,
                          
                          # This text output function is expecting output$size to contain html formatted text 
                          htmlOutput("size")
                   )
                 ),
                 fluidRow(
                   
                   column(6,
                          h4("Cluster means:"),
                          
                          # output$means is printed verbatim
                          verbatimTextOutput("means")
                   ),
                   
                   column(6,
                          h4("Cluster separation by species:"),
                          verbatimTextOutput("separation")
                   )
                 ),
                 
                 fluidRow(
                   column(12,
                          h4("Within cluster sum of squares by cluster:"),
                          verbatimTextOutput("withinss")
                   )
                 ),
                 
                 fluidRow(
                   column(12,
                          htmlOutput("btwnssVtotss")
                   )
                 )
                 
        )
      )
    )
  )
)