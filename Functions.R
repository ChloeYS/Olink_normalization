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



## FUNCTION TO CREATE DEMO JUST FOR GENETIC FTLD RAVE DATA
var.func.geneticALLFTD <- function(dfids, dfdemo) {

  ##Select the variables of interest (fixed)
  dfids <- dfids[, c("SampleID", "Barcode", "ID", "Alternate_MRN", "PROJECTID")]

  ##Get rid of duplicate rows/ keep only one row of fixed variables (ie demographic) per subject
  dfids <- unique(dfids) 

  ##Reorganize the variable columns
  dfids <- dfids[, c("ID", "SampleID", "Barcode", "Alternate_MRN", "PROJECTID")]

  ##Rename the variables
  colnames(dfids)[colnames(dfids) == 'SampleID'] <- 'AliquotNumber'
  colnames(dfids)[colnames(dfids) == 'ID'] <- 'Freezer_ID'

  ##Select the variables of interest (fixed)
  dfdemo <- dfdemo[, c("SMS_SUBJECT_ID", "CLINICAL_EVENT", "RUNDATE", "DID", "FAMILY_GENE", "GENETIC_STATUS", "SEX", "RACE", "RACEX", "HISPANIC_V3", "AGE_AT_VISIT_RNG", "AGE_AT_ONSET_RNG", "PRIM_CLIN_PHENO", "FREEZE")]

  ##Get rid of duplicate rows/ keep only one row of fixed variables (ie demographic) per subject
  dfdemo <- unique(dfdemo) 

  ##Reorganize the variable columns
  dfdemo <- dfdemo[, c("SMS_SUBJECT_ID", "DID", "CLINICAL_EVENT", "FAMILY_GENE", "GENETIC_STATUS", "SEX", "RACE", "RACEX", "HISPANIC_V3", "AGE_AT_VISIT_RNG", "AGE_AT_ONSET_RNG", "PRIM_CLIN_PHENO", "FREEZE", "RUNDATE")]

  ##Rename the variables
  colnames(dfdemo)[colnames(dfdemo) == 'SMS_SUBJECT_ID'] <- 'Alternate_MRN'
  colnames(dfdemo)[colnames(dfdemo) == 'DID'] <- 'Alternate_ID_DID'

  #dfids is longer as it contains all the samples metadata. dfdemo only contains the clinical data of the RAVE IDs. 
  #Therefore we perform a left join using the overlapping variable Alternate_MRN which is complete only in dfids but not dfdemo
  dfdemo <- left_join(dfids, dfdemo, by=c("Alternate_MRN")) 

  #Get rid of the bridging samples
  dfdemo<- dfdemo %>% filter(!str_detect(Alternate_MRN, 'Bridging'))

  return(dfdemo)

} #var.func.geneticALLFTD
