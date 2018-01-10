load("data/cache/USmapAndDataMerged.RData")

States <- unique(US@data$STATE)[order(unique(US@data$STATE))]

dir.create("StateMaps")

library(doParallel)
registerDoParallel(cores=5)

start <- proc.time()
temp <- foreach(i = 1:length(States)) %dopar% {
  StateMap = US[US@data$STATE==States[i],]
  save(StateMap, file = paste0("StateMaps/",States[i],".Rdata"))
  i
  }

rm(temp)

end <- proc.time()

end-start



# for(i in 1:length(States)) {
#   StateMap = US[US@data$STATE==States[i],]
#   save(StateMap, file = paste0("StateMaps/",States[i],".Rdata"))
# }

unlink("data/cache/", recursive=TRUE)

#clean up directory
#unlink("data/cache/",recursive = TRUE)
#unlink("data/cache/nhgis0017_shape/",recursive = TRUE)
#unlink("data/cache/US_blk_grp_2010/",recursive = TRUE)