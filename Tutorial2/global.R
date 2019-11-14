# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global Environment
#
# Tutorial 2: Developing Shiny
# Demonstrates the basics of layout and reactivity in a Shiny App
#
# Author: Louise Ord
# Date: 14-01-2019
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The global environment is read in only once when the application starts.
# Here you call any libraries that are used by the application and read in and define any static variables 
# and functions.

# 1. Libraries ----
library(shiny)
library(data.table)

# 2. Data ----
# Our data is a data.table.
# A data.table is an enhanced version of a data.frame, which is the standard structure for storing data in R.
# In contrast to a data.frame, you can do a lot more than just subsetting rows and selecting columns within 
# a data.table.
dataset <- as.data.table(iris)

# 3. Colour palette ----
palette_blue <- c("#2585e6", "#1bd1d1", "#291780", "#007356", "#8e33a8", "#8f005b", "#a3faa3")
palette_red <- c("#ffca00", "#ff4019", "#910013")

