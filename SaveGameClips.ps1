################################################################
#                                                              #
# This script works in conjunction with a XBOXAPI.COM account. #
# You must create a XBOXAPI.COM account in order to use it.    #
#                                                              #
# You do not need the paid subscription unless you intend      #
# to perform more than 120 API Requests an hour                #
#                                                              #
# The information you need from the account is:                #
#   -XboxAPI API Key                                           #
#   -XBOX Profile User ID                                      #
#                                                              #
# The information can be found on https://xboxapi.com/profile  #
#                                                              #
################################################################



Function Set-FileTimeStamps{
    #from http://blogs.technet.com/b/heyscriptingguy/archive/2012/06/01/use-powershell-to-modify-file-access-time-stamps.aspx
    Param (
    [Parameter(mandatory=$true)]
    [string[]]$path,
    [datetime]$date = (Get-Date))

    Get-ChildItem -Path $path |

    ForEach-Object {
        $_.CreationTime = $date
        $_.LastAccessTime = $date
        $_.LastWriteTime = $date
    }

}

# Get the information from https://xboxapi.com/
## Replace ######################## with your XboxAPI API Key
## Replace @@@@@@@@@@@@@@@@@@@@ with your XBOX Profile User ID
$APIKey="########################"
$profileID="@@@@@@@@@@@@@@@@@@@@"
$AllClips=(invoke-webrequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/$profileID/game-clips)

# Replace "Z:\XBox One Games" with your folder location
$gameVidSaveLocation="Z:\XBox One Games"

# Convert the information to usable form
$content=$AllClips.content | convertfrom-json

# Prepare variables to be used later for alerting
$numberOfDownloadedRecords=0
$allClipNames=@()

# Process each clip record recieved
foreach($c in $content){
    
    # Store the game name
    $game=$c.titleName

    # Store the date and time the clip was recorded
    $recordedWhenGMT=$c.dateRecorded
    
    # Convert the date and time the clip was recorded to usable form
    ## Change this as you need to fix the timestamp ( you can change the name of the variable, just make sure it is updated though the rest of the script ), change the -5 to whatever is needed
    $recordedWhenEST=$(([datetime]($recordedWhenGMT)).AddHours(-5))
    
    # Convert the date and time variable to format for use in file name
    $recordedWhen=get-date $recordedWhenEST -Format "yyyy-MM-dd_HH.mm.ss"
    
    # Store thumbnail information in variable
    $thumbnails=$c.thumbnails

    # Store the uri of the small and large thumnails into variables
    $smallThumnbnailuri=($thumbnails | where {$_.thumbnailType -eq "Small"}).uri
    $largeThumnbnailuri=($thumbnails | where {$_.thumbnailType -eq "Large"}).uri

    # Store the video URI into a variable
    $videoUri=$c.gameClipUris.uri

    # Store the video size into a variable
    ## Not currently used in the script, but could be used for logging or reporting functions if added to the script
    $videoSizeInBytes=$c.gameClipUris.fileSize

    # Convert the size of the video to Megabytes
    ## Not currently used in the script, but could be used for logging or reporting functions if added to the script
    $videoSizeInMB=[math]::round(($videoSizeInBytes/1024/1024),2)

    # Store a short name of the game into a variable, currently only configrued for Halo.  If not halo, short name is "Xbox One Game"
    if($game -eq "Halo 5: Guardians"){
        $gameShort="Halo_5"
    }
    else{
        $gameShort="Xbox One Game"
    }

    # Store the folder path the games will be saved
    $folderPath="$gameVidSaveLocation\$gameShort"

    # Specify the filenames for the files to be downlaoded
    $vidFileName = "$gameShort`_$recordedwhen.mp4"
    $stFileName = "$gameShort`_smallThumbnail_$recordedwhen.png"
    $ltFileName = "$gameShort`_largeThumbnail_$recordedwhen.png"

    # Specify the full path name for the files to be downloaded
    $vidSaveLocation="$folderPath\$vidFileName"
    $stSaveLocation="$folderPath\$stFileName"
    $ltSaveLocation="$folderPath\$ltFileName"
    
    # Check to see if the folder path where the games will be saved exists.  If it does not, create it.
    if(Test-Path $folderPath){
        #do nothing, the folder exists
    }
    else{
        new-item -path $folderPath -ItemType directory
    }

    # Check to see if the clip being processed has already had the thumnails and clip downloaded.  If any one of the 3 files has not been downlaoded, downlaod and replace
    if((Test-Path $vidSaveLocation) -and (Test-Path $stSaveLocation) -and (Test-Path $ltSaveLocation)){
        #do nothing, the fileset was already downloaded
        
    }
    else{
        
        # Download the video clip, set the timestamps on the video clip to the actual time it was recorded
        Invoke-WebRequest -Uri "$videoUri" -OutFile "$vidSaveLocation"
        Set-FileTimeStamps -path "$vidSaveLocation" -date "$recordedWhenEST"

        # Download the video clip, set the timestamps on the video clip to the actual time it was recorded
        Invoke-WebRequest -Uri "$smallThumnbnailuri" -OutFile "$stSaveLocation"
        Set-FileTimeStamps -path "$stSaveLocation" -date "$recordedWhenEST"

        # Download the video clip, set the timestamps on the video clip to the actual time it was recorded
        Invoke-WebRequest -Uri "$largeThumnbnailuri" -OutFile "$ltSaveLocation"
        Set-FileTimeStamps -path "$ltSaveLocation" -date "$recordedWhenEST"
        
        # Store information to be used for alerting
        ## Set how many clips are being downloaded
        $numberOfDownloadedRecords++

        ## Set each file name and their recorded time to a variable
        $allClipNames+=$c | select @{label="FileName";expression={$vidFileName}},@{label="RecordedWhen";expression={$recordedWhenEST}}
        $allClipNames+=$c | select @{label="FileName";expression={$stFileName}},@{label="RecordedWhen";expression={$recordedWhenEST}}
        $allClipNames+=$c | select @{label="FileName";expression={$ltFileName}},@{label="RecordedWhen";expression={$recordedWhenEST}}
    }

}


# Notify via Email and Xbox Messages when there are clips that were downloaded
if($numberOfDownloadedRecords -gt 0){
    # Set Mail Variables
    ## Variables different depending on SMTP service used and credentials: $mailServer, $mailPort, $mailUsername, $mailSecurePass
    ## $mailSecurePass must have file to pull from.  To create file: convertto-securestring -String "password" -AsPlainText -force | convertfrom-securestring | out-file Z:\smtpCred
    $mailServer="smtp.server.com"
    $mailPort="25"
    $mailUsername="mailUsername@server.com"
    $mailSecurePass=get-content "Z:\smtpCred" | ConvertTo-SecureString
    $mailCredentials=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$mailUsername",$mailSecurePass
    $mailTo="Mail User <mailUsername@server.com>"
    $mailFrom="Xbox One Clip Downloader <mailUsername@server.com>"
    $mailSubject=$(

        if($numberOfDownloadedRecords -eq "1"){
            "Xbox One Clip Downloader: $numberOfDownloadedRecords clip has been downloaded"
        }
        else{
            "Xbox One Clip Downloader: $numberOfDownloadedRecords clips have been downloaded"        
        }


        )
        [string]$mailBody=$(
    
            if($numberOfDownloadedRecords -eq "1"){
                "$numberOfDownloadedRecords clip, and it's thumbnails, have been downloaded:`n`n"
            }
            else{
                "$numberOfDownloadedRecords clips, and their thumbnails, have been downloaded:`n`n"        
            }

            foreach($a in $allClipNames){
                $fileName=$a.FileName
                $recordedWhen=$a.RecordedWhen

                if($fileName -like '*.mp4'){
                    "Recorded $recordedWhen`n"
                    "  Video: $fileName`n"
                }
                elseif($fileName -like '*small*.png'){
                    "    Small Thumbnail: $fileName`n"
                }
                elseif($fileName -like '*large*.png'){
                    "    Large Thumbnail: $fileName`n`n"
                }
            }


        )

        Send-MailMessage -SmtpServer $mailServer -Credential $mailCredentials -From $mailFrom -To $mailTo -Body $mailBody -Subject $mailSubject -UseSsl -Port $mailPort


        # Set and Send Xbox Message
        ## Set Xbox Message
        $xboxMessageBody=$(
    
            if($numberOfDownloadedRecords -eq "1"){
                "$numberOfDownloadedRecords clip, and it's thumbnails, have been downloaded to your computer.  Check your email for more information."
            }
            else{
                "$numberOfDownloadedRecords clips, and their thumbnails, have been downloaded to your computer.  Check your email for more information."        
            }
        )

        ## Convert Xbox Message to JSON
        $json=$("{`
        `"to`": [`
            `"$profileID`"`
        ],`
        `"message`": `"$xboxMessageBody`"`
        }"`
        )
        
        ## Send Xbox Message
        Invoke-WebRequest -uri "https://xboxapi.com/v2/messages" -Method post -Body $json -Headers @{"X-AUTH" = "$APIKey"} -ContentType "application/json"
}
else{
    #do not notify, nothing to notify on
}