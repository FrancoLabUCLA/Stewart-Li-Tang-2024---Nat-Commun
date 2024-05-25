function Whitehat_Maxentropy(input, output, filename){
	open(input + filename);
	run("Enhance Contrast...", "saturated=0.05");
	run("Morphological Filters", "operation=[White Top Hat] element=Disk radius=20");
	resetMinAndMax();
	
	run("Gaussian Blur...","sigma=2 stack");
	run("Smooth");
	run("Smooth");
	run("Smooth");
	
	setAutoThreshold("MaxEntropy dark no-reset");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
//	waitForUser("Check, then hit OK");
	
	saveAs("tiff", output + filename);
	close();
	close();
}

input = getDirectory("Input dir");
output = getDirectory("Output dir");
list = getFileList(input);

for(i = 0; i < list.length; i++){
	Whitehat_Maxentropy(input, output, list[i]);
}
