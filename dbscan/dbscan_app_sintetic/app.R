#############Synthetic DS################

library(magrittr)
library(shiny)
library(leaflet)
library(sp)
library(rgeos)
library(dbscan)
library(factoextra)
library(fpc)


dat = read.csv("sint_times_wgs84.csv", stringsAsFactors = FALSE) # Read CSV

dupl = duplicated(dat[, c("lon", "lat")]) #
dat = dat[!dupl, ]
coordinates(dat) = ~ lon + lat
proj4string(dat) = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
box = bbox(dat)
dat = spTransform(dat, "+proj=utm +zone=36 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

ui = bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
    sliderInput(
      "eps", "Epsilon", 
      min = 1, max = 10000, value = 200, step = 100
    ),
    sliderInput(
      "minPts", "Min. Points", 
      min = 1, max = 100, value = 1, step = 5
    )
  )
)

server = function(input, output, session) {
  
  pnt = reactive({
    
    pnt = dat
    res = dbscan::dbscan(cbind(coordinates(pnt), pnt$mean * 166.6667), eps = input$eps, minPts = input$minPts)
    pnt$clus = res$cluster
    pnt$clus[pnt$clus == 0] = NA
    pnt
  })
  
  ch = reactive({
    
    pnt_l = split(pnt(), pnt()$clus)
    point_count = sapply(pnt_l, nrow)
    pnt_l = pnt_l[point_count >= input$minPts]
    ch = lapply(pnt_l, gConvexHull)
    ch$makeUniqueIDs = TRUE
    ch = do.call(rbind, ch)
    ch = SpatialPolygonsDataFrame(
      ch, 
      data.frame(clus = pnt_l %>% names %>% as.numeric), 
      match.ID = FALSE
    )
    ch$count = sapply(pnt_l, nrow)
    ch
    
  })
  
  pal_rand = reactive({
    
    pal = colorFactor("Spectral", pnt()$clus)
    clus_range = range(pnt()$clus, na.rm = TRUE)
    random_colors = 
      seq(clus_range[1], clus_range[2]) %>% 
      pal %>% 
      sample
    colorFactor(random_colors, pnt()$clus)
    
  })
  
  output$map = renderLeaflet({
    
    leaflet() %>% 
      addTiles %>% 
      fitBounds(box[1,1], box[2,1], box[1,2], box[2,2])
  })
  
  observe({
    pnt() %>% spTransform("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") %>% print
    leafletProxy("map") %>%
      clearMarkers %>%
      clearShapes %>%
      addCircleMarkers(
        data = pnt() %>% spTransform("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"),
        group = "Points",
        color = ~pal_rand()(clus)
      ) %>%
      addPolygons(
        data = ch() %>% spTransform("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"),
        group = "Polygons",
        color = "black", dashArray = c(5, 5), opacity = 1, weight = 2,
        popup = ~as.character(count),
        fillColor = ~pal_rand()(clus)
      ) %>%
      addLayersControl(
        position = "bottomright",
        overlayGroups = c("Points", "Polygons"), 
        options = layersControlOptions(collapsed = FALSE)
        )
  })
}

shinyApp(ui, server)
