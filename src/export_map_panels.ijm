macro "Export map panels" {
    dir = getDirectory("Choose directory containing only images."); //get input directory
    dir2 = getDirectory("Choose directory for exported map panels."); //get ouput directory
    setBatchMode(true); //do everything after this line without visually opening the images
    file_list = getFileList(dir); //list all files in input folder
    for (i=0; i<file_list.length; i++) { //for each file:
        open(dir+file_list[i]); //open file
        img_name=getTitle(); //save file name as a variable
        run("Auto Crop");
        width = getWidth(); //get pixel width of image
        min_size = (width / 3)^2; //calculate minimum expected size of the map panels
        run("Duplicate...", "title="+img_name+"_mask"); //duplicate image
        selectWindow(img_name+"_mask"); //select image duplicate
        run("8-bit"); //transform to 8 bit (greyscale)
        run("Convert to Mask"); //transform greyscale into black & white
        run("Dilate"); //slightly dilate black pixels to close holes in the outline
        run("Erode"); //now erode the mask to minimise white borders
        run("Analyze Particles...", "size="+min_size+"-Infinity show=Nothing include add"); //detect panels
        roiManager("Select", 0); //select first ROI
        X0 = getValue("X"); //get x coordinate of the first ROI's centre
        Y0 = getValue("Y"); //get y coordinate of the first ROI's centre
        roiManager("Select", 1); //select second ROI
        X1 = getValue("X"); //get x coordinate of the second ROI's centre
        Y1 = getValue("Y"); //get y coordinate of the second ROI's centre
        makeLine(X0, Y0, X1, Y1); //make a line from the centre of the first to the centre of the second ROI
        skew = getValue("Angle"); //measure angle of that line
        if (skew > 10) { // make sure the angle isn't measured from the wrong side (e.g. -173 insted of 7)
            skew = skew - 180;
        }
        if (skew < -10) {
            skew = skew + 180;
        }
        selectWindow(img_name);
        run("Rotate... ", "angle="+skew+" interpolation=Bilinear"); //rotate image by the measured angle
        for (n = 0; n < roiManager("count"); n++){ //for each ROI:
            selectWindow(img_name); //select original image
            run("Duplicate...", "title="+img_name+"_"+n); //duplicate original image
            selectWindow(img_name+"_"+n); //select duplicate
            roiManager("Select", n); //select ROI
            XROI = getValue("X"); //get x coordinate of the ROI's centre
            YROI = getValue("Y"); //get y coordinate of the ROI's centre
            if (XROI < (width / 2) && YROI < (width / 2)) { //check which panel the ROI covers
                panel = "1";
            }
            if (XROI > (width / 2) && YROI < (width / 2)) { //check which panel the ROI covers
                panel = "2";
            }
            if (XROI < (width / 2) && YROI > (width / 2)) { //check which panel the ROI covers
                panel = "3";
            }
            if (XROI > (width / 2) && YROI > (width / 2)) { //check which panel the ROI covers
                panel = "4";
            }
            run("Rotate...", "rotate angle="+skew); //rotate ROI by the measured angle
            run("Crop"); //crop to panel outline
            saveAs("jpg", dir2+img_name+"_"+panel+".jpg"); //save panel in output folder
            close(); //close image
        }
        run("Close All"); //close all remaining open images
        roiManager("Deselect"); //deselect ROI
        roiManager("Delete"); //delete all ROIs
    }
    setBatchMode(false);
}
