# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tutorial 1: Basic Shiny App
# Demonstrates the basic structure of a Shiny application
#
# Author: Louise Ord
# Date: 14-01-2019
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 1. Global ----
# The part of the application that is outside the UI and the server is the global environment

# Source the shiny library
library(shiny)

# This variable contains the browser tab title
window_title <- "Tutorial 1: The Basic Shiny App"

# This variable contains the title of the application (left blank)
app_title <- ""

# This varibale contains the text above the input box that is used to inform the user
input_label <- "Enter the text to display below:" 

# 2. UI ----  
# The UI is the user interface -- it's what will appear in the browser window
ui <- fluidPage(
  
  # This is creates a title panel for the page and optionally titles the browser window 
  titlePanel(app_title, windowTitle = window_title),

  # This creates a text input control box that the user can type text into  
  textInput(inputId = "txt", label = input_label),
  
  # This prints verbatim the value of the output object "display_text"
  verbatimTextOutput(outputId = "display_txt", placeholder = TRUE)
)

# 3. Server ----
# The server function is called once per session and serves information from the computer hosting the app to the browser interfacing with it. 
# Any objects within this function are unique for a single session, including the input, output and session objects.
server <- function(input, output, session) {
  
  # This render function assigns the value of the output object "display_text" that is displayed in the UI.
  # The object is rendered as text.
  output$display_txt <- renderText({
    input$txt
  })
}

# 3. Call to the shinyApp function ----
shinyApp(ui = ui, server = server)