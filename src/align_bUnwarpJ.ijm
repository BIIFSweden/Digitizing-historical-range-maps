/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input images directory", style = "directory") input
#@ File (label = "Output images  directory", style = "directory") output
#@ File (label = "Reference image", style = "open") ref


/* 
 * Function to remove black pixels from image 
 * and replace them with median of the surounding pixels
 */
function removeBlack () {
    // Save image name, and duplicate image:
    a=getImageID();
    run("Duplicate...", " ");
    rename("temporary");
    // Convert image to grayscale
    run("8-bit");
    // Threshold image to get all black pixels:
    setThreshold(0, 130);
    // Save it as a selection and copy selection to color image:
    run("Create Selection");
    run("Enlarge...", "enlarge=2");
    roiManager("Add");
    close("temporary");
    selectImage(a);
    count = roiManager("count");
    roiManager("Select", count-1);
    roiManager("Delete");
    // convert black pixels to median value of neighborhood:
    run("Clear", "slice");
    run("Invert");
    run("Gaussian Blur...", "sigma=10");
    run("Median...", "radius=10");
    // clear selection:
    run("Select None");
}

// We run in batch mode, which hide windows of images during process:
//setBatchMode("hide");
setBatchMode("show");

// We load the reference image:
open(ref); //open file

// Remove black pixels from reference image:
removeBlack();
ref_name=getTitle(); //save file name as a variable

//Browse through all images in folder:
list = getFileList(input);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
    open(input+"/"+list[i]); //open file
    original_name=getTitle(); //save file name as a variable
    run("Duplicate...", " ");
    rename("Duplicate");
    // Remove black pixels from image:
    removeBlack();
    img_name=getTitle(); //save file name as a variable
    
    // Run bunwarpJ and save transformation
    run( "bUnwarpJ", "source_image="+img_name+" target_image="+ref_name+" registration=Mono " +
      "image_subsample_factor=1 initial_deformation=[Very Coarse] " +
      "final_deformation=[Fine] divergence_weight=0.1 curl_weight=0.1 landmark_weight=0 " +
      "image_weight=1 consistency_weight=10 stop_threshold=0.01 " +
      "save_transformations " +
      "save_direct_transformation="+output+"/transform.txt");
    // Close unused images:
    //close(img_name);
    //close("Registered Target Image");
    //close("Registered Source Image");

    // Apply saved transformation on the image with black pixels:
    call("bunwarpj.bUnwarpJ_.loadElasticTransform", output+"/transform.txt", ref_name, original_name);
    
    saveAs("jpg", output+"/"+original_name); //save panel in output folder
    //close(original_name);
    exit():
}
close(ref_name);
setBatchMode("show");
