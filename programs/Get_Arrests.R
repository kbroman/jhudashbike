#### Import and format the BPD Arrest Data ####
#### From open Baltimore

# This is a direct link to the file
# download.file("https://data.baltimorecity.gov/api/views/3i3v-ibrt/rows.csv?accessType=DOWNLOAD",
#               "Arrests/BPD_Arrests.csv")

arrests <- read.csv("Arrests/BPD_Arrests.csv")
keep <- c("ArrestDate","ArrestTime","ArrestLocation",
          "ChargeDescription","Location.1")
arrests <- arrests[arrests$Location.1 != "" & arrests$ArrestLocation != "",keep]
arrests <- arrests[!grepl("(unknown|Failure to appear)", 
                          arrests$ChargeDescription, ignore.case = T),]

arrests$Location.1 <- gsub("\\(","", arrests$Location.1)
arrests$Location.1 <- gsub("\\)","", arrests$Location.1)

arrests$lat <- gsub(",.*$","",arrests$Location.1)
arrests$long <- gsub("^.*, ","",arrests$Location.1)

arrests <- arrests[, c("ArrestDate","ArrestTime","ArrestLocation","lat","long",
                       "ChargeDescription")]

save(arrests, file = "Arrests/arrests.rda")
