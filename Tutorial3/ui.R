# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# User Interface
#
# Tutorial 3: Customising Shiny
# Demonstrates the customisation of a Shiny App, explores
# reactivity and introduces DT (DataTable.js).
#
# Author: Louise Ord
# Date: 13-02-2019
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Define user interface (UI) for application that plots random distributions
ui <- # This layout uses the shiny dashboards package
  shinydashboard::dashboardPage(
    title = "Tutorial 3: Customising Shiny",
    
    
    
    # 1. Header bar ----
    shinydashboard::dashboardHeader(title = "Classifying Iris Flowers",
                    titleWidth = "220px"),
    
    
    # 2. Sidebar ----
    shinydashboard::dashboardSidebar(
      width = "220px",

      # Horizontal row line
      hr(), 
      
      # 2.1. Sidebar menu ----
      shinydashboard::sidebarMenu(
        id = "sbmenu",
        # Introduction tab  ----
        shinydashboard::menuItem("Anderson's Iris Data", icon = icon("info"), tabName = "tab0"),
        # Statistics tab  ----
        shinydashboard::menuItem("Clustering Statistics", icon = icon("chart-bar"), tabName = "tab1")
      ),
      
      hr(),
      
      fluidRow(
        align = "center",
        # This creates a select input drop down menu control box that the user can choose from
        # The column heading names for all columns in the dataset except the "Species" column are used for the
        # input variables
        selectInput(
          inputId = "xcol",
          label = "X Variable",
          choices = names(dataset[, -c("Species")]),
          width = "70%"
        ),
        # In this next select input control box, the second column name is chosen to be the default selected value
        # rather than the first
        selectInput(
          inputId = "ycol",
          label = "Y Variable",
          choices = names(dataset[, -c("Species")]),
          selected = names(dataset)[2],
          width = "70%"
        ),
        # This creates a numeric select input drop down menu control box
        # Maximum and minimum values are fixed at 1 and 7 respectively and the default selected value is set to be 3.
        numericInput(
          inputId = "clusters",
          label = "Cluster count",
          value = 3,
          min = 2,
          max = 7,
          width = "70%"
        )
      ),
      br(),
      tags$hr(),
      fluidRow(align = "center",
               actionButton("clear_selections", "Clear Selections")
      ),
      
      hr()
    ),
    
    # 3. Body ----
    shinydashboard::dashboardBody(
      
      # 3.0. Include custom css ----
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
      
      # 3.1. Tab items ----
      #      These are referenced in the sidebar menu.
      tabItems(
        
        # 3.1.1 Introduction ----
        tabItem(
          tabName = "tab0",
          
          fluidRow(
            shinydashboard::box(
              title = "Anderson's iris data",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              h3(
                "Edgar Anderson's 1936 iris data has intrigued scientists for decades. The data was assembled
                by Anderson in 1935 and famously analysed by Roger Fisher in his 1936 paper",
                tags$em("The use of multiple measurements in taxonomic problems.")
              ),
              h3(
                "The data set consists of 50 samples from each of three species of Iris (Iris setosa, Iris virginica and Iris versicolor).
                Four features were measured from each sample; the length and the width of the sepals and petals, in centimetres.
                Based on the combination of these four features, Fisher developed a linear discriminant model to distinguish the species
                from each other."
              )
            )
            
          ),
          
          fluidRow(
            shinydashboard::box(title = 'Iris setosa "Baby Blue"',
              status = "primary",
              align = "center",
              solidHeader = TRUE,
              width = 4,
              uiOutput("setosa")
                
            ),
            shinydashboard::box(
              title = 'Iris versicolor "Kermesina"',
              status = "primary",
              align = "center",
              solidHeader = TRUE,
              width = 4,
              uiOutput("versicolor")
            ),
            shinydashboard::box(
              title = 'Iris virginica "Sumpfprinzessin"',
              status = "primary",
              align = "center",
              solidHeader = TRUE,
              width = 4,
              uiOutput("virginica")
            )
          )
          
        ),
        
        # 3.1.2 Statistics ----
        tabItem(tabName = "tab1",
                
                fluidRow(
                  # This box takes up half the available space; 6 out of a total of 12
                  shinydashboard::box(
                    width = 6,
                    height = 463,
                    title = "K-means cluster chart",
                    status = "primary",
                    solidHeader = TRUE,
                    align = "center",
                    
                    plotOutput("kmeans", height = "380px")
                  ),
                  shinydashboard::box(
                    width = 6,
                    title = "Species chart",
                    status = "primary",
                    solidHeader = TRUE,
                    align = "center",
                    plotOutput("species", height = "380px"),
                    
                    #  The legend is placed in its own plotOutput below the plots
                    plotOutput("legend", height = "20px")
                    
                    
                  )
                ),
                fluidRow(
                  shinydashboard::box(
                    width = 6, height = 415,
                    title = "Data",
                    status = "primary",
                    solidHeader = TRUE,
                    align = "center",
                    DT::DTOutput("table")
                  ),
                  
                  shinydashboard::box(
                    width = 6, height = 415,
                    title = htmlOutput("count"),
                    status = "primary",
                    solidHeader = TRUE,
                    align = "center",
                    DT::DTOutput("summary"),
                    
                    hr(),
                    
                    htmlOutput("btwnssVtotss")
                    
                  )
                  
                )
            ) # End tabItem()
        ) # End tabItems()
    ) # End shinydashboard::dashboardBody()
  ) # End shinydashboard::dashboardPage()
