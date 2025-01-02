# FILENAME: SINGLEPLATE_CREATION.R
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

    # # If getting end of line error or other bug related to csv reading:
    # ##To run only without the arg.vec part in bash Run_ script, or directly on the Rscript
    # filepaths <- c("/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.4_Olink_PC_data/2238A_Tartaglia_NPX_IPCnormalized2024-08-08.csv", #Plate A NPX data            
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.4_Olink_PC_data/2238B_Tartaglia_EXTENDED_NPX_2024-09-30_PCnormalized/Tartaglia_EXTENDED_NPX_2024-09-30.csv", #Plate B NPX data
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.4_Olink_PC_data/2238C_Tartaglia_EXTENDED_NPX_2024-03-25_PC_normalized.csv", #Plate C NPX
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.7_Templates/all_template_df.csv", #Template file with all TARTAGLIA ID to Aliquot ID (=SAMPLEID) match keys
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.8_Demographic_mastersheet/demographics.csv", #demographics file created by Olink
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.4_Olink_PC_data/PlateA_InflammationI_countdata.csv", #count data from Inflammation Panel I
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.4_Olink_PC_data/PlateA_InflammationII_countdata.csv") #count data from Inflammation Panel II

    # filepaths_df <- data.frame(filepaths)
    # write.csv(filepaths_df, "2_filepaths_singleplate.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 


#Read the csv that contains the pths to the plates
filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 

# Create the dfs by reading the files indicated by the csv: olink plate data
plateA_df <- read.func.csv(filepaths_df, 1, olink=TRUE)
plateB_df <- read.func.csv(filepaths_df, 2, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best
plateC_df <- read.func.csv(filepaths_df, 3, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best

#Read the manifest plate
template_df <- read.func.csv(filepaths_df, 4, olink=FALSE)

#Read the demographics data
demographics_df <- read.func.csv(filepaths_df, 5, olink=FALSE)

#Read the demographics data
count_inflammationI_df <- read.func.csv(filepaths_df, 6, olink=FALSE)
count_inflammationII_df <- read.func.csv(filepaths_df, 7, olink=FALSE)


cat("\n\n\n\n###############################################################################################\n",
            "3. PREP THE COUNT DATA FROM PLATE A (OLD NPX EXPLORE SOFTWARE)\n",
            "###############################################################################################\n\n\n")

#Understand the structure of the new plates: 
# unique(plateB_df$SampleID)
##The IDs for the sample controls (ie the controls spiked to assess CV (sample controls), high signal (Interplate controls), and background signal (Negative controls)):
###are: QC657-1 (sample control1), QC657-1_2 (sample control2), PC1, PC2, PC3, NC1, NC2, NC3.  

# subset(plateB_df, plateB_df$SampleID=="QC657-1" & plateB_df$Panel=="Inflammation")[, c("OlinkID", "Assay", "UniProt", "Panel")]
# subset(plateC_df, plateC_df$SampleID=="QC657-1" & plateC_df$Panel=="Inflammation_II")[, c("OlinkID", "Assay", "UniProt", "Panel")]
# subset(plateB_df, plateB_df$SampleID=="QC657-1" & plateB_df$Assay=="Incubation control 4")[, c("OlinkID", "Assay", "UniProt", "Panel")]
##The structure for the internal controls are: 
###Olink ID is unique and plate-specific. Panel I:
#### OID20034 (EXT1 Panel I), OID20018 (AMP1 Panel I), OID20002 (INC1 Panel I)
#### OID20038 (EXT2 Panel I), OID20022 (AMP2 Panel I), OID20006 (INC2 Panel I)
#### OID20042 (EXT3 Panel I), OID20026 (AMP3 Panel I), OID20010 (INC3 Panel I)
#### OID20046 (EXT4 Panel I), OID20030 (AMP4 Panel I), OID20014 (INC4 Panel I)

###Olink ID is unique and plate-specific.Panel II:
#### OID30034 (EXT1 Panel II), OID30018 (AMP1 Panel II), OID30002 (INC1 Panel II)
#### OID30038 (EXT2 Panel II), OID30022 (AMP2 Panel II), OID30006 (INC2 Panel II)
#### OID30042 (EXT3 Panel II), OID30026 (AMP3 Panel II), OID30010 (INC3 Panel II)
#### OID30046 (EXT4 Panel II), OID30030 (AMP4 Panel II), OID30014 (INC4 Panel II)

###Assay and UniProt is duplicated across plates:
####Assay: Incubation control 1 (...); Amplification control 1 (...); Extension control 1 (...)
####UniProt: INC1 (...); AMP1 (...); EXT1 (...)

#To match this structure, we need to rename the variables in the count data file we got from Hamilton: 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "X")] <- "SampleID" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Incubation.control.1")] <- "Incubation control 1" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Incubation.control.2")] <- "Incubation control 2" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Incubation.control.3")] <- "Incubation control 3" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Incubation.control.4")] <- "Incubation control 4" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Amplification.control.1")] <- "Amplification control 1" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Amplification.control.2")] <- "Amplification control 2" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Amplification.control.3")] <- "Amplification control 3" 
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Amplification.control.4")] <- "Amplification control 4"
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Extension.control.1")] <- "Extension control 1"  
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Extension.control.2")] <- "Extension control 2"  
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Extension.control.3")] <- "Extension control 3"  
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "Extension.control.4")] <- "Extension control 4"  
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "HLA.DRA")] <- "HLA-DRA"  
colnames(count_inflammationI_df)[which(names(count_inflammationI_df) == "HLA.E")] <- "HLA-E"  

colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "X")] <- "SampleID" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Incubation.control.1")] <- "Incubation control 1" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Incubation.control.2")] <- "Incubation control 2" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Incubation.control.3")] <- "Incubation control 3" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Incubation.control.4")] <- "Incubation control 4" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Amplification.control.1")] <- "Amplification control 1" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Amplification.control.2")] <- "Amplification control 2" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Amplification.control.3")] <- "Amplification control 3" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Amplification.control.4")] <- "Amplification control 4" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Extension.control.1")] <- "Extension control 1"  
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Extension.control.2")] <- "Extension control 2"  
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Extension.control.3")] <- "Extension control 3"  
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "Extension.control.4")] <- "Extension control 4" 
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "HLA.DRA")] <- "HLA-DRA"  
colnames(count_inflammationII_df)[which(names(count_inflammationII_df) == "HLA.E")] <- "HLA-E"  


#To match this structure, we also add a new colum that corresponds to the panel: 
count_inflammationI_df <- count_inflammationI_df %>% pivot_longer(!SampleID, names_to="Assay", values_to="Count")
count_inflammationII_df <- count_inflammationII_df %>% pivot_longer(!SampleID, names_to="Assay", values_to="Count")

#Create the panel variable
panelI <- data.frame("Panel"=rep("Inflammation", nrow(count_inflammationI_df)))
count_inflammationI_df<- cbind(count_inflammationI_df, panelI)

panelII <- data.frame("Panel"=rep("Inflammation_II", nrow(count_inflammationII_df)))
count_inflammationII_df<- cbind(count_inflammationII_df, panelII)

#Combine the count data from the two panels
count_df <- rbind(count_inflammationI_df, count_inflammationII_df)
    
    ##DEFENSIVE CODING
    #Before merging, check the number of assays and IDs
    countdf_assay_n <- length(unique(count_df$Assay)) #749 assays in count_df
    plateAdf_assay_n <-length(unique(plateA_df$Assay)) #737 assays in plate A: to this we plan to add: 4 extension controls, 4 amplification controls, 4 incubation controls for total of 749 assays
    plateAdf_uniProt_n <-length(unique(plateA_df$UniProt)) #737 UniProt IDs in plate A
    plateAdf_OlinkID_n <-length(unique(plateA_df$OlinkID)) #737 OlinkIDs in plate A

    if ((countdf_assay_n != plateAdf_assay_n + 12)|(countdf_assay_n != plateAdf_uniProt_n + 12)| (countdf_assay_n != plateAdf_OlinkID_n + 12)){
        cat("Check why the number of assays in the count_df is differnet from the ones in plate A + the 12 control assays.\n")
    }

# #Merge the already available data from plateA with the new count data
# ##PlateA csv had NPX for all subjects but not for the sample controls (sample control x2, plate control x3, negative control x3)
# ##We do have the count data for these sample controls
# ##PlateA csv also did not have the values for the different assay controls (incubation control x4, extension control x4, amplification control x4)
# ##We do have the count data for these assay controls.
# #As a result, in the merged dataframe there are NAs. 
# # plateA_df_count <- merge(plateA_df, count_df, by=c("SampleID","Panel", "Assay")) #Would remove the NAs
plateA_df <- left_join(count_df,plateA_df, by=c("SampleID","Panel", "Assay")) #Keep the incomplete data

#Change variables to add the OlinkIDs for the assay controls
plateA_df <- plateA_df %>%
            mutate(OlinkID=case_when(Assay=="Extension control 1" & Panel=="Inflammation"  ~ "OID20034",
                                    Assay=="Extension control 2" & Panel=="Inflammation"  ~ "OID20038",                                  
                                    Assay=="Extension control 3" & Panel=="Inflammation"  ~ "OID20042",
                                    Assay=="Extension control 4" & Panel=="Inflammation"  ~ "OID20046",
                                    Assay=="Amplification control 1" & Panel=="Inflammation"  ~ "OID20018",
                                    Assay=="Amplification control 2" & Panel=="Inflammation"  ~ "OID20022",
                                    Assay=="Amplification control 3" & Panel=="Inflammation"  ~ "OID20026",
                                    Assay=="Amplification control 4" & Panel=="Inflammation"  ~ "OID20030",
                                    Assay=="Incubation control 1" & Panel=="Inflammation"  ~ "OID20002",
                                    Assay=="Incubation control 2" & Panel=="Inflammation"  ~ "OID20006",
                                    Assay=="Incubation control 3" & Panel=="Inflammation"  ~ "OID20010",
                                    Assay=="Incubation control 4" & Panel=="Inflammation"  ~ "OID20014",

                                    #Same for Panel II 
                                    Assay=="Extension control 1" & Panel=="Inflammation_II"  ~ "OID30034",
                                    Assay=="Extension control 2" & Panel=="Inflammation_II"  ~ "OID30038",                                  
                                    Assay=="Extension control 3" & Panel=="Inflammation_II"  ~ "OID30042",
                                    Assay=="Extension control 4" & Panel=="Inflammation_II"  ~ "OID30046",
                                    Assay=="Amplification control 1" & Panel=="Inflammation_II"  ~ "OID30018",
                                    Assay=="Amplification control 2" & Panel=="Inflammation_II"  ~ "OID30022",
                                    Assay=="Amplification control 3" & Panel=="Inflammation_II"  ~ "OID30026",
                                    Assay=="Amplification control 4" & Panel=="Inflammation_II"  ~ "OID30030",
                                    Assay=="Incubation control 1" & Panel=="Inflammation_II"  ~ "OID30002",
                                    Assay=="Incubation control 2" & Panel=="Inflammation_II"  ~ "OID30006",
                                    Assay=="Incubation control 3" & Panel=="Inflammation_II"  ~ "OID30010",
                                    Assay=="Incubation control 4" & Panel=="Inflammation_II"  ~ "OID30014",

                                    TRUE ~ as.character(OlinkID))) %>% #Existing OlinkIDs remain

            mutate(UniProt=case_when(Assay=="Extension control 1" & Panel=="Inflammation"  ~ "EXT1",
                                    Assay=="Extension control 2" & Panel=="Inflammation"  ~ "EXT2",                                  
                                    Assay=="Extension control 3" & Panel=="Inflammation"  ~ "EXT3",
                                    Assay=="Extension control 4" & Panel=="Inflammation"  ~ "EXT4",
                                    Assay=="Amplification control 1" & Panel=="Inflammation"  ~ "AMP1",
                                    Assay=="Amplification control 2" & Panel=="Inflammation"  ~ "AMP2",
                                    Assay=="Amplification control 3" & Panel=="Inflammation"  ~ "AMP3",
                                    Assay=="Amplification control 4" & Panel=="Inflammation"  ~ "AMP4",
                                    Assay=="Incubation control 1" & Panel=="Inflammation"  ~ "INC1",
                                    Assay=="Incubation control 2" & Panel=="Inflammation"  ~ "INC2",
                                    Assay=="Incubation control 3" & Panel=="Inflammation"  ~ "INC3",
                                    Assay=="Incubation control 4" & Panel=="Inflammation"  ~ "INC4",

                                    #Same for Panel II 
                                    Assay=="Extension control 1" & Panel=="Inflammation_II"  ~ "EXT1",
                                    Assay=="Extension control 2" & Panel=="Inflammation_II"  ~ "EXT2",                                  
                                    Assay=="Extension control 3" & Panel=="Inflammation_II"  ~ "EXT3",
                                    Assay=="Extension control 4" & Panel=="Inflammation_II"  ~ "EXT4",
                                    Assay=="Amplification control 1" & Panel=="Inflammation_II"  ~ "AMP1",
                                    Assay=="Amplification control 2" & Panel=="Inflammation_II"  ~ "AMP2",
                                    Assay=="Amplification control 3" & Panel=="Inflammation_II"  ~ "AMP3",
                                    Assay=="Amplification control 4" & Panel=="Inflammation_II"  ~ "AMP4",
                                    Assay=="Incubation control 1" & Panel=="Inflammation_II"  ~ "INC1",
                                    Assay=="Incubation control 2" & Panel=="Inflammation_II"  ~ "INC2",
                                    Assay=="Incubation control 3" & Panel=="Inflammation_II"  ~ "INC3",
                                    Assay=="Incubation control 4" & Panel=="Inflammation_II"  ~ "INC4",

                                    TRUE ~ as.character(UniProt))) %>% #Existing OlinkIDs remain      


            mutate(SampleID=case_when(SampleID=="SC" ~ "QC657-1", #So it matches name on the other plates
                                      SampleID=="SC-2" ~ "QC657-1_2", 
                                      SampleID=="NC" ~ "NC1", 
                                      SampleID=="NC-2" ~ "NC2", 
                                      SampleID=="NC-3" ~ "NC3",
                                      SampleID=="PC" ~ "PC1", 
                                      SampleID=="PC-2" ~ "PC2", 
                                      SampleID=="PC-3" ~ "PC3",
                                      TRUE ~ as.character(SampleID))) %>%

data.frame()

#Check the dataframe
    ##DEFENSIVE CODING
    if (length(unique(plateA_df$SampleID))!=96) {
        cat("Check the merge as there seems to be the wrong number of samples (including 2 sample controls, 3 plate controls, 3 negative controls. \n")
    }


cat("\n\n\n\n###############################################################################################\n",
            "4. MERGE THE DATA FROM PLATE A REFORMATTED WITH THE DEMOGRAPHICS\n",
            "###############################################################################################\n\n\n")

#Create the list of sample IDs and UniProt IDs to remove (ie the controls)
SampleControls_SampleID_vec <- c("QC657-1", "QC657-1_2","NC1", "NC2", "NC3", "PC1", "PC2", "PC3")
InternalControls_UniProt_vec <- c("EXT1", "EXT2", "EXT3", "EXT4", "AMP1", "AMP2", "AMP3", "AMP4", "INC1", "INC2", "INC3", "INC4")

#Remove them from Plate A so we are left only with the Tartaglia sample data
plateA_df <- subset(plateA_df, !plateA_df$SampleID %in%SampleControls_SampleID_vec)
plateA_df <- subset(plateA_df, !plateA_df$UniProt %in%InternalControls_UniProt_vec)


#Plate A is in a different format as it comes from the old software. 
#Give plateA_df new cols with empty rows to match the plates B and C layout
var_to_add_df <- data.frame("Sample_Type"=rep("SAMPLE", nrow(plateA_df)),
                            "Block"=rep("Not available", nrow(plateA_df)),
                            "WellID"=rep("Not available", nrow(plateA_df)),
                            "IntraCV"=rep("Can calculate if needed", nrow(plateA_df)),
                            "InterCV"=rep("Can calculate if needed", nrow(plateA_df)),
                            "Processing_StartDate"=rep("Not available", nrow(plateA_df)),
                            "Processing_EndDate"=rep("Not available", nrow(plateA_df)),
                            "AnalyzerID"=rep("Not available", nrow(plateA_df)),
                            "ExploreVersion"=rep("Pre-2023", nrow(plateA_df)))
plateA_df<- cbind(plateA_df, var_to_add_df)
    
#Merge with the demographics file
plateA_df <- left_join(plateA_df, demographics_df, by="SampleID")

plateA_df <- plateA_df %>% 
            dplyr::select(-Index.x, -PlateID.x, -X) %>% 
            data.frame()          

  
    ##DEFENSIVE CODING
    if (nrow(plateA_df) != 737*88) {
        cat("Check why the total number of rows is not as expected (ie 737 assays * 88 samples\n")
    }

#Save the file
write.csv(plateA_df, "PlateA_single.csv")


cat("\n\n\n\n###############################################################################################\n",
            "5. MERGE THE DATA FROM PLATE B WITH THE DEMOGRAPHICS\n",
            "###############################################################################################\n\n\n")

#Create the list of sample IDs and UniProt IDs to remove (ie the controls)
SampleControls_SampleID_vec <- c("QC657-1", "QC657-1_2","NC1", "NC2", "NC3", "PC1", "PC2", "PC3")
InternalControls_UniProt_vec <- c("EXT1", "EXT2", "EXT3", "EXT4", "AMP1", "AMP2", "AMP3", "AMP4", "INC1", "INC2", "INC3", "INC4")

#Remove them from Plate B so we are left only with the Tartaglia sample data
plateB_df <- subset(plateB_df, !plateB_df$SampleID %in%SampleControls_SampleID_vec)
plateB_df <- subset(plateB_df, !plateB_df$UniProt %in%InternalControls_UniProt_vec)
    
#Merge with the demographics file
plateB_df <- left_join(plateB_df, demographics_df, by="SampleID")

plateB_df <- plateB_df %>% 
            dplyr::select(-Index.x, -PlateID.x, -X) %>% 
            data.frame()          

    ##DEFENSIVE CODING
    cat("Reminder: for some reason, this plate has an extra assay: KNG1 for a total of 738 assays\n")
    if (nrow(plateB_df) != 738*88) {
        cat("Check why the total number of rows is not as expected (ie 738 assays * 88 samples\n")
    }

#Save the file
write.csv(plateB_df, "PlateB_single.csv")


cat("\n\n\n\n###############################################################################################\n",
            "6. MERGE THE DATA FROM PLATE C WITH THE DEMOGRAPHICS\n",
            "###############################################################################################\n\n\n")

#Create the list of sample IDs and UniProt IDs to remove (ie the controls)
SampleControls_SampleID_vec <- c("QC657-1", "QC657-1_2","NC1", "NC2", "NC3", "PC1", "PC2", "PC3")
InternalControls_UniProt_vec <- c("EXT1", "EXT2", "EXT3", "EXT4", "AMP1", "AMP2", "AMP3", "AMP4", "INC1", "INC2", "INC3", "INC4")

#Remove them from Plate C so we are left only with the Tartaglia sample data
plateC_df <- subset(plateC_df, !plateC_df$SampleID %in%SampleControls_SampleID_vec)
plateC_df <- subset(plateC_df, !plateC_df$UniProt %in%InternalControls_UniProt_vec)
    
#Merge with the demographics file
plateC_df <- left_join(plateC_df, demographics_df, by="SampleID")

plateC_df <- plateC_df %>% 
            dplyr::select(-Index.x, -PlateID.x, -X) %>% 
            data.frame()          

    ##DEFENSIVE CODING
    if (nrow(plateC_df) != 737*88) {
        cat("Check why the total number of rows is not as expected (ie 738 assays * 88 samples\n")
    }

#Save the file
write.csv(plateC_df, "PlateC_single.csv")















