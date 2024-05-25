# To detect condensates in 10 random images within the directory

ls *.nd2 | sort -R | tail -n10 | while read file ; do py edgeDetect_noSegmentation_pair_channel_int_labeled.py $file ; done