#Last updated November 2024

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
    
    # # List of file pathways for the demographics
    # #If getting end of line error or other bug related to csv reading:
    # ##To run only without the arg.vec part in bash Run_ script, or directly on the Rscript
    # filepaths <- c("/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.7_Templates/all_template_df.csv", #Template file with all TARTAGLIA ID to Aliquot ID (=SAMPLEID) match keys
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.3_Clinical/0.3.7_local_FTLD/Olink_FTLD_clinical.csv", #Chloe's FTLD spreadsheet
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.3_Clinical/0.3.9_local_nonFTLD/Olink_nonFTLD_clinical.csv", #Chloe's nonFTLD spreadsheet
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.1_Simrika_Onedrive/Third_project_Genetic_cases/Sample_template_3rd_olink.csv", #Genetic FTLD spreadsheet: sampleID
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.1_Simrika_Onedrive/Third_project_Genetic_cases/clinical_data_ftld_biospecimen.csv") #Genetic FTLD spreadsheet: actual data

    # filepaths_df <- data.frame(filepaths)
    # write.csv(filepaths_df, "1_filepaths_demographics.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 

#Read the csv that contains the paths to the plates
filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 

#Read the template information
all_template_df <- read.func.csv(filepaths_df, 1, olink=FALSE)

#Read the clinical data
local_data_ftd_df <- read.func.csv(filepaths_df, 2, olink=FALSE)
local_data_nonftd_df <- read.func.csv(filepaths_df, 3, olink=FALSE)
allftd_ids_simrika_df <- read.func.csv(filepaths_df, 4, olink=FALSE)
allftd_demo_simrika_df <- read.func.csv(filepaths_df, 5, olink=FALSE)

#List of bridging samples
bridge_vec <- c("T041", "T050", "T120", "T351", "FTLD_039", "BC18", "01-0007 baseline", "01-0021 baseline")

cat("\n\n\n\n###############################################################################################\n",
            "3. CLEAN THE FTD COHORT FIRST\n",
            "###############################################################################################\n\n\n")

#Rename columns in chloe's file
colnames(local_data_ftd_df)[which(names(local_data_ftd_df) == "ID_main")] <- "Freezer_ID" 

#Add empty columns to have a match with other spreadsheets
local_data_ftd_df$Barcode <- NA #blank column 
local_data_ftd_df$Alternate_MRN <- NA #blank column
local_data_ftd_df$Alternate_ID_DID <- NA #blank column
local_data_ftd_df$RAVE_visit <- NA #blank column 
local_data_ftd_df$Age_range <- NA #blank column 
local_data_ftd_df$Onset_age_range <- NA #blank column 
local_data_ftd_df$FreezeThaw_cycles <- NA #blank column 
local_data_ftd_df$Age <- NA #blank column (Could use ID_Age if dont have all the DOBs/visit dates but for FTLD i usually keep it updated

local_data_ftd_df <- local_data_ftd_df[, c("Freezer_ID",
                                            "Lifetime_PlasmaSerum", "Longitudinal_CSF", "DNA", 
                                            "Primary_DX_clin_final", "Primary_DX_clin_visit","DX_PPA_lifetime","Postmortem_primary",
                                            "Evidence_AD", "CSF.AD_visit", "CSF_ptau_visit","CSF_ttau_visit", "CSF_abeta42_visit", "CSF_ATI_visit",
                                            "Evidence_ASYN_lifetime", "ASYN.SAA_visit", 
                                            "FAMILY_GENE", "GENETIC_STATUS", "APOE",
                                            "Age", "Sex", "Race", "Hispanic_ethnicity", 
                                            "DOB_dd.mmmm.yy","ID_Date_dd.mmmm.yy", "Onset_age",  "Onset_type", "Age_range", "Onset_age_range",
                                            "Education", "NFL_visit","GFAP_visit", "YKL40_visit",
                                            "Arthritis", "Fazekas_all", "Fazekas_PV","Fazekas_D",
                                            "PSPRS_visit","MOCA_visit_1yrmax_zscore",
                                            "Barcode", "Alternate_MRN","Alternate_ID_DID",  "RAVE_visit",
                                            "FreezeThaw_cycles", "Quanterix_kit")] 

    #DEFENSIVE CODING
    if (sum(local_data_ftd_df$Freezer_ID %in% all_template_df$Freezer_ID)<67) {
        cat("Check that the subject IDs in clinical files match the ones in the Olink dataset or use grep\n")
    }



cat("\n\n\n\n###############################################################################################\n",
            "4. CLEAN THE NON-FTD COHORT NEXT \n",
            "###############################################################################################\n\n\n")

#Drop the RAVE IDs as doing separately for now due to weird format
local_data_nonftd_df <- subset(local_data_nonftd_df, local_data_nonftd_df$Primary_DX_clin_final != "ALLFTD")

#Rename columns in clinical data file
colnames(local_data_nonftd_df)[which(names(local_data_nonftd_df) == "ID_main")] <- "Freezer_ID"

#Add empty columns to have a match with other spreadsheets
local_data_nonftd_df$Barcode <- NA #blank column 
local_data_nonftd_df$Alternate_MRN <- NA #blank column 
local_data_nonftd_df$Alternate_ID_DID <- NA #blank column 
local_data_nonftd_df$RAVE_visit <- NA #blank column 
local_data_nonftd_df$Age_range <- NA #blank column 
local_data_nonftd_df$Onset_age_range <- NA #blank column 
local_data_nonftd_df$FreezeThaw_cycles <- NA #blank column 
local_data_nonftd_df$DX_PPA_lifetime <- NA #blank column 

local_data_nonftd_df <- local_data_nonftd_df[, c("Freezer_ID",
                                            "Lifetime_PlasmaSerum", "Longitudinal_CSF", "DNA", 
                                            "Primary_DX_clin_final", "Primary_DX_clin_visit","DX_PPA_lifetime","Postmortem_primary",
                                            "Evidence_AD", "CSF.AD_visit", "CSF_ptau_visit","CSF_ttau_visit", "CSF_abeta42_visit", "CSF_ATI_visit",
                                            "Evidence_ASYN_lifetime", "ASYN.SAA_visit", 
                                            "FAMILY_GENE", "GENETIC_STATUS", "APOE",
                                            "Age","Sex", "Race", "Hispanic_ethnicity", 
                                            "DOB_dd.mmmm.yy","ID_Date_dd.mmmm.yy", "Onset_age",  "Onset_type", "Age_range", "Onset_age_range",
                                            "Education", "NFL_visit","GFAP_visit", "YKL40_visit",
                                            "Arthritis", "Fazekas_all", "Fazekas_PV","Fazekas_D",
                                            "PSPRS_visit","MOCA_visit_1yrmax_zscore",
                                            "Barcode", "Alternate_MRN","Alternate_ID_DID",  "RAVE_visit",
                                            "FreezeThaw_cycles", "Quanterix_kit")] 

    #DEFENSIVE CODING
    if (sum(local_data_nonftd_df$Freezer_ID %in% all_template_df$Freezer_ID)!= length(local_data_nonftd_df$Freezer_ID)) {
        cat("Check that the subject IDs in clinical files match the ones in the Olink dataset or use grep\n")
    }



cat("\n\n\n\n###############################################################################################\n",
            "5. CLEAN UP THE RAVE ALLFTD GENETIC COHORT \n",
            "###############################################################################################\n\n\n")

sponsor_data_allftd_df <- var.func.geneticALLFTD(allftd_ids_simrika_df, allftd_demo_simrika_df)

#Combine/Modify some of the variables to make new ones: 
sponsor_data_allftd_df <- sponsor_data_allftd_df %>%
        mutate(Sex=case_when(SEX==1 ~ "M", SEX==2 ~ "F"))%>%
        mutate(Primary_DX_clin_final= PRIM_CLIN_PHENO) %>%
        mutate(Primary_DX_clin_final=case_when(grepl("Corticobasal syndrome", Primary_DX_clin_final) ~ "CBS",
                                               grepl("Behavioral variant frontotemporal dementia", Primary_DX_clin_final) ~ "bvFTD",
                                               grepl("Amyotrophic lateral sclerosis", Primary_DX_clin_final)  | grepl("ALS", Primary_DX_clin_final)  ~ "ALS",
                                               grepl("MCI", Primary_DX_clin_final) ~ "MCI",
                                               grepl("Alzheimer's", Primary_DX_clin_final) ~ "AD",
                                               grepl("agrammatic", Primary_DX_clin_final) ~ "nfvPPA",
                                               grepl("Pool", Freezer_ID) ~ "Pooled CSF",
                                               TRUE ~ "Other")) %>%
        mutate(DX_PPA_lifetime=case_when(grepl("agrammatic", Primary_DX_clin_final) ~ "nfvPPA",
               TRUE ~ "No")) %>%
        mutate(Primary_DX_clin_visit= Primary_DX_clin_final) %>%
        data.frame()

#Rename columns in clinical data file
colnames(sponsor_data_allftd_df)[which(names(sponsor_data_allftd_df) == "CLINICAL_EVENT")] <- "RAVE_visit"
colnames(sponsor_data_allftd_df)[which(names(sponsor_data_allftd_df) == "RACE")] <- "Race"
colnames(sponsor_data_allftd_df)[which(names(sponsor_data_allftd_df) == "HISPANIC_V3")] <- "Hispanic_ethnicity"
colnames(sponsor_data_allftd_df)[which(names(sponsor_data_allftd_df) == "AGE_AT_VISIT_RNG")] <- "Age_range"
colnames(sponsor_data_allftd_df)[which(names(sponsor_data_allftd_df) == "AGE_AT_ONSET_RNG")] <- "Onset_age_range"
colnames(sponsor_data_allftd_df)[which(names(sponsor_data_allftd_df) == "FREEZE")] <- "FreezeThaw_cycles"

#Add empty columns to have a match with other spreadsheets
sponsor_data_allftd_df$Lifetime_PlasmaSerum <- NA #blank column 
sponsor_data_allftd_df$Longitudinal_CSF <- NA #blank column 
sponsor_data_allftd_df$DNA <- NA #blank column 
sponsor_data_allftd_df$Postmortem_primary <- NA #blank column 
sponsor_data_allftd_df$Evidence_AD <- NA #blank column
sponsor_data_allftd_df$CSF.AD_visit <- NA #blank column  
sponsor_data_allftd_df$CSF_ptau_visit <- NA #blank column 
sponsor_data_allftd_df$CSF_ttau_visit <- NA #blank column 
sponsor_data_allftd_df$CSF_abeta42_visit <- NA #blank column 
sponsor_data_allftd_df$CSF_ATI_visit <- NA #blank column 
sponsor_data_allftd_df$Evidence_ASYN_lifetime <- NA #blank column 
sponsor_data_allftd_df$ASYN.SAA_visit <- NA #blank column 
sponsor_data_allftd_df$APOE <- NA #blank column 
sponsor_data_allftd_df$Age <- NA #blank column 
sponsor_data_allftd_df$DOB_dd.mmmm.yy <- NA #blank column 
sponsor_data_allftd_df$ID_Date_dd.mmmm.yy <- NA #blank column 
sponsor_data_allftd_df$Onset_age <- NA #blank column 
sponsor_data_allftd_df$Onset_type <- NA #blank column 
sponsor_data_allftd_df$Education <- NA #blank column 
sponsor_data_allftd_df$NFL_visit <- NA #blank column 
sponsor_data_allftd_df$GFAP_visit <- NA #blank column 
sponsor_data_allftd_df$YKL40_visit <- NA #blank column 
sponsor_data_allftd_df$Arthritis <- NA #blank column 
sponsor_data_allftd_df$Fazekas_all <- NA #blank column 
sponsor_data_allftd_df$Fazekas_PV <- NA #blank column 
sponsor_data_allftd_df$Fazekas_D <- NA #blank column 
sponsor_data_allftd_df$PSPRS_visit <- NA #blank column 
sponsor_data_allftd_df$MOCA_visit_1yrmax_zscore <- NA #blank column 
sponsor_data_allftd_df$Quanterix_kit <- NA #blank column 

sponsor_data_allftd_df <- sponsor_data_allftd_df[, c("Freezer_ID",
                                                "Lifetime_PlasmaSerum", "Longitudinal_CSF", "DNA", 
                                                "Primary_DX_clin_final", "Primary_DX_clin_visit","DX_PPA_lifetime","Postmortem_primary",
                                                "Evidence_AD", "CSF.AD_visit", "CSF_ptau_visit","CSF_ttau_visit", "CSF_abeta42_visit", "CSF_ATI_visit",
                                                "Evidence_ASYN_lifetime", "ASYN.SAA_visit", 
                                                "FAMILY_GENE", "GENETIC_STATUS", "APOE",
                                                "Age","Sex", "Race", "Hispanic_ethnicity", 
                                                "DOB_dd.mmmm.yy","ID_Date_dd.mmmm.yy", "Onset_age",  "Onset_type", "Age_range", "Onset_age_range",
                                                "Education", "NFL_visit","GFAP_visit", "YKL40_visit",
                                                "Arthritis", "Fazekas_all", "Fazekas_PV","Fazekas_D",
                                                "PSPRS_visit","MOCA_visit_1yrmax_zscore",
                                                "Barcode", "Alternate_MRN","Alternate_ID_DID",  "RAVE_visit",
                                                "FreezeThaw_cycles", "Quanterix_kit")] 


    #DEFENSIVE CODING
    if (sum(sponsor_data_allftd_df$Freezer_ID %in% all_template_df$Freezer_ID)!= length(sponsor_data_allftd_df$Freezer_ID)) {
        cat("Check that the subject IDs in clinical files match the ones in the Olink dataset or use grep\n")
    }



cat("\n\n\n\n###############################################################################################\n",
            "6. MERGE THE DEMOGRAPHICS FROM ALL THREE PLATES TOGETHER \n",
            "###############################################################################################\n\n\n")

    #DEFENSIVE CODING
    if (sum(colnames(local_data_ftd_df) != colnames(local_data_nonftd_df)) >0) {
        cat("Dataframes with the local non-FTD vs local FTD cohort clinical data need to have same variables for the merge\n")
    }
    if (sum(colnames(local_data_ftd_df) != colnames(sponsor_data_allftd_df)) >0) {
        cat("Dataframes with the local FTD vs sponsor ALLFTD cohort clinical data need to have same variables for the merge\n")
    }

#Combine the two local datasets
local_data_df <- rbind(local_data_ftd_df, local_data_nonftd_df)
all_data_df <- rbind(local_data_df, sponsor_data_allftd_df)



cat("\n\n\n\n###############################################################################################\n",
            "7. MERGE THE DEMOGRAPHICS WITH THE PLATE LAYOUT \n",
            "###############################################################################################\n\n\n")

# Merge with the template file
demographics_df <- left_join(all_template_df,all_data_df, by="Freezer_ID")



cat("\n\n\n\n###############################################################################################\n",
            "8. FORMAT THE VARIABLES\n",
            "###############################################################################################\n\n\n")

#Format properly the different variables:

#Categorical variables
demographics_df$Freezer_ID <- as.factor(demographics_df$Freezer_ID)
demographics_df$PlateID <- as.factor(demographics_df$PlateID)
demographics_df$SampleID <- as.factor(demographics_df$SampleID)
demographics_df$Index <- as.factor(demographics_df$Index)
demographics_df$Lifetime_PlasmaSerum <- as.factor(demographics_df$Lifetime_PlasmaSerum)
demographics_df$Longitudinal_CSF <- as.factor(demographics_df$Longitudinal_CSF)
demographics_df$DNA <- as.factor(demographics_df$DNA)
demographics_df$Primary_DX_clin_final <- as.factor(demographics_df$Primary_DX_clin_final)
demographics_df$Primary_DX_clin_visit <- as.factor(demographics_df$Primary_DX_clin_visit)
demographics_df$DX_PPA_lifetime <- as.factor(demographics_df$DX_PPA_lifetime)
demographics_df$Postmortem_primary <- as.factor(demographics_df$Postmortem_primary)
demographics_df$Evidence_AD <- as.factor(demographics_df$Evidence_AD)
demographics_df$CSF.AD_visit <- as.factor(demographics_df$CSF.AD_visit)
demographics_df$Evidence_ASYN_lifetime <- as.factor(demographics_df$Evidence_ASYN_lifetime)
demographics_df$ASYN.SAA_visit <- as.factor(demographics_df$ASYN.SAA_visit)
demographics_df$FAMILY_GENE <- as.factor(demographics_df$FAMILY_GENE)
demographics_df$GENETIC_STATUS <- as.factor(demographics_df$GENETIC_STATUS)
demographics_df$APOE <- as.factor(demographics_df$APOE)
demographics_df$Sex <- as.factor(demographics_df$Sex)
demographics_df$Race <- as.factor(demographics_df$Race)
demographics_df$Hispanic_ethnicity <- as.factor(demographics_df$Hispanic_ethnicity)
demographics_df$Onset_type <- as.factor(demographics_df$Onset_type)
demographics_df$Arthritis <- as.factor(demographics_df$Arthritis)
demographics_df$Barcode <- as.factor(demographics_df$Barcode)
demographics_df$Alternate_MRN <- as.factor(demographics_df$Alternate_MRN)
demographics_df$Alternate_ID_DID <- as.factor(demographics_df$Alternate_ID_DID)
demographics_df$RAVE_visit <- as.factor(demographics_df$RAVE_visit)
demographics_df$Quanterix_kit <- as.factor(demographics_df$Quanterix_kit)

##Numerical variables
demographics_df$CSF_ptau_visit <- as.numeric(demographics_df$CSF_ptau_visit)
demographics_df$CSF_ttau_visit <- as.numeric(demographics_df$CSF_ttau_visit)
demographics_df$CSF_abeta42_visit <- as.numeric(demographics_df$CSF_abeta42_visit)
demographics_df$CSF_ATI_visit <- as.numeric(demographics_df$CSF_ATI_visit)
demographics_df$Age <- as.numeric(demographics_df$Age)
demographics_df$Onset_age <- as.numeric(demographics_df$Onset_age)
demographics_df$Education <- as.numeric(demographics_df$Education)
demographics_df$NFL_visit <- as.numeric(demographics_df$NFL_visit)
demographics_df$GFAP_visit <- as.numeric(demographics_df$GFAP_visit)
demographics_df$YKL40_visit <- as.numeric(demographics_df$YKL40_visit)
demographics_df$Fazekas_all <- as.numeric(demographics_df$Fazekas_all)
demographics_df$Fazekas_PV <- as.numeric(demographics_df$Fazekas_PV)
demographics_df$Fazekas_D <- as.numeric(demographics_df$Fazekas_D)
demographics_df$PSPRS_visit <- as.numeric(demographics_df$PSPRS_visit)
demographics_df$MOCA_visit_1yrmax_zscore <- as.numeric(demographics_df$MOCA_visit_1yrmax_zscore)
demographics_df$FreezeThaw_cycles <- as.numeric(demographics_df$FreezeThaw_cycles)

##Date variables
demographics_df$DOB <- as.Date(as.character(demographics_df$DOB_dd.mmmm.yy), format="%Y-%m-%d") 
demographics_df$Date <- as.Date(as.character(demographics_df$ID_Date_dd.mmmm.yy), format="%Y-%m-%d") 

##Onset age range
demographics_df$AGE_AT_VISIT_RNG <- factor(demographics_df$Age_range, order = TRUE)
demographics_df$AGE_AT_ONSET_RNG <- factor(demographics_df$Onset_age_range, order = TRUE)


cat("\n\n\n\n###############################################################################################\n",
            "9. CREATE NEW VARIABLES: DEMOGRAPHICS\n",
            "###############################################################################################\n\n\n")

#Combine/Modify some of the variables to make new ones: 
demographics_df <- demographics_df %>%
                    mutate(Race=case_when(grepl("White", Race) | grepl("Caucasian", Race)  ~ "White",
                              grepl("Black", Race)  ~ "Black",
                              grepl("Asian", Race)  ~ "Asian",
                              grepl("Alaska", Race) ~ "American indian or Alaska native",
                              grepl("Mixed", Race) ~ "Complex",
                              TRUE ~ "Unknown")) %>%

##Calculate ages
    mutate(Age=case_when(is.na(Age)==TRUE ~ as.numeric(Date - DOB)/365,
            TRUE ~ as.numeric(Age)))%>%
    mutate(Disease_duration= (as.numeric(Age - Onset_age))) %>%

##Binarize AD
    mutate(CSF.AD_visit_binary=case_when(grepl("Borderline", CSF.AD_visit) | grepl("Inconsistent", CSF.AD_visit) | grepl("Negative", CSF.AD_visit) ~ "AD-",
                                        grepl("Positive", CSF.AD_visit) ~ "AD+",
                               TRUE ~ "NA")) %>%
    mutate(Evidence_AD_binary=case_when(grepl("Yes", Evidence_AD) ~ "AD+",
                                        grepl("No", Evidence_AD) ~ "AD-",
                               TRUE ~ "NA")) %>%
##Bridging sample
    mutate(Bridge=case_when(grepl("003", PlateID) & (Freezer_ID %in% bridge_vec)==TRUE ~ "Bridging sample on plate 3",
                            TRUE ~ "Regular sample")) %>%
data.frame()


cat("\n\n\n\n###############################################################################################\n",
            "10. CREATE NEW VARIABLES: CTE PAPER \n",
            "###############################################################################################\n\n\n")

#Standardize DX for the analyses: CTE paper
##Here we have to decide how the analysis is going to be done. We want to 1) have all the CTE subjects and 2) include the HC. 
###Inclusion:
####all the athletes, even the one with CBD (T128) or the one with svPPA (CTE1096);
####all the local HC, on plate 1 and 2. Later Lian can exclude based on his own criteria (plate ID, age);

demographics_df <- demographics_df %>%
    mutate(DX_CTE_paper=case_when(grepl("CTE", Primary_DX_clin_final) | grepl("T128", Freezer_ID) | grepl("CTE1096", Freezer_ID) ~ "CTE",
                                  grepl("NHL", Freezer_ID) | grepl("FTLD_HC", Freezer_ID) | grepl("LS10", Freezer_ID)~ "HC",
                                  TRUE ~ "Other")) %>%
data.frame()


cat("\n\n\n\n###############################################################################################\n",
            "11. CREATE NEW VARIABLES: PSP PAPER\n",
            "###############################################################################################\n\n\n")

#Standardize DX for the analyses: PSP paper
##Here we have to decide how the analysis is going to be done. We want to 1) have all subjects with high likelihood of having PSP pathology; 2) include the HC; 3) include the AD cases. 
###Inclusion:
####all the PSP, based on 1) clinical diagnosis of PSP; 2) pathology of PSP;
####all the local HC, on plate 1 and 2, which are likely to be excluded later based on plate or age;
####all the local AD cases, on plate 1 and 2, for comparison with another disease, including the CBS;
###Exclusions:
####For now don't include the sponsor genetic carriers (even if PSP), 

demographics_df <- demographics_df %>%
    mutate(DX_PSP_paper=case_when(grepl("PSP", Primary_DX_clin_final) | grepl("PSP", Postmortem_primary) ~ "PSP",                                  
                                  grepl("Yes", Evidence_AD) | grepl("AD", Postmortem_primary) ~ "AD",
                                  grepl("NHL", Freezer_ID) | grepl("FTLD_HC", Freezer_ID) | grepl("LS10", Freezer_ID)~ "HC",
                                  TRUE ~ "Other")) %>%
data.frame()



cat("\n\n\n\n###############################################################################################\n",
            "12. CREATE NEW VARIABLES: YOAD LOAD PAPER\n",
            "###############################################################################################\n\n\n")

#Standardize DX for the analyses: YOAD vs LOAD paper
##Here we have to decide how the analysis is going to be done. We want to 1) have all subjects with AD+ status and 2) the local HC.
###Inclusion:
####all the local AD+ subjects, based on AD evidence. Later PSP and other groups where AD is co-pathology can be excluded.
####all the local HC, on plate 1 and 2, which are likely to be excluded later based on plate or age;
###Exclusions:
####For now don't include the sponsor genetic carriers (even if PSP).
####Excludes automatically CTE1052 as AD was found at pathology but he doesnt have an age at onset for AD. 

demographics_df <- demographics_df %>%
    mutate(DX_YOAD_paper=case_when((grepl("Yes", Evidence_AD) | grepl("AD", Postmortem_primary)) & Onset_age <=65  ~ "YOAD",
                                    (grepl("Yes", Evidence_AD) | grepl("AD", Postmortem_primary)) & Onset_age >65  ~ "LOAD",                                  
                                     grepl("NHL", Freezer_ID) | grepl("FTLD_HC", Freezer_ID) | grepl("LS10", Freezer_ID)~ "HC",
                                     TRUE ~ "Other")) %>%
data.frame()

colnames(demographics_df)

cat("\n\n\n\n###############################################################################################\n",
            "13. SAVE DATAFRAME\n",
            "###############################################################################################\n\n\n")

#Remove the bridge samples as not needed this time
# demographics_df <- demographics_df[!duplicated(demographics_df$Freezer_ID), ]

demographics_df <- demographics_df %>% 
                   dplyr::select(-CSF.AD_visit, -Evidence_AD) %>% 
                   data.frame()

write.csv(demographics_df, "demographics.csv")




