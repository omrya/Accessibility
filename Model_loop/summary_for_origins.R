library(magrittr)
library(sf)
library(dplyr)

# Working dir
setwd("D:\\Data_for_model")
#setwd("D:\\")

# Get shapefile names
files = list.files(path = "./output/", pattern = "\\.shp$", full.names = TRUE)

# List of tables per origin
final = list()

# List of unread shapefiles
i_error = c()

# For file i...
for(i in files) {
  
  # Try reading file
  dat = try(st_read(i, stringsAsFactors = FALSE))
  
  # If error - keep name
  if(class(dat) == "try-error") i_error = c(i_error, i)
  
  # If success - continue processing
  if(class(dat) != "try-error") {
  
    # Time statistics for each origin
    dat_attr = 
      dat %>% # shapefile
      st_set_geometry(NULL) %>% # Drop geometry 
      group_by(OriginID) %>% # Group by origin
      summarise( # Summary
        mean = mean(Total_Trav),
        sd = sd(Total_Trav),
        min = min(Total_Trav),
        max = max(Total_Trav)
      ) %>% 
      ungroup %>% 
      as.data.frame
    
    # X-Y for each origin
    dat_geo = dat[!duplicated(dat$OriginID), ] # Remove duplicated lines for origin ID
    geom = st_geometry(dat_geo) # Keep only geometry
    x = sapply(geom, function(x) x[1, 1]) # Extract X of 1st point in each line
    y = sapply(geom, function(x) x[1, 2]) # Extract Y of 1st point in each line
    dat_geo = data.frame( # Build table with ID, X and Y
      OriginID = dat_geo$OriginID,
      orig_x = x,
      orig_y = y,
      stringsAsFactors = FALSE
    )
    
    final[[i]] = left_join(dat_geo, dat_attr, "OriginID") # Join X-Y with time stats
    
  }

}

final = do.call(rbind, final) # Combine list of table to one big table
final$OriginID = NULL
# rownames(final) = 1:nrow(final)

# To point layer
tmp = st_as_sf(final, coords = c("orig_x", "orig_y"), crs = 4326)

# Export Shapefile
st_write(tmp, "origins_summary.shp")
  
  
  


