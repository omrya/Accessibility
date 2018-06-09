#All routes from Dan BS
install.packages("SIRItoGTFS")
SIRItoGTFS::readGTFS(data.table = F)
#Dan Badarom = 31 (before the reform)
routes <- GTFSroutes[GTFSroutes$agency_id == 32,]
write.table(routes,"C:\\Accessibility_data\\gtfs_data\\routes.txt", sep = ",", row.names = FALSE)

#All trips among specifiec route
trips <- GTFStrips[GTFStrips$route_id %in% routes$route_id,]
write.table(trips,"C:\\Accessibility_data\\gtfs_data\\trips.txt", sep = ",", row.names = FALSE)

shapes <- GTFSshapes[GTFSshapes$shape_id %in% trips$shape_id,]
write.table(shapes,"C:\\Accessibility_data\\gtfs_data\\shapes.txt", sep = ",", row.names = FALSE)
 
stop_times <- GTFSstop_times[GTFSstop_times$trip_id %in% trips$trip_id,]
write.table(stop_times,"C:\\Accessibility_data\\gtfs_data\\stop_times.txt", sep = ",", row.names = FALSE)

stops <- GTFSstops[GTFSstops$stop_id %in% stop_times$stop_id,]
write.table(stops,"C:\\Accessibility_data\\gtfs_data\\stops.txt", sep = ",", row.names = FALSE)

calendar <- GTFScalendar[GTFScalendar$service_id %in% trips$service_id,]
write.csv(calendar,"C:\\Accessibility_data\\gtfs_data\\calendar.txt",row.names = FALSE)

  
