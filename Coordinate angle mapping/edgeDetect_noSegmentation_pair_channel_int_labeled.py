__author__ = "Melissa A. Klocke" "Shiyi Li"
__email__ = "klocke@ucr.edu" "shiyili822@ucla.edu"
__version__ = "2.0"


import sys
import os
from re import sub
import imageio as io
from nd2reader import ND2Reader
import matplotlib.pyplot as plt

import numpy as np
import pandas as pd
from scipy import ndimage as ndi
# from skimage.feature import canny		# can probs delete as long as it runs fine
from skimage import (color, filters, measure, morphology, segmentation, restoration, segmentation, exposure)
from skimage.util import img_as_int, img_as_ubyte, img_as_uint, img_as_float, invert, img_as_bool
from skimage.feature import peak_local_max

'''This code uses the same method of edge-based thresholding as originally used "noCombo_edge_detectCondensates.py" but no longer applies
any further segmentation. This is because watershed segmentation works best for homogonously sized objects (the condensates are not) to avoid
merging of small objects and oversegmentation of large objects, and because it is unclear which "touching" objects are in fact unique, merged, 
or soon-to-be merged. This is also faster to run, and doesn't require fiddling with parameters beyond an appropriate smoothing sigma.'''

def main():
	if len(sys.argv)==1:
		print("Need to specify file to process as a parameter.")
		print("   Exiting")
		exit()

	fn = sys.argv[1] 

	dil_s = 4
	dilate_selem = morphology.disk(dil_s)
	dilate_s = 'morphology.disk(%s)' % dil_s
	sigma_val = 5 # was 2.5
	thresh = 'otsu' ## 'yen' or 'tri' or 'otsu' or 'multi' 
	gamma = 0.5
	
	os.system("mkdir _figs")
	print("\nOpening file: ", fn)

	fname, gfp_img, cy3_img, pix_micron = nd2_read(fn) 
	gamma_corrected = gamma_enhance(cy3_img, gamma)
	thresh_img = threshold(gamma_corrected, sigma_val, thresh, dilate_selem, fname)
	labeledImg = measure.label(thresh_img)
	
	prop_df = getCondensateMeasurements(labeledImg, cy3_img, pix_micron)
	label_img(cy3_img, labeledImg, prop_df, fname)
	extract_intensities(cy3_img, gfp_img, labeledImg, thresh_img, fname)

	prop_df.to_csv('_figs/%s_data.csv' % fname)
	saveRunValues(fn, fname, pix_micron, dilate_s, sigma_val, thresh)

	
def nd2_read(fn):
	'''We add "min" to the fname as a tag for combining all the data files for different images into a single file later.'''
	basdir, basename = os.path.split(fn)
	fname, fext = os.path.splitext(basename)

	split_char = '_'
	splitname = fname.split(split_char)
	# splitname[-2] = splitname[-2] + 'min'      
	fname = '_'.join([str(elem) for elem in splitname])

	img = ND2Reader(fn)
	pix_micron = img.metadata['pixel_microns']
	img_GFP = np.array(img.get_frame_2D(c=0))
	img_CY3 = np.array(img.get_frame_2D(c=1))
	return fname, img_GFP, img_CY3, pix_micron

def gamma_enhance(img, gamma):
	gamma_corrected = exposure.adjust_gamma(img, gamma)
	return gamma_corrected

def threshold(img, sigma, thresh, dilate_selem, fn):
	'''---.'''
	gauss_filtered_img = filters.gaussian(img, sigma=sigma)

	edges = filters.sobel(gauss_filtered_img)  #gauss_filtered_img
	if thresh == 'otsu':
		thresh_val = filters.threshold_otsu(edges)
	elif thresh == 'yen':
		thresh_val = filters.threshold_yen(edges)
	elif thresh == 'tri':
		thresh_val = filters.threshold_triangle(edges)
	elif thresh == 'multi':
		thresh_val = filters.threshold_multiotsu(edges)[0]
	# otsuThresh = filters.threshold_otsu(edges)
	# triThresh = filters.threshold_triangle(edges)

	maskImg = edges > thresh_val

	# io.imwrite('_figs/%s_smThresh.png' % fn, img_as_uint(maskImg), format = 'png') 
	# io.imwrite('_figs/%s_combineThresh.png' % fn, img_as_uint(maskLarge+maskSmall), format = 'png') 
	# exit()

	thin = morphology.skeletonize(maskImg)
	filled = ndi.binary_fill_holes(thin)
	cleaned = morphology.binary_opening(filled)
	cleaned = morphology.binary_dilation(cleaned, footprint = dilate_selem)

	# io.imwrite('_figs/%s_Edgethresh.tif' % fn, img_as_uint(maskImg), format = 'tif')
	# io.imwrite('_figs/%s_thinEdgethresh.tif' % fn, img_as_uint(thin), format = 'tif')
	# io.imwrite('_figs/%s_fillEdgethresh.png' % fn, img_as_uint(filled), format = 'png')
	# io.imwrite('_figs/%s_thresh.png' % fn, img_as_uint(cleaned), format = 'png')  
	return cleaned


def getCondensateMeasurements(labeledImg, img, pix_micron):
	props = measure.regionprops(labeledImg,img)

	areas = [r.area for r in props]
	meanIntensities = [r.mean_intensity for r in props]
	eqDiam = [r.equivalent_diameter for r in props]
	centroid = [r.centroid for r in props]
	eccentricity = [r.eccentricity for r in props]
	label = [r.label for r in props]
	bbox = [r.bbox for r in props]

	eqDiam = [i * pix_micron for i in eqDiam]
	# eqDiam = np.round(eqDiam)

	props_dict = {'Label':label, 'Areas (pix^2)': areas, 'Mean Intensity':meanIntensities, 
	'Equivalent Diameter (micron)':eqDiam, 'Eccentricity': eccentricity, 'BBox coords (pix)':bbox}
	df = pd.DataFrame(props_dict)
	return df


def draw_blobs(img, labeledImg):
	# img_equalized = exposure.equalize_adapthist(img, clip_limit=0.1) #, kernel_size=300
	# img_equalized = exposure.rescale_intensity(img)
	# img_equalized = exposure.adjust_gamma(img, gamma=0.5)
	vmin, vmax = np.percentile(img, q=(0.05, 99.95))
	img_equalized = exposure.rescale_intensity(img, in_range=(vmin, vmax), out_range=np.float32)
	# img_equalized = exposure.adjust_gamma(img, gamma=0.5)
	img_equalized = exposure.equalize_adapthist(img_equalized) #, kernel_size=300
	img = color.gray2rgb(img_as_ubyte(img_equalized)) # img_equalized
	edges = filters.sobel(labeledImg) > 0.
	img[edges] = (220, 20, 20)
	return img


def label_img(img, labeledImg, df, fn):
	x_coord = [num[-1] for num in df['BBox coords (pix)']]
	y_coord = [num[0] for num in df['BBox coords (pix)']]
	label = df['Label'].tolist()

	img_blobs = draw_blobs(img, labeledImg)

	fig, ax = plt.subplots(ncols=1, nrows=1, figsize=(10, 10))
	ax.imshow(img_blobs)
	for i in range(len(x_coord)):
		ax.text(x_coord[i],y_coord[i],str(label[i]),fontsize=15, color='palegoldenrod')

	ax.set_title('Detected condensates (red) on droplet image')
	fig.tight_layout()
	fig.savefig('_figs/%s_compimg.%s' % (fn.replace("/","__"), 'png'), dpi=700)
	plt.close()


def saveRunValues(fn, fname, pix_m, dilate_selem, sigma, thresh):
	dict_vals = {'filename': [fn], 'pix to micron': [pix_m], 'dilation selem': [dilate_selem], 'thresh sigma': [sigma], 
		'threshold type': [thresh]} #'BG gaussian value': [BGsigma],
	temp_df = pd.DataFrame(dict_vals)
	temp_df.to_csv('_figs/%s_runvalues.csv' % fname)


def extract_intensities(cy3_img, gfp_img, labeledImg, mask, fn):
    '''Here apply the mask generated from thresholding to both cy3 and GFP channels. Because the mask from previous step has TRUE for 
	signal and FALSE for background, it has to be inverted'''

    mask = np.invert(mask)
    
    temp_cy3 = np.ma.array(cy3_img, mask=mask, dtype=int)
    temp_cy3 = temp_cy3.compressed()
    temp_GFP = np.ma.array(gfp_img, mask=mask, dtype=int)
    temp_GFP = temp_GFP.compressed()
    temp_label = np.ma.array(labeledImg, mask=mask)
    temp_label = temp_label.compressed()
  
    dict = {'CY3_Intensity':temp_cy3,'GFP_Intensity':temp_GFP, 'Label':temp_label}
    drop_intensity = pd.DataFrame(dict)
    
    drop_intensity.to_csv('_figs/%s_intensity.%s' % (fn.replace("/","__"), 'csv'))



if __name__ == '__main__':
	main()