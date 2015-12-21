. .\functions.ps1

$runState="setup"

# Specify DB and SQLite Paths
$sqlitePaths=Set-SQLitePaths
$sqlitePath=$sqlitePaths.sqlitePath
$dbPath=$sqlitePaths.dbPath

if(test-path $dbPath){
    $createDB=0
    $overwrite=Read-Host -Prompt "The database already exists, do you want to overwrite the existing initial values? (Yes or No)"

    if($overwrite -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N"){
        do{$overwrite=Read-Host -Prompt "Please enter 'Yes' or 'No'`nDo you want to ovewrite the existing initial values? (Yes or No)"}
        while($overwrite -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")
    }

    if($overwrite -match "yes|Yes|YES|y|Y"){

        write-host "The initial values will be overwritten.  Continuing with setup..."

        Add-Type -Path "$sqlitePath"
    
        $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $con.ConnectionString = "Data Source=$dbPath"
        $con.Open()

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT * FROM UserInfo"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet

        if(($adapter.Fill($data)) -eq 1){
            $overwite=0
        }
        else{
            $overwrite=1
        }
    
        [void]$con.close

    }
    else{

        write-host "The initial values will not be overwitten.  Cannot continue."
        break

    }

}
else{
    $createDB=1
}

# Gather XBOXAPI API Key
$APIKey=$(Get-InfoFromUser "API Key")
$APIKey="fc6de22bb9250ff77f2c3ef924de59f19431144a"

# Test API Key and gather User Info from XBOXAPI.COM at the same time.  If API Key is invalid, break script.
try{
    $userInfo=(invoke-webrequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/accountXuid)
}
catch{
    write-host "`nYour API Key, '$APIKey', is not authorized to access XBOXAPI.COM.`n`nPlease verify you have an XBOXAPI.COM account and that your API Key is valid.`n`nOnce you have done so please re-run this script."
    break
}

# Gather gamertag
$gamertag=($userInfo.Content -creplace "gamerTag","gt"| ConvertFrom-Json).gamertag

# Gather Profile ID
$ProfileID=((invoke-webrequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/$gamertag/profile).content | ConvertFrom-Json).id

# Gather Save Location
$saveLocation=$(Get-InfoFromUser "Save Location")

# Test Save Location, create if it does not exist and specified to
if(!(test-path $saveLocation)){
    $createPath="###begin####"
    do{
        if($createPath -ne "###begin####" -and $createPath -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N"){
            write-host "You must specify 'Yes' or 'No'"
        }
        $createPath=Read-Host -Prompt "The path you have specified, '$saveLocation', does not exist.  Create? (Yes or No)"
    }
    while($createPath -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")

    if($createPath -match "yes|Yes|YES|y|Y"){
        New-Item -Path $saveLocation -ItemType directory | out-null
        write-host "`nThe Path '$saveLocation' has been created."
    }
    else{
        write-host "`nThe path '$saveLocation' has not been created and does not exist.`nIf it is not created before the script begins it's normal operation it will be created at that time."
    }
}

# Contribute Option
$contributeReturn=Set-ContributeOption -runState $runState

$contribute=$contributeReturn.bool
$contributeOption=$contributeReturn.String


# Email Notification Option
$emailNotifyReturn=Set-EmailNotifyOption -runState $runState

$emailNotify=$emailNotifyReturn.bool
$emailNotifyOption=$emailNotifyReturn.String

if($emailNotify -eq 1){

    Set-EmailNotifySettings

}
else{

    Set-EmailNotifySettings -disable

}


# Xbox Notification Option

$xboxNotifyReturn=Set-XboxNotifyOption -runState $runState

$xboxNotify=$xboxNotifyReturn.bool
$xboxNotifyOption=$xboxNotifyReturn.String

# Display information gathered so far
write-host "Your information is as follows:`n
     Gamertag: $gamertag
   Profile ID: $profileID
      API Key: $APIKey
Save Location: $saveLocation
   Contribute: $contributeOption
 Email Notify: $emailNotifyOption
  XBox Notify: $xboxNotifyOption`n"


# Create Database
Add-Type -Path "$sqlitePath"
    
$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$con.ConnectionString = "Data Source=$dbPath"
$con.Open()

if($createDB -eq 1){

    # Create tables
    $sql = $con.CreateCommand()
    $sql.CommandText = "CREATE TABLE UserInfo(ProfileID Text,Gamertag Text,APIKey Text, SaveLocation Text,ContributeGames Integer,NotificationEmail Integer,NotificationXbox Integer, Setup Integer);`
    CREATE TABLE NotificationInfo(EmailMailServer Text, EmailMailPort Integer, EmailMailUsername Text, EmailMailTo Text, EmailMailFrom Text, EmailMailPasswordEncrypted Text);`
    CREATE TABLE GamesInfo(GameTitleId Integer, GameHexID Text, GameName Text, GameDescription Text, GameReleaseDate Text, GameDeveloper Text, GamePublisher Text, GameRating Text);`
    CREATE TABLE GamesImages(GameTitleId Integer, ImageID Text, ImageURL Text, ImagePurpose Text, ImageHeight Integer, ImageWidth Integer);`
    CREATE TABLE GamesShortName(GameTitleId Integer, GameName Text, GameShortName Text);`
    CREATE TABLE GamesShortNameCustom(GameTitleId Integer, GameName Text, GameShortName Text);`
    CREATE TABLE GameClips(GameTitleId Integer, GameClipID Text, DateRecordedGMT Text, Length Integer, SmallThumbnailUrl Text, LargeThumbnailUrl Text, GameClipUrl Text);"
    [void]$sql.ExecuteNonQuery()

}

if($overwrite -eq 0){

    # Insert information collected into database
    Insert-IntoSqliteDB -table UserInfo -columns ProfileID,Gamertag,APIKey,SaveLocation,ContributeGames,NotificationEmail,NotificationXbox,Setup -values $profileID,$gamertag,$APIKey,$saveLocation,$contribute,$emailNotify,$xboxNotify,1

}
elseif($overwrite -eq 1){

    $sql = $con.CreateCommand()
    $sql.CommandText = "UPDATE UserInfo SET ProfileID = '$profileID',Gamertag = '$gamertag',APIKey = '$APIKey',SaveLocation = '$saveLocation',ContributeGames = '$contribute',NotificationEmail = '$emailNotify',NotificationXbox = '$xboxNotify',Setup = 1";
    [void]$sql.ExecuteNonQuery()

}

$con.close()

# Intial Population of GamesInfo

Get-RecentPlayedGames -APIKey $APIKey -ProfilID $ProfileID

# Schedule download script

New-ScheduledTask -JobName "Download Xbox Clips" -Script "C:\Script.ps1" -Interval 15