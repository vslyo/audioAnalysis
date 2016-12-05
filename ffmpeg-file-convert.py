"""Script to go through files in a directory with a specific file name of given format and use ffmpeg to convert it to a given format.

Run Instructions:
python ffmpeg-file-convert.py <INPUT FILE/ FILE PATTERN> <INPUT FORMAT> <OUTPUT DIRECTORY> <OUTPUT FORMAT> <DELETE ORIGINAL>
DELETE ORIGINAL has values d - delete else no delete
"""

from glob import glob
import re
import sys
import os
import subprocess

dlt = 0

if sys.argv[5] == 'd':
    dlt = 1

idir = '/'.join(sys.argv[1].split('/')[:-1]) + '/'
istr = sys.argv[1].split('/')[-1]
ifmt = sys.argv[2]

odir = sys.argv[3]
if odir[-1] != '/':
    odir = odir + '/'
try:
    os.stat(odir)
except:
    print 'Output folder does not exist! Please create it'
ofmt = sys.argv[4]

files = glob(idir + istr)

for fname in files:
    if fname.split('.')[-1] == ifmt:
        subprocess.call(['ffmpeg', '-i', fname, odir + re.sub(ifmt + '$', ofmt, fname.split('/')[-1])])
        if dlt == 1:
            subprocess.call(['rm', fname])
