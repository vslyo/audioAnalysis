# audioAnalysis
audio analysis tools for reading honest signals
Code as of now is very small and can be understood through comments. Detailed documentation will be added as required.

You will need the Praat software. You can get it at http://www.fon.hum.uva.nl/praat/ .

Instructions as to how to get the relevant data from Praat are present in the screencasts at the main page. Please download the mpg files and view them on your computer.

You can use the praat script 'featureExtraction.praat' to batch process a set of files in a directory and output their feature information in a set of files with a given output directory.

Use the code: usr/bin/praat --run featureExtraction.praat "/input-directory" "/output-directory"
This is the code for a linux system. It is easy to port it to a mac or windows system. Just follow instuctions given in the praat documentation and apply suitable changes.
Please note that the destination directory has to exist before the code is run.
