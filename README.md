# Olink_normalization
Whenever plates need to be normalized to each other

#1. TEMPLATE_CREATION.R: creates the all_template_df.csv which has for each sanple aliquot the corresponding TARTAGLIA ID (STUDY ID.) This is required for the bridge normalization.PlateAtoC_template is an intermediate step where I manually added for a subset of the subjects the corresponding TARTAGLIA ID as I did not have a clean spreadsheet. Then the code grabs information from other spreadsheet and consolidates them into all_template_df.csv.

#2 BRIDGE_NORMALIZATION.R: normalizes plate A to plate C, and plate B to plate C. It creates a new file, all_plates.csv, which has the data from all plates pre-bridging and allows for basic comparisons of format, assays, etc. Then the plates are bridged (AtoC_bridged_PC.csv and BtoCbridged_PC.csv). 

#3 DEMOGRAPHICS_CREATION.R: create a file with all dempgrphics for the bridged data. For now focus on the local FTLD cohort as it is the only one of interest for now. But will need the HC data too. 

#4 BRIDGE_NORMALIZATION_VALIDATION.R: not done yet but will perform analyses to comapre outputs of plate 1 and plate 2 after normalziation to plate 3. 