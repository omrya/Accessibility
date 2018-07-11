
# Import arcpy module
import arcpy
from arcpy import env
from datetime import datetime

start = datetime.now()

arcpy.CheckOutExtension("Network")
arcpy.env.overwriteOutput = True

for i in range(0,115):

    env.workspace = "C:/Accessibility_data/gis_data/add_gtfs_model/gtfs_2018.gdb"
    arcpy.MakeFeatureLayer_management("bldgs_all_centroid", "build_lyr")

    # Process: Make OD Cost Matrix Layer
    arcpy.MakeODCostMatrixLayer_na("gtfs_2017_ND", "OD Cost Matrix" + str(i), "TravelTime_WithTransit", "", "", "", "ALLOW_UTURNS", "", "NO_HIERARCHY", "", "STRAIGHT_LINES", "31/12/1899 08:00:00")

    # Process: Select Layer By Attribute
    arcpy.SelectLayerByAttribute_management("build_lyr", "NEW_SELECTION", "(OBJECTID > " + str(i*200 ) + ") AND (OBJECTID <= " + str((i+1)*200)+")")

    # Process: Add Locations- Origins
    arcpy.AddLocations_na("OD Cost Matrix" + str(i), "Origins", "build_lyr", "Name Name #;TargetDestinationCount TargetDestinationCount #;CurbApproach CurbApproach 0;Cutoff_Length Cutoff_Length #;Cutoff_TravelTime_WithTransit Cutoff_TravelTime_WithTransit #", "5000 Meters", "", "Connectors_Stops2Streets SHAPE;Streets_UseThisOne SHAPE;TransitLines SHAPE;Stops SHAPE;Stops_Snapped2Streets SHAPE; NONE", "MATCH_TO_CLOSEST", "APPEND", "NO_SNAP", "5 Meters", "INCLUDE", "Connectors_Stops2Streets #;Streets_UseThisOne #;TransitLines #;Stops #;Stops_Snapped2Streets #;gtfs_2017_ND_Junctions #")

    # Process: Add Locations- Destinations
    arcpy.AddLocations_na("OD Cost Matrix" + str(i), "Destinations", "bldgs_all_centroid", "Name Name #;CurbApproach CurbApproach 0", "8000 Meters", "", "Connectors_Stops2Streets SHAPE;Streets_UseThisOne SHAPE;TransitLines SHAPE;Stops SHAPE;Stops_Snapped2Streets SHAPE;gtfs_2017_ND_Junctions NONE", "MATCH_TO_CLOSEST", "APPEND", "NO_SNAP", "5 Meters", "INCLUDE", "Connectors_Stops2Streets #;Streets_UseThisOne #;TransitLines #;Stops #;Stops_Snapped2Streets #;gtfs_2017_ND_Junctions #")

    #Omry: Check for add location (override)
    
    # Delete
    arcpy.Delete_management("build_lyr")
    
    try:
        # Process: Solve
        arcpy.Solve_na("OD Cost Matrix" + str(i), "SKIP", "TERMINATE", "")

        # Process: Select Data
        arcpy.SelectData_management("OD Cost Matrix" + str(i), "Lines")

        # Process: Copy Features
        env.workspace = "D:/Data_for_model/output"
        arcpy.CopyFeatures_management("Lines", "lines_" + str(i) + ".shp", "", "0", "0", "0")

        # Delete
        arcpy.Delete_management("OD Cost Matrix" + str(i))
		
		# Print
		#print("success! " + i)
		#print(datetime.now())
		#print(i)

    except:
        arcpy.Delete_management("OD Cost Matrix" + str(i))
		
		# Print
		#print("error! " + i)
		#print(datetime.now())
        continue  

end = datetime.now()

print(end - start)
