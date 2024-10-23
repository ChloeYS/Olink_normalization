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
            "3. CLEAN THE DATA FROM CHLOE FIRST\n",
            "###############################################################################################\n\n\n")

#Only keep the subjects included in Olink
local_data_chloe_df <- local_data_chloe_df[, c("ID_main",
                                                "Primary_DX_clin_final", "Primary_DX_clin_visit","DX_PPA_lifetime",
                                                "Evidence_AD_lifetime", "CSF.AD_visit", "CSF_ptau_visit","CSF_ttau_visit", "CSF_abeta42_visit",
                                                "CSF_ATI_visit","Evidence_ASYN_lifetime", "ASYN.SAA_visit", "Postmortem_primary","Genetics_FamilyHistory",
                                                 "APOEe4_alleles", "Sex", "Race_ethnicity",
                                                 "DOB_dd.mmmm.yy","ID_Date_dd.mmmm.yy", "Onset_age",  "Onset_type",
                                                 "Education", "NFL_visit","GFAP_visit", "YKL40_visit",
                                                "Arthritis","WMH_PV","WMH_D", "CDR_original_SOB","CDR_original_Total",
                                                "PSPRS_visit","MOCA_visit_1yrmax_zscore")]          

#Rename columns in chloe's file
colnames(local_data_chloe_df)[which(names(local_data_chloe_df) == "ID_main")] <- "Freezer_ID"

if (sum(local_data_chloe_df$Freezer_ID %in% all_template_df$Freezer_ID)<67) {
    cat("Check that the subject IDs in clinical files match the ones in the Olink dataset or use grep\n")
}


#Merge with the template file
demographics_df <- left_join(all_template_df,local_data_chloe_df, by="Freezer_ID")

#For tonight, I will create a file with just the FTLD data and do analyses within the FTLD. Will create a demographic file that gets
##read in the analysis script. But tht demographic file can be easily replaced by the version with HC in the future.
#Tomorrow, first step would be to add the HC and rerun the analysis this time with the HC and AD subjects. 

###################################################################
##THIS IS WHERE THE INCORPORATION OF THE HC AND AD SHOULD HAPPEN
###################################################################

cat("\n\n\n\n###############################################################################################\n",
            "4. FORMAT THE VARIABLES\n",
            "###############################################################################################\n\n\n")

#Format properly the different variables:

##Categorical variables
demographics_df$Freezer_ID <- as.factor(demographics_df$Freezer_ID)
demographics_df$PlateID <- as.factor(demographics_df$PlateID)
demographics_df$Index <- as.factor(demographics_df$Index)
demographics_df$Primary_DX_clin_final <- as.factor(demographics_df$Primary_DX_clin_final)
demographics_df$Primary_DX_clin_visit <- as.factor(demographics_df$Primary_DX_clin_visit)
demographics_df$DX_PPA_lifetime <- as.factor(demographics_df$DX_PPA_lifetime)
demographics_df$Evidence_AD_lifetime <- as.factor(demographics_df$Evidence_AD_lifetime)
demographics_df$CSF.AD_visit <- as.factor(demographics_df$CSF.AD_visit)
demographics_df$Evidence_ASYN_lifetime <- as.factor(demographics_df$Evidence_ASYN_lifetime)
demographics_df$ASYN.SAA_visit <- as.factor(demographics_df$ASYN.SAA_visit)
demographics_df$Postmortem_primary <- as.factor(demographics_df$Postmortem_primary)
demographics_df$Genetics_FamilyHistory <- as.factor(demographics_df$Genetics_FamilyHistory)
demographics_df$APOEe4_alleles <- as.factor(demographics_df$APOEe4_alleles)
demographics_df$Sex <- as.factor(demographics_df$Sex)
demographics_df$Race_ethnicity <- as.factor(demographics_df$Race_ethnicity)
demographics_df$Onset_type <- as.factor(demographics_df$Onset_type)
demographics_df$Arthritis <- as.factor(demographics_df$Arthritis)

##Numerical variables
demographics_df$CSF_ptau_visit <- as.numeric(demographics_df$CSF_ptau_visit)
demographics_df$CSF_ttau_visit <- as.numeric(demographics_df$CSF_ttau_visit)
demographics_df$CSF_abeta42_visit <- as.numeric(demographics_df$CSF_abeta42_visit)
demographics_df$CSF_ATI_visit <- as.numeric(demographics_df$CSF_ATI_visit)
demographics_df$Onset_age <- as.numeric(demographics_df$Onset_age)
demographics_df$Education <- as.numeric(demographics_df$Education)
demographics_df$NFL_visit <- as.numeric(demographics_df$NFL_visit)
demographics_df$GFAP_visit <- as.numeric(demographics_df$GFAP_visit)
demographics_df$YKL40_visit <- as.numeric(demographics_df$YKL40_visit)
demographics_df$WMH_PV <- as.numeric(demographics_df$WMH_PV)
demographics_df$WMH_D <- as.numeric(demographics_df$WMH_D)
demographics_df$CDR_original_SOB <- as.numeric(demographics_df$CDR_original_SOB)
demographics_df$CDR_original_Total <- as.numeric(demographics_df$CDR_original_Total)
demographics_df$PSPRS_visit <- as.numeric(demographics_df$PSPRS_visit)
demographics_df$MOCA_visit_1yrmax_zscore <- as.numeric(demographics_df$MOCA_visit_1yrmax_zscore)

##Date variables
demographics_df$DOB <- as.Date(as.character(demographics_df$DOB_dd.mmmm.yy), format="%Y-%m-%d") 
demographics_df$Date <- as.Date(as.character(demographics_df$ID_Date_dd.mmmm.yy), format="%Y-%m-%d") 


cat("\n\n\n\n###############################################################################################\n",
            "5. CREATE NEW VARIABLES\n",
            "###############################################################################################\n\n\n")

##Calculate ages
demographics_df <- demographics_df %>%
    mutate(Age= (as.numeric(Date - DOB))/365) %>%
    mutate(Disease_duration= (as.numeric(Age - Onset_age))) %>%
    data.frame()

#Standardize DX for the analyses within APD only first
demographics_df <- demographics_df %>%
    mutate(APD_DX= Primary_DX_clin_final) %>%
    mutate(APD_DX=case_when(grepl("PSP", APD_DX) | grepl("PSP", Postmortem_primary) ~ "PSP",
                            grepl("CBS", APD_DX) | grepl("CBD", Postmortem_primary) ~ "CBS",
                            TRUE ~ "Other")) %>%
    data.frame()

#Standardize AD and ASyn-SAA diagnosis
demographics_df <- demographics_df %>%
    mutate(Evidence_AD_lifetime_binary=case_when(grepl("Yes", Evidence_AD_lifetime) ~ "ADpos",
                                                  grepl("No", Evidence_AD_lifetime) ~ "ADneg")) %>%
    mutate(Evidence_AD_visit_binary=case_when(grepl("Positive", CSF.AD_visit) ~ "ADpos",
                                                  grepl("No", CSF.AD_visit) ~ "ADneg",
                                                    grepl("Borderline", CSF.AD_visit) ~ "ADneg",
                                                    grepl("Inconsistent", CSF.AD_visit) ~ "ADneg")) %>%
    mutate(Evidence_ASYN_lifetime_binary=case_when(grepl("Yes", Evidence_ASYN_lifetime) ~ "ASYNpos",
                                                  grepl("No", Evidence_ASYN_lifetime) ~ "ASYNneg")) %>%
    mutate(ASYN.SAA_visit_binary=case_when(grepl("Positive", ASYN.SAA_visit) ~ "ASYNpos",
                                    grepl("Negative", ASYN.SAA_visit) ~ "ASYNneg")) %>%
    data.frame()

#Create a co-pathology variable
demographics_df <- demographics_df %>%
    mutate(Copathology=case_when(grepl("Yes", Evidence_AD_lifetime) & grepl("PSP", APD_DX) ~ "Yes",
                                 grepl("Yes", Evidence_ASYN_lifetime) & grepl("PSP", APD_DX) ~ "Yes",
                                grepl("Yes", Evidence_ASYN_lifetime) & grepl("CBS", APD_DX) ~ "Yes",
                                TRUE ~ "No")) %>%
    mutate(Copathology2=case_when(grepl("Yes", Evidence_AD_lifetime) & grepl("PSP", APD_DX) ~ "AD+",
                                 grepl("Yes", Evidence_ASYN_lifetime) & grepl("PSP", APD_DX) ~ "ASyn-SAA+",
                                grepl("Yes", Evidence_AD_lifetime) & grepl("Yes", Evidence_ASYN_lifetime) & grepl("PSP", APD_DX) ~ "AD+/ASyn-SAA+",
                                grepl("Yes", Evidence_ASYN_lifetime) & grepl("CBS", APD_DX) ~ "ASyn-SAA+",
                                TRUE ~ "No")) %>%
    data.frame()

#Create a pathology group variable
demographics_df <- demographics_df %>%
    mutate(Path_Grouping=case_when(grepl("Yes", Evidence_AD_lifetime) & grepl("CBS", APD_DX) ~ "AD",
                                  grepl("PSP", APD_DX) ~ "PSP",
                                grepl("No", Evidence_AD_lifetime) & grepl("CBS", APD_DX) ~ "CBS-other",
                                TRUE ~ "Other")) %>%
    data.frame()

cat("\n\n\n\n###############################################################################################\n",
            "6. CREATE NEW VARIABLES\n",
            "###############################################################################################\n\n\n")

demographics_df <- demographics_df[, c("Freezer_ID", "PlateID",
                                    "Sex", "Education", 
                                    "APD_DX", "Copathology", "Copathology2", "Path_Grouping", "Evidence_AD_lifetime_binary", "Evidence_AD_visit_binary", "Evidence_ASYN_lifetime_binary", "ASYN.SAA_visit_binary",
                                    "Age", "Onset_age", "Disease_duration",
                                    "CSF_ptau_visit",  "CSF_ttau_visit", "CSF_abeta42_visit", "CSF_ATI_visit",
                                    "NFL_visit", "GFAP_visit", "YKL40_visit",
                                    "CDR_original_SOB", "CDR_original_Total",
                                    "PSPRS_visit",  "MOCA_visit_1yrmax_zscore")]

demographics_df <- demographics_df[!duplicated(demographics_df$Freezer_ID), ]

write.csv(demographics_df, "demographics.csv")





