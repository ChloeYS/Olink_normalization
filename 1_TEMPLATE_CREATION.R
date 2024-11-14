# FILENAME: TEMPLATE_CREATION.R
#Last updated November 2024

#Usage: gets sourced by other files.

cat("\n\n\n\n###############################################################################################\n",
            "1. SOURCE PACKAGES AND FUNCTIONS\n",
            "###############################################################################################\n\n\n")

arg.vec <- commandArgs(trailingOnly = T) #Defines a vector of arguments. In this case, it is only one argument.  

source('Functions.R') #Source the functions from file in same repository (for now)

#load packages
library(OlinkAnalyze)


cat("\n\n\n\n###############################################################################################\n",
            "2. LOAD DATAFRAME\n",
            "###############################################################################################\n\n\n")


# #If getting end of line error or other bug related to csv reading:
# filepaths <- c("/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238A_Tartaglia_NPX_IPCnormalized2024-08-08.csv", #plate A raw data
#                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238B_Tartaglia_EXTENDED_NPX_2024-09-30_PCnormalized/Tartaglia_EXTENDED_NPX_2024-09-30.csv", #plate B raw data
#                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238C_Tartaglia_EXTENDED_NPX_2024-03-25_PC_normalized.csv", #plate C raw data
#                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.1_Simrika_Onedrive/Second_project_AD_HC/Sample_all_2ndproject.csv", #Sample to ID match from Simrika, clinic cases
#                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.1_Simrika_Onedrive/Third_project_Genetic_cases/Sample_template_3rd_olink.csv") #Sample to ID match from Simrika, genetic cases
#     filepaths_df <- data.frame(filepaths)
#     write.csv(filepaths_df, "1_filepaths.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 

#Read the csv that contains the pths to the plates
filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 


#Create the dfs by reading the files indicated by the csv: olink plate data
plateA_df <- read.func.csv(filepaths_df, 1, olink=TRUE)
plateB_df <- read.func.csv(filepaths_df, 2, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best
plateC_df <- read.func.csv(filepaths_df, 3, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best

#Create the dfs by reading the files indicated by the csv: sample equivalency based on Simrika's template files for Plates A & B
plateB_manifest_df <- read.func.csv(filepaths_df, 4, olink=FALSE) #clinic cases sample# to ID match key
plateC_manifest_df <- read.func.csv(filepaths_df, 5, olink=FALSE) #genetic cases sample# to ID match key
    
    # #DONT RUN!!! THIS IS TO CREATE A FILE THAT IS MANUALLY EDITED BEFORE NEXT STEPS
    #Script to create the plate ID list and then manually add IDs as missing the original manifest file for plate 1
    # plateA_template <- plateA_df[, c("SampleID", "Index", "PlateID")]
    # plateA_template <- plateA_template[!duplicated(plateA_template[c('SampleID')]), ]

    # plateB_template <- plateB_df[, c("SampleID", "Index", "PlateID")]
    # plateB_template <- plateB_template[!duplicated(plateB_template[c('SampleID')]), ]

    # plateC_template <- plateC_df[, c("SampleID", "Index", "PlateID")]
    # plateC_template <- plateC_template[!duplicated(plateC_template[c('SampleID')]), ]

    # template <- rbind(plateA_template, plateB_template, plateC_template)
    # write.csv(template, "platesA-C_template.csv")

#Create a df with all the matches between aliquot # and Tartaglia IDs
all_template_df <- read.func("platesA-C_template.csv", "all_template_df") #File with the Plate 1 TARTAGLIA IDs to which I'll add other IDs
all_template_df$SampleID <- as.character(all_template_df$SampleID)
plateB_manifest_df$SampleID <- as.character(plateB_manifest_df$SampleID)
plateC_manifest_df$SampleID <- as.character(plateC_manifest_df$SampleID)

#Merge plate B and plate A manifest
all_template_df <- left_join(all_template_df, plateB_manifest_df, by="SampleID")
all_template_df <- left_join(all_template_df, plateC_manifest_df, by="SampleID")

all_template_df <- all_template_df %>%
                    mutate(Freezer_ID= case_when(is.na(Freezer_ID.y)==FALSE ~ as.character(Freezer_ID.y),
                                      is.na(ID)==FALSE ~ as.character(ID),
                                      TRUE ~ as.character(Freezer_ID.x))) %>%
                    data.frame()

all_template_df <- subset(all_template_df, is.na(all_template_df$Freezer_ID)==FALSE)
all_template_df <- all_template_df[, c("Freezer_ID", "PlateID", "SampleID", "Index")]                                                         
    
    #DEFENSIVE CODING
    if (nrow(all_template_df)!=88*length(unique(all_template_df$PlateID))) {
        cat("Possible issue in merging as there is different number of total samples than expected: ", nrow(all_template_df),"\n")
    }

write.csv(all_template_df, "all_template_df.csv")
