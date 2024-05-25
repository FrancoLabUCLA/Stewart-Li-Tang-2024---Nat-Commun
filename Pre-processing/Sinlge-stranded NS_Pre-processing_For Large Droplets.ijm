//open files and convert to stack
run("Images to Stack", "use");

run("Set Scale...", "distance=1 known=0.07 unit=um global");

//Contrast enhancement
run("Enhance Contrast...", "saturated=0.05 normalize process_all");
run("Gaussian Blur...","sigma=1.5 stack");

//background subtraction, I do this twice
run("Subtract Background...","rolling=9 sliding disable stack")
run("Subtract Background...","rolling=9 sliding disable stack")