# FILENAME: Functions.R

#Last updated October 2024
##Only kept functions useful for the CTE WMH manuscript


# USEFUL LIBRARIES #
library(tidyverse) #https://tidyverse.tidyverse.org/

# FUNCTIONS USED FOR PREPARATION OF OLINK DATA - SPECIFICALLY BETWEEN PLATES

## READ.FUNC() ##
##read.func is a function that assigns the data in a given file to a dataframe
#then prints the name of the file & returns the data.
read.func <- function(file, df.name) { #file is the name of a file in the same directory, and df.name is a character string
             if (!file.exists(file)) { #then we check that the input file exists
               stop("The first argument, data file, cannot be found.")
             } else {
                 df <- read.csv(file, header=T, na.strings="") #creates dataframe from file data
                 df <- filter(df, rowSums(is.na(df)) != ncol(df)) # Apply filter function in order to remove completely empty rows. Basically, only keeps rows for which the number of NAs is different from the number of columns
                 cat('The file:', file, 'is read into the dataframe:', df.name, '\n')
                 return(df) #if run independently, read.func will print the dataframe
               } #else
             }

## READ.FUNC.PATHS() ##
##read.func.csv takes a df with paths to files that need to be loaded as df
read.func.csv <- function(df, index, olink=FALSE) { #csv is a file containing paths, index is the row number i want to extract
             filepath_index <- df[index, c("filepaths")]
             if (olink==FALSE) {
             df <- read.func(filepath_index, "df")
              } else {
             df <- read_NPX(filepath_index)
              }
             return(df)
             }
