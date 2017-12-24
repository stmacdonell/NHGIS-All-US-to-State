csvfile <- "data/raw/nhgis0017_csv.zip"
shapefile <- "data/raw/nhgis0017_shape.zip"

dir.create("data/cache")
dir.create("data/cache/csv")
dir.create("data/cache/shape")
dir.create("data/cache/USshape")

library(rgdal)

#unpack files from NHGIS
unzip(csvfile,exdir = "data/cache/csv/")
unzip(shapefile,exdir = "data/cache/shape/")

shapefile <- paste0("data/cache/shape/",list.files("data/cache/shape/"),"/")
shapefile <- paste0(shapefile,list.files(shapefile))

unzip(shapefile, exdir="data/cache/USshape")

layer <- list.files("data/cache/USshape/")
library(tools)
layer <- file_path_sans_ext(layer[[1]])

#map
US <- readOGR(dsn="data/cache/USshape/",layer=layer,stringsAsFactors = FALSE)

rm(layer)
#save(US,file="data/cache/US.RData")
#load("data/cache/US.RData")

csvfile <- paste0("data/cache/csv/",list.files("data/cache/csv/"),"/")
csvfile <- paste0(csvfile,list.files(csvfile))
csvfile <- csvfile[[2]]

#csv data
USdata <- read.csv(csvfile,stringsAsFactors = FALSE)

#save(USdata,file="data/cache/USdata.RData")

#which rows in the data are on the map
onMap <- sapply(USdata$GISJOIN, FUN=function(x){
  x%in%US@data$GISJOIN
  })

#verify no one lives in unmatched polygons
sum(USdata$H7Q001[!onMap])

#verify that there are no unmatched blocks on map
sum(!onMap)+length(US)==dim(USdata)[1]

rm(onMap)

#load("data/cache/US.RData")
#load("data/cache/USdata.RData")

#what is the original order of the data
US@data$index <- 1:length(US)

#merge in the data
US@data <- merge(US@data,USdata,by="GISJOIN",all.x=TRUE,all.y=FALSE)

#sort according to original order
US@data <- US@data[order(US@data$index),]

#save the data
save(US,file="data/cache/USmapAndDataMerged.RData")

rm(list = ls())