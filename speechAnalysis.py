#!/usr/bin/env python2.7
"""
A set of functions to read data files written by praat and convert them to python constructs for further processing. As suggested by the names they read the intensity, pitch and pace data returned by praat.

"""

# Reads a headerless spreadsheet file (.txt extension generally) of intensity from praat. In order to get this, first read a sound file to praat, then convert to Intensity(To Intensity). Convert the Intensity to IntensityTier and then to TableOfReal. Save the TableOfReal as headerless spreadsheet.
def readIntens(s):
    
    f = open(s, 'r')
    inte = f.read().split('\n')
    inte.pop(0)
    f.close()
    
    inte = '\t'.join(inte).split('\t')
    intens = []
    i = 0
    while i < len(inte):
        intens.append((float(inte[i+1]), float(inte[i+2])))
        i += 3
    
    return intens
    # The returned object is a list of tuples with the first element of the tuple the time and the second element the intensity in dB at that time

# Reads a headerless spreadsheet file (.txt extension generally) of pitch tiers from praat. In order to get this, first read a sound file to praat, then convert to Pitch from the 'Analyse periodicity' utility. Convert the Pitch object to PitchTier using the 'Convert' utility. Then save the PitchTier as a headerless spreadsheet file.
def readPitch(s):
    
    f = open(s, 'r')
    pit = f.read().split()
    f.close()
    
    pitch = []
    i = 0
    while i < len(pit):
        pitch.append((float(pit[i]), float(pit[i+1])))
        i += 2
    
    return pitch
    # The returned object is a list of tuples with the first element of the tuple the time and the second element the pitch in Hz at that time

# Reads a comma separated file (.Table extension generally) of table of phone data from praat. In order to get this the syllable nuclei (i've only used v2) praat script is required. Open this praat script from praat and run it (only the '/directory' field need be changed to the folder where your sound files are placed, I didn't require tweaking any parameters). A TextGrid object is obtained. Use the 'Down to Table...' utility to convert it to a Table object. Save the Table object as a comma separated file. 
def readPace(s):
    
    f = open(s, 'r')
    pac = f.read().split('\n')
    pac.pop(0)
    f.close()
    
    pace = []
    i = 0
    while i < len(pac):
        s = pac[i].split(',')
        pace.append((float(s[0]), float(s[3]), s[1], s[2]))
        i += 1
    
    return pace
    # The returned object is a list of tuples with the first two elements the start and end times of the instance respectively. The nest two elements label the segment of sound as either a silence, which is sounding or silent, or a syllable, and its count.

if __name__ == "__main__":
    print "Sorry, main functionalities not yet provided :<"
