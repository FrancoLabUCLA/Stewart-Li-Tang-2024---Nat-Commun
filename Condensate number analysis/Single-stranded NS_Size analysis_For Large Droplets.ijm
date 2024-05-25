//Convert to stack
run("Images to Stack", "use");
//run("Make Montage...", "columns=4 rows=3 scale=0.1 label");
selectWindow("Stack");

run("Set Scale...", "distance=1 known=0.07 unit=um global");

//Contrast enhancement
run("Enhance Contrast...", "saturated=0 normalize process_all");
run("Gaussian Blur...","sigma=1.5 stack");
//waitForUser("Check, then hit OK");

//background subtraction, I do this multiple times
run("Subtract Background...","rolling=2 sliding disable stack")
//run("Subtract Background...","rolling=0.5 sliding disable stack")
//run("Subtract Background...","rolling=0.5 sliding disable stack")
//run("Subtract Background...","rolling=0.5 sliding disable stack")
//run("Subtract Background...","rolling=0.5 sliding disable stack")

waitForUser("Check, then hit OK");

//droplet selection
selectWindow("Stack");
setAutoThreshold("Moments dark no-rest stack create");

//Creat mask
selectWindow("Stack");
run("Convert to Mask", "method=Moments background=Dark create");
waitForUser("Check, then hit OK");
run("Analyze Particles...","size=0.03-Infinity show=[Overlay Masks] display clear stack");

//selectWindow("MASK_Stack");
run("Image Sequence... ", "dir=[G:/.shortcut-targets-by-id/1Y7_eW5KXCTmhLilwrD3HU1UDxsF4qxlf/RNA nanostars - Science/Figures/Figure3/PanelI_Cotranscription_Double/forSizeAnalysis/mask_120min/3/] format=TIFF digits=4 use");
