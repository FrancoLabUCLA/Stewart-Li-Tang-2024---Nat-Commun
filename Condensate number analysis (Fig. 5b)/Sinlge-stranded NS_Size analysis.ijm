//Convert to stack
run("Images to Stack", "use");

run("Set Scale...", "distance=1 known=0.07 unit=um global");

//Contrast enhancement
run("Enhance Contrast...", "saturated=0 normalize process_all");
run("Gaussian Blur...","sigma=2 stack");

//waitForUser("Check, then hit OK");

//background subtraction, I do this multiple times
run("Subtract Background...","rolling=0.5 sliding disable stack")
run("Subtract Background...","rolling=0.5 sliding disable stack")
run("Subtract Background...","rolling=0.5 sliding disable stack")
run("Subtract Background...","rolling=0.5 sliding disable stack")
run("Subtract Background...","rolling=0.5 sliding disable stack")

waitForUser("Check, then hit OK");

//droplet selection
setAutoThreshold("Moments dark no-rest stack create");

//Creat mask
run("Convert to Mask", "method=Moments background=Dark create");
waitForUser("Check, then hit OK");

run("Analyze Particles...","size=0.03-Infinity show=[Overlay Masks] display clear stack");

