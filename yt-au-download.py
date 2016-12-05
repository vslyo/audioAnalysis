"""Given a search string, downloads audio track.

Downloads the first N(specified in arguments) number of videos from the search list.

The developer key is to be set in the py file.

Audio file properties:
Bit rate = 128k
Format   = m4as

Dependencies needed to run script:
1. Download and install youtube-dl from https://github.com/rg3/youtube-dl only.
2. Install Python package pafy: pip install pafy
3. Install google data api: pip install --upgrade google-api-python-client

Run instructions:
python yt-au-download-1.py <INSERT YOUTUBE SEARCH STRING> <NUMBER OF FILES TO BE DOWNLOADED> <PATH FOR DOWNLOADED FILES> <LICENSE> <DEVELOPER KEY>
LICENSE has values a - All, c - Creative Commons y - Standard YouTube
"""

import pafy
import sys
from apiclient.discovery import build
from apiclient.errors import HttpError
from oauth2client.tools import argparser

searchStr = sys.argv[1]
numOfFiles = sys.argv[2]
filesPath = sys.argv[3]

if sys.argv[4] == 'a':
    vidLicense = 'any'
elif sys.argv[4] == 'c':
    vidLicense = 'creativeCommon'
elif sys.argv[4] == 'y':
    vidLicense = 'youtube'
else:
    print 'Invalid license code. Please try again.'
    sys.exit()

devKey = sys.argv[5]
serviceName = 'youtube'
APIVersion = 'v3'

def ytSearchDownload(searchStr, numOfFiles, filesPath, vidLicense, devKey):
    youtube = build(serviceName, APIVersion, developerKey = devKey)
    filesSearched = 2 * int(numOfFiles)
    searchResults = youtube.search().list(part = "id,snippet", q = searchStr, maxResults = filesSearched, videoLicense = vidLicense, type = 'video').execute()
    videos = []
    
    i = 0
    for result in searchResults.get("items", []):
        if result["id"]["kind"] == 'youtube#video' and i < int(numOfFiles):
            videos.append(result["id"]["videoId"])
            i += 1
    
    i = 0
    for vd in videos:
        i += 1
        url = vd
        video_object = pafy.new(vd)
        for au in video_object.audiostreams:
            if au.extension == 'm4a' and au.bitrate == '128k':
                au.download(filesPath + str(i) + '.m4a')

ytSearchDownload(searchStr, numOfFiles, filesPath, vidLicense, devKey)
