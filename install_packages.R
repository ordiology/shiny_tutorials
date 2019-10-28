#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Package installation script: Installs all packages required by the application
# 
# Author: Louise Ord
# Date: 11-01-2019
#
# Last modified by: Louise Ord
# Date: 11-01-2019
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Packages to install
pkg <- c("data.table", "shiny", "shinydashboard", "DT")

# If packages aren't alread installed, install most recent version of packages
new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
if (length(new.pkg)) {
  print("Installing pkg list")
  install.packages(new.pkg, dependencies = TRUE)
}