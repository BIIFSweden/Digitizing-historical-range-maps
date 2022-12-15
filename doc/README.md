# Documentation

The project contains two ImageJ macros:
 - export_map_panels.ijm
 - align_bUnwarpJ.ijm


## Inputs
Maps were scanned at 600 dpi, full color, and saved in .jpg format. Each scanned image contains four panels. Two examples are in the folder `/data/scanned_maps`.

## 1. ImageJ (fiji) macro used to cut each of the map panels separately 
Using the first script, maps are cut into separate images.
/src/export_map_panels.ijm 

input
```
/data/scanned_maps/p1.jpg
```

output
```
/results/cut_maps/h_1.jpg
/results/cut_maps/h_2.jpg
/results/cut_maps/h_3.jpg
/results/cut_maps/h_4.jpg
```


## 2. ImageJ (fiji) macro used to align each map to a reference image (bUnwarpJ) 

/macro/align_bUnwarpJ.ijm

input
```
/results/cut_maps/h_1.jpg
/results/reference/ref_map.jpg
```

output
```
/results/registered_maps/h_1.jpg
```
