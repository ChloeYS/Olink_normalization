# FILENAME: BRIDGE_NORMALIZATION.R
#Last updated October 2024

#Usage: gets sourced by other files.

cat("\n\n\n\n###############################################################################################\n",
            "1. SOURCE PACKAGES AND FUNCTIONS\n",
            "###############################################################################################\n\n\n")

arg.vec <- commandArgs(trailingOnly = T) #Defines a vector of arguments. In this case, it is only one argument.  

source('Functions.R') #Source the functions from file in same repository (for now)

#load packages



cat("\n\n\n\n###############################################################################################\n",
            "2. LOAD DATAFRAME\n",
            "###############################################################################################\n\n\n")

    #If getting end of line error or other bug related to csv reading:
    # filepaths <- c("/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238A_Tartaglia_NPX_IPCnormalized2024-08-08.csv",
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238B_Tartaglia_EXTENDED_NPX_2024-09-30_PCnormalized/Tartaglia_EXTENDED_NPX_2024-09-30.csv",
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238C_Tartaglia_EXTENDED_NPX_2024-03-25_PC_normalized.csv")
    # filepaths_df <- data.frame(filepaths)
    # write.csv(filepaths_df, "filepaths.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 

filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 

plateA_df <- read.func.csv(filepaths_df, 1)
plateB_df <- read.func.csv(filepaths_df, 2)
plateC_df <- read.func.csv(filepaths_df, 3)



# write.csv(df, "dataframe.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 

