# Download XBox One Game Clips

This PowerShell script will connect and download your Xbox One Game Clips.

Requires account with the Unofficial XBox API (https://xboxapi.com/).

##Current Build Features (11/16/2015)

  - Connects to the Xbox API and checks for new clips
    - The test for new clips is checking the download path to see if that specific clip has already been downloaded
  - If the clip has already been downloaded
      - Does nothing and ends the script
  - If the clip has not been downloaded:
      - Downoads the clip, small thumbnail, and large thumbnail.
      - Sets the timestamp of each downloaded file to that of the recorded time
      - Sends an E-Mail to the specified account with information on which clips were downlaoded
      - Sends a XBox Message to the XBox user specified (currently recommened to be the user/owner of the XBox API Account
      
      
##Future Builds Wishlist
*May not be all in one script, multiple scripts may be needed*

  - Database to store and track information about downlaoded items
    - Querying this database should also resolve [Issue #1 "New downloads are repeated"](https://github.com/terrytrent/DownloadXBoxGameClips/issues/1)
  - More notification paths
  - Ability to enable or disable notification paths
  - Logging (Log File, Event Log, etc.)
  - Switches to enable specific downloads, with clips always enabled
    - Thumbnails (Small, Large)
  - Extend to Screenshots
  - Auto setup of Task Scheduling
  - Utility for reviewing downloaded clips, along with the ability to rename / title / describe
