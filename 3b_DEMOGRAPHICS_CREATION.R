# FILENAME: BRIDGE_NORMALIZATION_PCdata.R
#Last updated October 2024

#Usage: to create the bridged data files, sources other files and output csv is sourced by other files.

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
    
#Read the filepaths created by 1_TEMPLATE_CREATION.R script

#Read the csv that contains the pths to the plates
filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 

#Create the dfs by reading the files indicated by the csv: olink plate data
local_data_simrika_df <- read.func.csv(filepaths_df, 4, olink=FALSE)
gen_data_simrika_df <- read.func.csv(filepaths_df, 5, olink=FALSE)
local_data_chloe_df <- read.func.csv(filepaths_df, 6, olink=FALSE)
all_template_df <- read.func.csv(filepaths_df, 7, olink=FALSE)


cat("\n\n\n\n###############################################################################################\n",
            "3. CLEAN THE DATA FROM SIMRIKA FIRST\n",
            "###############################################################################################\n\n\n")
    

# colnames(ftld_demo)
#  [1] "ID_main"                     "IDs_same_tp"                
#  [3] "IDs_other_tps"               "Lifetime_CSF"               
#  [5] "Included_Olink"              "Name"                       
#  [7] "MRN"                         "Included_APD_MS"            
#  [9] "Primary_DX_clin_final"       "Primary_DX_clin_visit"      
# [11] "Clinical_DX_additional"      "DX_PPA_lifetime"            
# [13] "Evidence_AD_lifetime"        "Evidence_AD_notes"          
# [15] "CSF.AD_visit"                "CSF_ptau_visit"             
# [17] "CSF_ttau_visit"              "CSF_abeta42_visit"          
# [19] "CSF_ATI_visit"               "Evidence_ASYN_lifetime"     
# [21] "ASYN.SAA_visit"              "Postmortem_primary"         
# [23] "Postmortem"                  "Genetics_FamilyHistory"     
# [25] "APOEe4_alleles"              "Death_age"                  
# [27] "Sex"                         "Race_ethnicity"             
# [29] "DOB_dd.mmmm.yy"              "ID_Date_dd.mmmm.yy"         
# [31] "Onset_age"                   "Onset_type"                 
# [33] "Education"                   "NFL_visit"                  
# [35] "GFAP_visit"                  "YKL40_visit"                
# [37] "First_Visit_Date_dd.mmmm.yy" "Last_Visit_Date_dd.mmmm.yy" 
# [39] "Arthritis"                   "WMH_PV"                     
# [41] "WMH_D"                       "CDR_original_SOB"           
# [43] "CDR_original_Total"          "PSPRS_visit"                
# [45] "MOCA_visit_1yrmax"           "MOCA_visit_1yrmax_zscore"   



# cat("\n\n\n\n###############################################################################################\n",
#             "4. CLEAN THE HC AND AD DEMOGRAPHIC FILE\n",
#             "###############################################################################################\n\n\n")
    







