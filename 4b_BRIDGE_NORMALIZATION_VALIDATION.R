# FILENAME: BRIDGE_NORMALIZATION_VALIDATION.R
#Last updated October 2024

#Usage: not sourced by other files

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
	# ##To run only without the arg.vec part in bash Run_ script, or directly on the Rscript
	# filepaths <- c("/Users/nikhilbhagwat/projects/git_repos/Olink_normalization/AtoC_bridged_PC.csv",
	# 				"/Users/nikhilbhagwat/projects/git_repos/Olink_normalization/BtoC_bridged_PC.csv") #Template file with all TARTAGLIA ID to Aliquot ID (=SAMPLEID) match keys

	# filepaths_df <- data.frame(filepaths)
	# write.csv(filepaths_df, "filepaths_validation.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 

#Read the csv that contains the pths to the plates
filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 

#Create the dfs by reading the files indicated by the csv: olink plate data
plateAtoC_df <- read.func.csv(filepaths_df, 1, olink=TRUE) #the bridged dataset is not identified as an NPX file by read_NPX()
plateBtoC_df <- read.func.csv(filepaths_df, 2, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best


cat("\n\n\n\n###############################################################################################\n",
            "3. \n",
            "###############################################################################################\n\n\n")

# PCA plot
olink_pca_plot(df = plateAtoC_df, color_g = "Type", byPanel= TRUE)	