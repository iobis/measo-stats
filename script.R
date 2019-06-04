library(rgdal)
library(robis)
library(wicket)
library(dplyr)

measo = readOGR(dsn = "./SHP/measo_regions03_ll.shp")

results <- list()

for (i in 1:length(measo)) {
  name <- measo@data$name[i]
  if (!is.na(name)) {
    wkt <- sp_convert(measo[i,])
    occ <- occurrence(geometry = wkt, fields = c("decimalLongitude", "decimalLatitude", "eventDate", "scientificName", "speciesid"))
    results[[i]] <- occ
  }
}

names(results) <- measo@data$name
occ <- bind_rows(results, .id = "area")
occ <- occ[!duplicated(occ$id),]

occ %>% group_by(area) %>% summarize(records = n(), species = length(unique(speciesid))) %>% arrange(desc(records))
