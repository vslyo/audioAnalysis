#########
#
# Praat script to obtain features for use in audio analysis. The script takes in a directory and evaluates pitch,
# intensity, formants and pace for each file and stores it as a set of text files. Default praat scripts are used
# for pitch, intensity and formants whereas pace uses the:
#
### Praat Script Syllable Nuclei ###
### Copyright (C) 2008  Nivja de Jong and Ton Wempe ###
#
# whose documentation and copyright information can be found at the end of this document.
# Their original script is modified and some functionalities added to make this script.
#
#########

form Counting Syllables in Sound Utterances
   sentence Input_Directory /directory
   sentence Output_Directory /directory
endform

# default values of variables used in original script
silencedb = -25
mindip = 2
minpause = 0.3
directory$ = input_Directory$
odir$ = output_Directory$

# read files
strid = Create Strings as file list... list 'directory$'/*.wav
numberOfFiles = Get number of strings

# Iterate though all the files
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   Read from file... 'directory$'/'fileName$'
   # Getting filename for saving files
   fileName$ = replace$ (fileName$, ".wav", "", 1)

   ### The pace extraction part by Nivja de Jong and Ton Wempe ###
   # use object ID
   soundname$ = selected$("Sound")
   soundid = selected("Sound")

   originaldur = Get total duration
   # allow non-zero starting time
   bt = Get starting time

   # Use intensity to get threshold
   To Intensity... 50 0 yes
   intid = selected("Intensity")
   start = Get time from frame number... 1
   nframes = Get number of frames
   end = Get time from frame number... 'nframes'

   # estimate noise floor
   minint = Get minimum... 0 0 Parabolic
   # estimate noise max
   maxint = Get maximum... 0 0 Parabolic
   #get .99 quantile to get maximum (without influence of non-speech sound bursts)
   max99int = Get quantile... 0 0 0.99

   # estimate Intensity threshold
   threshold = max99int + silencedb
   threshold2 = maxint - max99int
   threshold3 = silencedb - threshold2
   if threshold < minint
       threshold = minint
   endif

   # get pauses (silences) and speakingtime
   To TextGrid (silences)... threshold3 minpause 0.1 silent sounding
   textgridid = selected("TextGrid")
   silencetierid = Extract tier... 1
   silencetableid = Down to TableOfReal... sounding
   nsounding = Get number of rows
   npauses = 'nsounding'
   speakingtot = 0
   for ipause from 1 to npauses
      beginsound = Get value... 'ipause' 1
      endsound = Get value... 'ipause' 2
      speakingdur = 'endsound' - 'beginsound'
      speakingtot = 'speakingdur' + 'speakingtot'
   endfor

   select 'intid'
   Down to Matrix
   matid = selected("Matrix")
   # Convert intensity to sound
   To Sound (slice)... 1
   sndintid = selected("Sound")

   # use total duration, not end time, to find out duration of intdur
   # in order to allow nonzero starting times.
   intdur = Get total duration
   intmax = Get maximum... 0 0 Parabolic

   # estimate peak positions (all peaks)
   To PointProcess (extrema)... Left yes no Sinc70
   ppid = selected("PointProcess")

   numpeaks = Get number of points

   # fill array with time points
   for i from 1 to numpeaks
       t'i' = Get time from index... 'i'
   endfor 


   # fill array with intensity values
   select 'sndintid'
   peakcount = 0
   for i from 1 to numpeaks
       value = Get value at time... t'i' Cubic
       if value > threshold
             peakcount += 1
             int'peakcount' = value
             timepeaks'peakcount' = t'i'
       endif
   endfor


   # fill array with valid peaks: only intensity values if preceding 
   # dip in intensity is greater than mindip
   select 'intid'
   validpeakcount = 0
   currenttime = timepeaks1
   currentint = int1

   for p to peakcount-1
      following = p + 1
      followingtime = timepeaks'following'
      dip = Get minimum... 'currenttime' 'followingtime' None
      diffint = abs(currentint - dip)

      if diffint > mindip
         validpeakcount += 1
         validtime'validpeakcount' = timepeaks'p'
      endif
         currenttime = timepeaks'following'
         currentint = Get value at time... timepeaks'following' Cubic
   endfor


   # Look for only voiced parts
   select 'soundid' 
   To Pitch (ac)... 0.02 30 10 no 0.03 0.25 0.01 0.35 0.25 600
   # keep track of id of Pitch
   pitchid = selected("Pitch")

   voicedcount = 0
   for i from 1 to validpeakcount
      querytime = validtime'i'

      select 'textgridid'
      whichinterval = Get interval at time... 1 'querytime'
      whichlabel$ = Get label of interval... 1 'whichinterval'

      select 'pitchid'
      value = Get value at time... 'querytime' Hertz Linear

      if value <> undefined
         if whichlabel$ = "sounding"
             voicedcount = voicedcount + 1
             voicedpeak'voicedcount' = validtime'i'
         endif
      endif
   endfor


   # calculate time correction due to shift in time for Sound object versus
   # intensity object
   timecorrection = originaldur/intdur

   # Insert voiced peaks in TextGrid
   select 'textgridid'
   Insert point tier... 1 syllables

   for i from 1 to voicedcount
       position = voicedpeak'i' * timecorrection
       Insert point... 1 position 'i'
   endfor

   ### End of original script part of new script ###

   # Save textgrid and remove
   selectObject: 'textgridid'
   textgridTableid = Down to Table... no 6 yes no
   Save as comma-separated file... 'odir$'/'fileName$'-pace.txt
   removeObject: textgridTableid

   # Save intensity and remove
   selectObject: intid
   intTiid = Down to IntensityTier
   intTORid = Down to TableOfReal
   Save as headerless spreadsheet file... 'odir$'/'fileName$'-intensity.txt
   removeObject: intTiid, intTORid

   # Save pitch and remove
   selectObject: pitchid
   pitchTierid = Down to PitchTier
   Save as headerless spreadsheet file... 'odir$'/'fileName$'-pitch.txt
   removeObject: pitchTierid

   # Save formants and remove; remove sound
   selectObject: soundid
   forid = To Formant (burg)... 0 5.0 7000.0 0.025 50.0
   forTid = Down to Table... no yes 6 no 3 yes 3 yes
   Save as comma-separated file... 'odir$'/'fileName$'-formants.txt
   removeObject: forid, forTid

   # clean up before next sound file is opened
   select 'intid'
   plus 'matid'
   plus 'sndintid'
   plus 'ppid'
   plus 'pitchid'
   plus 'silencetierid'
   plus 'silencetableid'
   plus 'soundid'
   plus 'textgridid'

   Remove

endfor

# clean up string of files
select strid

Remove

###########################################################################
#                                                                         #
#  Praat Script Syllable Nuclei                                           #
#  Copyright (C) 2008  Nivja de Jong and Ton Wempe                        #
#                                                                         #
#    This program is free software: you can redistribute it and/or modify #
#    it under the terms of the GNU General Public License as published by #
#    the Free Software Foundation, either version 3 of the License, or    #
#    (at your option) any later version.                                  #
#                                                                         #
#    This program is distributed in the hope that it will be useful,      #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
#    GNU General Public License for more details.                         #
#                                                                         #
#    You should have received a copy of the GNU General Public License    #
#    along with this program.  If not, see http://www.gnu.org/licenses/   #
#                                                                         #
###########################################################################
#
# modified 2010.09.17 by Hugo Quené, Ingrid Persoon, & Nivja de Jong
# Overview of changes: 
# + change threshold-calculator: rather than using median, use the almost maximum
#     minus 25dB. (25 dB is in line with the standard setting to detect silence
#     in the "To TextGrid (silences)" function.
#     Almost maximum (.99 quantile) is used rather than maximum to avoid using
#     irrelevant non-speech sound-bursts.
# + add silence-information to calculate articulation rate and ASD (average syllable
#     duration.
#     NB: speech rate = number of syllables / total time
#         articulation rate = number of syllables / phonation time
# + remove max number of syllable nuclei
# + refer to objects by unique identifier, not by name
# + keep track of all created intermediate objects, select these explicitly, 
#     then Remove
# + provide summary output in Info window
# + do not save TextGrid-file but leave it in Object-window for inspection
#     (if requested in startup-form)
# + allow Sound to have starting time different from zero
#      for Sound objects created with Extract (preserve times)
# + programming of checking loop for mindip adjusted
#      in the orig version, precedingtime was not modified if the peak was rejected !!
#      var precedingtime and precedingint renamed to currenttime and currentint
#
# + bug fixed concerning summing total pause, feb 28th 2011
###########################################################################


# counts syllables of all sound utterances in a directory
# NB unstressed syllables are sometimes overlooked
# NB filter sounds that are quite noisy beforehand
# NB use Silence threshold (dB) = -25 (or -20?)
# NB use Minimum dip between peaks (dB) = between 2-4 (you can first try;
#                                                      For clean and filtered: 4)
