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
    
    # #If getting end of line error or other bug related to csv reading:
    # ##To run only without the arg.vec part in bash Run_ script, or directly on the Rscript
    # filepaths <- c("/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238A_Tartaglia_NPX_IPCnormalized2024-08-08.csv", #Plate A NPX data            
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238B_Tartaglia_EXTENDED_NPX_2024-09-30_PCnormalized/Tartaglia_EXTENDED_NPX_2024-09-30.csv", #Plate B NPX data
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.4_Olink_PC_data/2238C_Tartaglia_EXTENDED_NPX_2024-03-25_PC_normalized.csv", #Plate C NPX
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.1_Simrika_Onedrive/Second_project_AD_HC/Sample_all_2ndproject.csv", #Merged IDs from Simrika: not needed here but needed for TEMPLATE_CREATION.R
    #                 "/Users/nikhilbhagwat/Desktop/0_DATA/0.4_Biofluids/0.4.3_Olink/0.4.3.1_Simrika_Onedrive/Third_project_Genetic_cases/Sample_template_3rd_olink.csv", #Merged IDs from Simrika: not needed here but needed for TEMPLATE_CREATION.R
    #                 "all_template_df.csv") #Template file with all TARTAGLIA ID to Aliquot ID (=SAMPLEID) match keys

    # filepaths_df <- data.frame(filepaths)
    # write.csv(filepaths_df, "filepaths_normalization.csv") #a copy of object created at the time of submission was kept for reference. Can be shared upon request. 


#Read the csv that contains the pths to the plates
filepaths_df <- read.func(arg.vec[1], 'filepaths_df') #arg.vec[1] is the csv with the pathways to the different data spreadsheets. 

#Create the dfs by reading the files indicated by the csv: olink plate data
plateA_df <- read.func.csv(filepaths_df, 1, olink=TRUE)
plateB_df <- read.func.csv(filepaths_df, 2, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best
plateC_df <- read.func.csv(filepaths_df, 3, olink=TRUE) #diff delimiter: using OlinkAnalyze read function is best

#Read the manifest plate
all_plates_manifest_df <- read.func.csv(filepaths_df, 6, olink=FALSE)


cat("\n\n\n\n###############################################################################################\n",
            "3. PREP THE PLATE DATA (NPX)\n",
            "###############################################################################################\n\n\n")

#Give plateA_df new cols with empty rows to match the plates B and C layout
var_to_add_df <- data.frame("Sample_Type"=rep("Not available", nrow(plateA_df)),
                            "Block"=rep("Not available", nrow(plateA_df)),
                            "WellID"=rep("Not available", nrow(plateA_df)),
                            "Count"=rep("Not available", nrow(plateA_df)),
                            "IntraCV"=rep("Not available", nrow(plateA_df)),
                            "InterCV"=rep("Not available", nrow(plateA_df)),
                            "Processing_StartDate"=rep("Not available", nrow(plateA_df)),
                            "Processing_EndDate"=rep("Not available", nrow(plateA_df)),
                            "AnalyzerID"=rep("Not available", nrow(plateA_df)),
                            "ExploreVersion"=rep("Not available", nrow(plateA_df)))
plateA_df<- cbind(plateA_df, var_to_add_df)

# Combine all plate data into one: 
all_plates_df <- rbind(plateA_df, plateB_df, plateC_df)

#Remove the controls
all_plates_df <- subset(all_plates_df, (grepl("control", all_plates_df$Assay, fixed=TRUE))==FALSE)


cat("\n\n\n\n###############################################################################################\n",
            "4. MERGE WITH THE TEMPLATE DATA FOR IDs\n",
            "###############################################################################################\n\n\n")

#Merge plate data with the manifest. Use merge so only data corresponding to a TARTAGLIA ID are kept
all_plates_df <- merge(all_plates_manifest_df, all_plates_df, by="SampleID")


cat("\n\n\n\n###############################################################################################\n",
            "5. IDENTIFY THE ASSAY THAT HAS CHANGED NAMES BETWEEN PLATES\n",
            "###############################################################################################\n\n\n")

#The number of rows is different between the plates so would like to know which proteins differ between the different plates.
for (plate1 in c("053-001", "053-002", "053-003")) {  
    for (plate2 in c("053-001", "053-002", "053-003")) { 
        if (plate1 != plate2) { 
            assays1 <- unique(all_plates_df[all_plates_df$PlateID==plate1, ]$Assay)
            assays2 <- unique(all_plates_df[all_plates_df$PlateID==plate2, ]$Assay)
                if (sum(assays1 %in% assays2 == FALSE) >0) { 
                    cat("The following protein is in", plate1," but not", plate2, ":\n")
                    extra_assay <- subset(assays1, assays1 %in% assays2 == FALSE)
                    cat(extra_assay, "\n")
                }
        }
    }
}

cat("Found that KNG1 is only on Plate B but not the other two. No protein is missing from Plate B. \n")

all_plates_df <- subset(all_plates_df, all_plates_df$Assay!="KNG1")


cat("\n\n\n\n###############################################################################################\n",
            "6. CLEAN UP & SAVE THE COMPLETE NPX DATAFRAME\n",
            "###############################################################################################\n\n\n")

#Rename columns
colnames(all_plates_df)[which(names(all_plates_df) == "PlateID.x")] <- "PlateID"
colnames(all_plates_df)[which(names(all_plates_df) == "Index.x")] <- "Index"

#Remove duplicate columns
all_plates_df <- all_plates_df[, c("SampleID","Freezer_ID", "PlateID", "Index", "OlinkID",
                                    "UniProt","Assay", "MissingFreq", "Panel", "Panel_Lot_Nr",
                                    "QC_Warning", "LOD","NPX", "Normalization","Assay_Warning",
                                     "Sample_Type", "Block","WellID","Count",
                                     "IntraCV", "InterCV", "Processing_StartDate",
                                     "Processing_EndDate", "AnalyzerID", "ExploreVersion")]
#Save the new df
write.csv(all_plates_df, "all_plates_df.csv")

cat("\n\n\n\n###############################################################################################\n",
            "7. IDENTIFY THE BRIDGING SAMPLES FOR PLOTTING ON PCA: A to C plates \n",
            "###############################################################################################\n\n\n")

#First recreate the plate A, B, C data but after having harmonized the files in the previous merging steps
plateA_df <- subset(all_plates_df, all_plates_df$PlateID=="053-001")
plateB_df <- subset(all_plates_df, all_plates_df$PlateID=="053-002")
plateC_df <- subset(all_plates_df, all_plates_df$PlateID=="053-003")

#List of df for some basic checks
df_list <- list(plateA_df,plateB_df,plateC_df)
df_list_assays <- list(plateA_df$Assay,plateB_df$Assay,plateC_df$Assay)
df_list_subjects <- list(plateA_df$Freezer_ID,plateB_df$Freezer_ID,plateC_df$Freezer_ID)

    #DEFENSIVE CODING
    #Check no difference between the plates in terms of dimensions (no exclusions due to QC or missing subjects)
    assays_n <- lapply(df_list_assays, function(x) length(unique(x)))
    subject_n <- lapply(df_list_subjects, function(x) length(unique(x)))
    for (i in 1:3) {
        if (assays_n[i]!=737 | subject_n[i]!=88) {
            cat("Check that all assays and subjects were included for plate.", i,"where plate1 is plate A, plate2 is plate B, plate 3 is plate C.\n")
            }
        }

cat("\n\n\n\n###############################################################################################\n",
            "6. BOTH PLATES CHECK: NPX DENSITY PLOT BEFORE BRIDGING \n",
            "###############################################################################################\n\n\n")

#Keep only data from plate A and C
AtoC_prebridging_df<- subset(all_plates_df, all_plates_df$PlateID=="053-001" | all_plates_df$PlateID=="053-003")

# Plot NPX density before bridging normalization
AtoC_prebridging_df %>%
  mutate(Panel = gsub("Olink ", "", Panel)) %>%
  ggplot(aes(x = NPX, fill = PlateID)) + geom_density(alpha = 0.3) + 
  facet_grid(~Panel) + set_plot_theme() +
  ggtitle("Plate A vs Plate C pre-bridging: NPX distribution") +
  scale_fill_manual('Plate ID', values=c('red', 'darkblue')) +
  theme(strip.text = element_text(size = 16),legend.position = "top")


#Keep only data from plate B and C
BtoC_prebridging_df<- subset(all_plates_df, all_plates_df$PlateID=="053-002" | all_plates_df$PlateID=="053-003")

# Plot NPX density before bridging normalization
BtoC_prebridging_df %>%
  mutate(Panel = gsub("Olink ", "", Panel)) %>%
  ggplot(aes(x = NPX, fill = PlateID)) + geom_density(alpha = 0.3) + 
  facet_grid(~Panel) + set_plot_theme() +
  ggtitle("Plate B vs Plate C pre-bridging: NPX distribution") +
  scale_fill_manual('Plate ID', values=c('red', 'darkblue')) +
  theme(strip.text = element_text(size = 16),legend.position = "top")


cat("\n\n\n\n###############################################################################################\n",
            "7. IDENTIFY THE BRIDGING SAMPLES FOR PLOTTING ON PCA: A to C plates \n",
            "###############################################################################################\n\n\n")


#Find bridge samples between Plates A and C
##First create df with only the data of IDs in common between Plates A and C
AtoC_overlapping_samples_df <- subset(plateA_df, plateA_df$Freezer_ID %in% intersect(plateA_df$Freezer_ID, plateC_df$Freezer_ID))
CtoA_overlapping_samples_df <- subset(plateC_df, plateC_df$Freezer_ID %in% intersect(plateA_df$Freezer_ID, plateC_df$Freezer_ID))

##Then clean up that dataset and then ensure the samples show up in the same order in both dataframes
##This ensures that the sample IDs list match each other on both dataframes when they are bridged
AtoC_overlapping_samples_df <- AtoC_overlapping_samples_df[, c("Freezer_ID", "SampleID")]
AtoC_overlapping_samples_df <- AtoC_overlapping_samples_df[order(AtoC_overlapping_samples_df$Freezer_ID),]
AtoC_overlapping_sampleID<- unique(AtoC_overlapping_samples_df$SampleID)

CtoA_overlapping_samples_df <- CtoA_overlapping_samples_df[, c("Freezer_ID", "SampleID")]
CtoA_overlapping_samples_df <- CtoA_overlapping_samples_df[order(CtoA_overlapping_samples_df$Freezer_ID),]
CtoA_overlapping_sampleID<- unique(CtoA_overlapping_samples_df$SampleID)

AtoC_overlapping_FreezerID <- unique(AtoC_overlapping_samples_df$Freezer_ID)

cat("Samples in common across both plate A and C are: \n")
print(AtoC_overlapping_FreezerID)
cat("Their aliquot number on Plate A is:")
print(AtoC_overlapping_sampleID)
cat("Their aliquot number on Plate C is:")
print(CtoA_overlapping_sampleID)


cat("\n\n\n\n###############################################################################################\n",
            "8. IDENTIFY THE BRIDGING SAMPLES FOR PLOTTING ON PCA: B to C plates \n",
            "###############################################################################################\n\n\n")

#Find bridge samples between Plates B and C
##First create df with only the data of IDs in common between Plates B and C
BtoC_overlapping_samples_df <- subset(plateB_df, plateB_df$Freezer_ID %in% intersect(plateB_df$Freezer_ID, plateC_df$Freezer_ID))
CtoB_overlapping_samples_df <- subset(plateC_df, plateC_df$Freezer_ID %in% intersect(plateB_df$Freezer_ID, plateC_df$Freezer_ID))

##Then clean up that dataset and then ensure the samples show up in the same order in both dataframes
##This ensures that the sample IDs list match each other on both dataframes when they are bridged
BtoC_overlapping_samples_df <- BtoC_overlapping_samples_df[, c("Freezer_ID", "SampleID")]
BtoC_overlapping_samples_df <- BtoC_overlapping_samples_df[order(BtoC_overlapping_samples_df$Freezer_ID),]
BtoC_overlapping_sampleID <- unique(BtoC_overlapping_samples_df$SampleID)

CtoB_overlapping_samples_df <- CtoB_overlapping_samples_df[, c("Freezer_ID", "SampleID")]
CtoB_overlapping_samples_df <- CtoB_overlapping_samples_df[order(CtoB_overlapping_samples_df$Freezer_ID),]
CtoB_overlapping_sampleID<- unique(CtoB_overlapping_samples_df$SampleID)

BtoC_overlapping_FreezerID <- unique(BtoC_overlapping_samples_df$Freezer_ID)

cat("Samples in common across both plate B and C are: \n")
print(BtoC_overlapping_FreezerID)
cat("Their aliquot number on Plate B is:")
print(BtoC_overlapping_sampleID)
cat("Their aliquot number on Plate C is:")
print(CtoB_overlapping_sampleID)


cat("\n\n\n\n###############################################################################################\n",
            "9. BOTH PLATES CHECK: PCA PLOT BEFORE BRIDGING \n",
            "###############################################################################################\n\n\n")

#For plate A and C: create merged dataframe for PCA plotting
AtoC_prebridging_df <- plateA_df %>%
  dplyr::mutate(Type = if_else(SampleID %in% AtoC_overlapping_sampleID,paste0("plateA Bridge"),paste0("plateA Sample"))) %>%
  rbind({plateC_df %>% mutate(Type = if_else(SampleID %in% CtoA_overlapping_sampleID, paste0("plateC Bridge"),paste0("plateC Sample"))) %>%
      mutate(SampleID = if_else(SampleID %in% AtoC_overlapping_sampleID,paste0(SampleID, "_new"), SampleID))
  })

#PCA plot of plates A and C without bridging
olink_pca_plot(df = AtoC_prebridging_df, color_g= "Type", byPanel= TRUE)



#For plate B and C: create merged dataframe for PCA plotting
BtoC_prebridging_df <- plateB_df %>%
  mutate(Type = if_else(SampleID %in% BtoC_overlapping_sampleID, paste0("plateB Bridge"), paste0("plateB Sample"))) %>%
  rbind({plateC_df %>%
      mutate(Type = if_else(SampleID %in% CtoB_overlapping_sampleID, paste0("plateC Bridge"),paste0("plateC Sample"))) %>%
      mutate(SampleID = if_else(SampleID %in% BtoC_overlapping_sampleID,paste0(SampleID, "_new"),SampleID))
  })

#PCA plot of plates A and C without bridging
olink_pca_plot(df = BtoC_prebridging_df, color_g= "Type", byPanel= TRUE)


cat("\n\n\n\n###############################################################################################\n",
            "10. PLATES A TO C BRIDGING \n",
            "###############################################################################################\n\n\n")

AtoC_overlap_samples_list <- list("DF1" = AtoC_overlapping_sampleID, "DF2" = CtoA_overlapping_sampleID)

npx_1 <- plateA_df %>% mutate(Project = "data1")%>% as_tibble()
npx_2 <- plateC_df %>% mutate(Project = "data2")%>% as_tibble()

# Perform Bridging normalization
AvsC_bridged_df <- olink_normalization_bridge(project_1_df = npx_1, project_2_df = npx_2,
                                            bridge_samples = AtoC_overlap_samples_list,
                                            project_1_name = "data1", project_2_name = "data2",
                                            project_ref_name = "data1")


cat("\n\n\n\n###############################################################################################\n",
            "11. PLATES B TO C BRIDGING \n",
            "###############################################################################################\n\n\n")

BtoC_overlap_samples_list <- list("DF1" = BtoC_overlapping_sampleID, "DF2" = CtoB_overlapping_sampleID)

npx_1 <- plateB_df %>% mutate(Project = "data1")%>% as_tibble()
npx_2 <- plateC_df %>% mutate(Project = "data2")%>% as_tibble()

# Perform Bridging normalization
BvsC_bridged_df <- olink_normalization_bridge(project_1_df = npx_1, project_2_df = npx_2,
                                            bridge_samples = BtoC_overlap_samples_list,
                                            project_1_name = "data1", project_2_name = "data2",
                                            project_ref_name = "data1")


cat("\n\n\n\n###############################################################################################\n",
            "12. QC OF PLATES A TO C BRIDGING: OLINKANALYZE \n",
            "###############################################################################################\n\n\n")

# Plot NPX density after bridging normalization
AvsC_bridged_df %>%
  mutate(Panel = gsub("Olink ", "", Panel)) %>%
  ggplot(aes(x = NPX, fill = PlateID)) + geom_density(alpha = 0.3) + 
  facet_grid(~Panel) + set_plot_theme() +
  ggtitle("Plate A vs Plate C pre-bridging: NPX distribution") +
  scale_fill_manual('Plate ID', values=c('red', 'darkblue')) +
  theme(strip.text = element_text(size = 16),legend.position = "top")

## After bridging: PCA plot
AvsC_bridged_data <- AvsC_bridged_df %>%
  mutate(Type = ifelse(Freezer_ID %in% AtoC_overlapping_FreezerID, paste(Project, "Bridge"), paste(Project, "Sample")))

# PCA plot
olink_pca_plot(df = AvsC_bridged_data, color_g = "Type", byPanel= TRUE)
olink_pca_plot(df = AvsC_bridged_data, color_g = "Type", byPanel= TRUE,label_samples = TRUE)

cat("\n\n\n\n###############################################################################################\n",
            "13. QC OF PLATES B TO C BRIDGING: OLINKANALYZE \n",
            "###############################################################################################\n\n\n")

Plot NPX density after bridging normalization
BvsC_bridged_df %>%
  mutate(Panel = gsub("Olink ", "", Panel)) %>%
  ggplot(aes(x = NPX, fill = PlateID)) + geom_density(alpha = 0.3) + 
  facet_grid(~Panel) + set_plot_theme() +
  ggtitle("Plate B vs Plate C pre-bridging: NPX distribution") +
  scale_fill_manual('Plate ID', values=c('red', 'darkblue')) +
  theme(strip.text = element_text(size = 16),legend.position = "top")

# After bridging: PCA plot
BvsC_bridged_data <- BvsC_bridged_df %>%
  mutate(Type = ifelse(Freezer_ID %in% BtoC_overlapping_FreezerID, paste(Project, "Bridge"), paste(Project, "Sample")))

# PCA plot
olink_pca_plot(df = BvsC_bridged_data, color_g = "Type", byPanel= TRUE)
olink_pca_plot(df = BvsC_bridged_data, color_g = "Type", byPanel= TRUE,label_samples = TRUE)


cat("\n\n\n\n###############################################################################################\n",
            "14. SAVING THE BRIDGED DATA \n",
            "###############################################################################################\n\n\n")

AvsC_bridged_df %>% 
  dplyr::filter(Project == "data2") %>% 
  dplyr::select(-Project, -Adj_factor) %>% 
  write.csv(, file = "AtoC_bridged_PC.csv")


BvsC_bridged_df %>% 
  dplyr::filter(Project == "data2") %>% 
  dplyr::select(-Project, -Adj_factor) %>% 
  write.csv(, file = "BtoC_bridged_PC.csv")

