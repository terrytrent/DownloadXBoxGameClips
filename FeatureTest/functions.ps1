function Set-GitHubPath(){

        $path1="$env:USERPROFILE\My Documents\GitHub"
        $path2="$env:USERPROFILE\GitHub"
        $path3="$env:HOMESHARE\GitHub"
        $path4="$env:HOMESHARE\My Documents\GitHub"

        if(test-path $path1){
            return $path1
        }
        elseif(test-path $path2){
            return $path2
        }
        elseif(test-path $path3){
            return $path3
        }
        elseif(test-path $path4){
            return $path4
        }
        else{
            throw("No Github Path Found")
        }
}
function Set-SQLitePaths(){

    [hashtable]$return=@{}

    $gitHubPath=Set-GitHubPath
    $sqlitePath="$gitHubPath\DownloadXBoxGameClips\FeatureTest\Sqlite\System.Data.SQLite.dll"
    $dbPath="$gitHubPath\DownloadXBoxGameClips\FeatureTest\XBClipDownloder.db"
    $dbRPPlayedGamesPath="$gitHubPath\DownloadXBoxGameClips\FeatureTest\RPPGames.db"

    $return.sqlitePath=$sqlitePath
    $return.dbPath=$dbPath
    $return.dbRPPlayedGamesPath=$dbRPPlayedGamesPath

    return $return

    

}
function Get-InfoFromUser(){

    Param (
        [Parameter(mandatory=$true)]
        $varFullName,
        [switch]$secure
    )

    if($secure -eq $true){
    
        $response1=Read-Host -Prompt "Please enter your $varFullName" -AsSecureString
        $response2=Read-Host -Prompt "Please re-enter your $varFullName to confirm" -AsSecureString
        $var=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response1))
        $var2=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response2))
        if($var -ne $var2){
            $var=$null
            $var2=$null
            do{
                Write-Host "Sorry, but the entries did not match.  Please try again."
                $response1=Read-Host -Prompt "Please enter your $varFullName" -AsSecureString
                $response2=Read-Host -Prompt "Please re-enter your $varFullName to confirm" -AsSecureString
                $var=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response1))
                $var2=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response2))
            }
            while($var -ne $var2)
            $response=$response1 | ConvertFrom-SecureString
            return $response
        }
        else{
            $response=$response1 | ConvertFrom-SecureString
            return $response
        }

    }
    else{ 

        $var=Read-Host -Prompt "Please enter your $varFullName"
        $varConfirm=Read-Host -Prompt "You entered '$var', is this correct? (Yes or No)"

        if(($varConfirm -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")){
            do{
                $varConfirm=Read-Host -Prompt "You must specify 'Yes' or 'No'.`n`nYou entered '$var', is this correct? (Yes or No)"
            }
            until($varConfirm -match "yes|Yes|YES|y|Y|no|No|NO|n|N")
        }

        if($varConfirm -match "no|No|NO|n|N"){

            do{
                $varConfirm=$null
                $var=Read-Host -Prompt "Please re-enter your $varFullName"
                $varConfirm=Read-Host -Prompt "You entered '$var', is this correct? (Yes or No)"
        
                if(($varConfirm -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")){
                    do{
                        $varConfirm=Read-Host -Prompt "You must specify 'Yes' or 'No'.`n`nYou entered '$var', is this correct? (Yes or No)"
                    }
                    until($varConfirm -match "yes|Yes|YES|y|Y|no|No|NO|n|N")
                }

            }
            until($varConfirm -match "yes|Yes|YES|y|Y")

        }
        elseif($varConfirm -match "yes|Yes|YES|y|Y"){
            #do nothing, got a yes!
        }
    
        return $var
    }
}
function Insert-IntoSqliteDB(){

    Param (
        $table,
        [string[]]$columns,
        [string[]]$values
    )
    
    $sql = $con.CreateCommand()
    $columnvaluesArray=@()

    foreach($c in $columns){

        $columnNames+="$c,"
        $columnValues+="@$c,"
        $columnvaluesArray+="@$c"
    }
    
    $columnNames=$columnNames.Substring(0,($columnNames.length-1))
    $columnValues=$columnValues.Substring(0,($columnValues.length-1))
    
    $i=0

    foreach($v in $values){
        
        $column=$columnvaluesArray[$i]
        $value=$v
        [void]$sql.Parameters.AddWithValue("$column", $value);
        $i++
            
    }
    $sql.CommandText = "INSERT INTO $table ($columnNames) VALUES ($columnValues);"
    #$sql.Parameters
    [void]$sql.ExecuteNonQuery()

}
function Set-XboxNotifyOption(){

    Param (
        $runState
    )

    [hashtable]$return=@{}

    if($runState -eq "standalone"){
        $xboxNotifyOption=Read-Host -Prompt "This will set the Xbox Notification Option.`nWhenever the script has downloaded one or more new clips it will send you an XBox Message.`nDo you want to activate this option? (Yes or No)"
    }
    elseif($runState -eq "Setup"){

        $xboxNotifyOption=Read-Host -Prompt "The next notification option is Xbox Messaging.`nWhenever the script has downloaded one or more new clips it will send you an XBox Message.`nDo you want to activate this option? (Yes or No)"
    }


    if($xboxNotifyOption -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N"){
        do{$xboxNotifyOption=Read-Host -Prompt "Please enter 'Yes' or 'No'`nDo you want to activate the Xbox Messaging option? (Yes or No)"}
        while($xboxNotifyOption -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")
    }

    if($xboxNotifyOption -match "yes|Yes|YES|y|Y"){

        write-host "The Xbox Messaging Notification option is enabled.`n`nYou can disable this option at any time by running the xboxMessagingSetting.ps1 script."

    }
    else{

        write-host "The Xbox Messaging Notification option is disabled.`n`nYou can enable this option at any time by running the xboxMessagingSetting.ps1 script."

    }

    switch($xboxNotifyOption){
        "No" {$xboxNotify=0}
        "Yes" {$xboxNotify=1}
    }

    $return.Bool=$xboxNotify
    $return.String=$xboxNotifyOption
    return $return

}
function Set-ContributeOption(){

    Param (
        $runState
    )

    [hashtable]$return=@{}

    if($runState -eq "standalone"){
        $contributeOption=Read-Host -Prompt "Occasionally you may play a game that is not yet in our database - When this happens your clips are saved to a generic folder with a generic name.`n`nWe would like for you to help us improve the performance of this script by`n   occasionally sending us information about the games you play, specifically the name.`nIf you choose to enable this option no personal information will be sent.`n`nDo you want to activate this option? (Yes or No)"
    }
    elseif($runState -eq "Setup"){

        $contributeOption=Read-Host -Prompt "Occasionally you may play a game that is not yet in our database - When this happens your clips are saved to a generic folder with a generic name.`n`nWe would like for you to help us improve the performance of this script by`n   occasionally sending us information about the games you play, specifically the name.`nIf you choose to enable this option no personal information will be sent.`n`nDo you want to activate this option? (Yes or No)"
    }


    if($contributeOption -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N"){
        do{$contributeOption=Read-Host -Prompt "Please enter 'Yes' or 'No'`nDo you want to activate the Contribution option? (Yes or No)"}
        while($contributeOption -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")
    }

    if($contributeOption -match "yes|Yes|YES|y|Y"){

        write-host "The Contribution option is enabled.`n`nYou can disable this option at any time by running the contributeSetting.ps1 script."

    }
    else{

        write-host "The Contribution option is disabled.`n`nYou can enable this option at any time by running the contributeSetting.ps1 script."

    }

    switch($contributeOption){
        "No" {$contribute=0}
        "Yes" {$contribute=1}
    }

    $return.Bool=$contribute
    $return.String=$contributeOption
    return $return

}
function Set-EmailNotifyOption(){

    Param (
        $runState
    )

    [hashtable]$return=@{}

    if($runState -eq "standalone"){
        $emailNotifyOption=Read-Host -Prompt "If you enable the Email Notify option after clips are downloaded you will recieve an email notification.`nDo you want to activate this option? (Yes or No)"
    }
    elseif($runState -eq "Setup"){

        $emailNotifyOption=Read-Host -Prompt "The first option is the Email Notify option.`nIf this option is enabled, when clips are downloaded you will recieve an email notification.`nDo you want to activate this option? (Yes or No)"
    }


    if($emailNotifyOption -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N"){
        do{$emailNotifyOption=Read-Host -Prompt "Please enter 'Yes' or 'No'`nDo you want to activate the Email Notify option? (Yes or No)"}
        while($emailNotifyOption -notmatch "yes|Yes|YES|y|Y|no|No|NO|n|N")
    }

    if($emailNotifyOption -match "yes|Yes|YES|y|Y"){

        write-host "The Email Notify option is enabled.`n`nYou can disable this option at any time by running the emailNotifySetting.ps1 script."

    }
    else{

        write-host "The Email Notify Option is disabled.`n`nYou can enable this option at any time by running the emailNotifySetting.ps1 script."

    }

    switch($emailNotifyOption){
        "No" {$emailNotify=0}
        "Yes" {$emailNotify=1}
    }

    $return.Bool=$emailNotify
    $return.String=$emailNotifyOption
    return $return

}
function Set-EmailNotifySettings(){

    Param(
        [switch]$disable
    )
    
    if($disable -eq $true){
        
        $sqlitePaths=Set-SQLitePaths
        $sqlitePath=$sqlitePaths.sqlitePath
        $dbPath=$sqlitePaths.dbPath

        Add-Type -Path "$sqlitePath"
    
        $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $con.ConnectionString = "Data Source=$dbPath"
        $con.Open()

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT * FROM NotificationInfo"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet
        [void]$adapter.Fill($data)
    
        $currentEmailNotifySettings=$data.tables
        $currentEmailNotifySettingsTest=$currentEmailNotifySettings.EmailMailServer

        if(!($currentEmailNotifySettingsTest)){
    
            Insert-IntoSqliteDB -table NotificationInfo -columns EmailMailServer,EmailMailPort,EmailMailUsername,EmailMailTo,EmailMailFrom,EmailMailPasswordEncrypted -values NULL,NULL,NULL,NULL,NULL,NULL
        }
        else{
    
            $sql = $con.CreateCommand()
            $sql.CommandText = "UPDATE NotificationInfo SET EmailMailServer = NULL,EmailMailPort = NULL,EmailMailUsername = NULL,EmailMailTo = NULL,EmailMailFrom = NULL,EmailMailPasswordEncrypted = NULL";
            [void]$sql.ExecuteNonQuery()
    
        }


        [void]$con.close

    }
    else{

        Write-Host "You have chosen to enable the Email Notify Option.  To continue please provide the following information:`
      - E-Mail Server`
      - E-Mail Server Port`
      - E-Mail Username`
      - E-Mail Password (this will be encrypted in the database)`
      - To Email Address`
      - From Email Address`n`n"

        $EmailMailServer=Get-InfoFromUser -varFullName "'Email Server'"
        $EmailMailPort=Get-InfoFromUser -varFullName "'E-Mail Server Port'"
        $EmailMailUsername=Get-InfoFromUser -varFullName "'E-Mail Username'"
        $EmailMailPasswordEncrypted=Get-InfoFromUser -varFullName "'E-Mail Password'" -secure
        $EmailMailTo=Get-InfoFromUser -varFullName "'To E-Mail Address'"
        $EmailMailFrom=Get-InfoFromUser -varFullName "'From Email Address'"
    
        $gitHubPath=Set-GitHubPath

        Add-Type -Path "$gitHubPath\DownloadXBoxGameClips\FeatureTest\Sqlite\System.Data.SQLite.dll"
    
        $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $con.ConnectionString = "Data Source=$gitHubPath\DownloadXBoxGameClips\FeatureTest\XBClipDownloder.db"
        $con.Open()

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT * FROM NotificationInfo"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet
        [void]$adapter.Fill($data)
    
        $currentEmailNotifySettings=$data.tables
        $currentEmailNotifySettingsTest=$currentEmailNotifySettings.EmailMailServer

        if(!($currentEmailNotifySettingsTest)){
            write-host this
            Insert-IntoSqliteDB -table NotificationInfo -columns EmailMailServer,EmailMailPort,EmailMailUsername,EmailMailTo,EmailMailFrom,EmailMailPasswordEncrypted -values $EmailMailServer,$EmailMailPort,$EmailMailUsername,$EmailMailTo,$EmailMailFrom,$EmailMailPasswordEncrypted
        }
        else{
    
            $sql = $con.CreateCommand()
            $sql.CommandText = "UPDATE NotificationInfo SET EmailMailServer = '$EmailMailServer',EmailMailPort = '$EmailMailPort',EmailMailUsername = '$EmailMailUsername',EmailMailTo = '$EmailMailTo',EmailMailFrom = '$EmailMailFrom',EmailMailPasswordEncrypted = '$EmailMailPasswordEncrypted'";
            [void]$sql.ExecuteNonQuery()
    
        }


        [void]$con.close
    }

}
function New-ScheduledTask(){

    Param (

        [Parameter(Mandatory=$True,Position=1)]
        [string]$JobName,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$Script,
        [Parameter(Mandatory=$False,Position=3)]
        [int]$Interval = "15",
        [Parameter(Mandatory=$False,Position=4)]
        $Duration = ([TimeSpan]::MaxValue)

    )

    $Interval = (New-TimeSpan -Minutes $Interval)
 
    $scriptblock = [scriptblock]::Create($script)

    #Edit this next line as appropriate
    $trigger = New-JobTrigger -Once -At (Get-Date).Date -RepetitionInterval $repeat -RepetitionDuration $duration

    #Change the two lines following to take input via cli and store as credential
    $msg = "Enter the username and password that will run the task"; 
    $credential = $Host.UI.PromptForCredential("Task username and password",$msg,"$env:userdomain\$env:username",$env:userdomain)
    
    #Edit this next line as appropriate
    $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
    Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger -ScheduledJobOption $options -Credential $credential

}
function Check-SetupValue(){

    $sqlitePaths=Set-SQLitePaths
    $sqlitePath=$sqlitePaths.sqlitePath
    $dbPath=$sqlitePaths.dbPath

    Add-Type -Path "$sqlitePath"

    if(Test-Path $dbPath){

        $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $con.ConnectionString = "Data Source=$dbPath"
        $con.Open()

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT Setup FROM UserInfo"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet
        [void]$adapter.Fill($data)
    
        [void]$con.close
    
        $currentSetupValue=$data.tables

        return $currentSetupValue.Setup
    }
    else{
        return 2
    }


}
function Get-RecentPlayedGames(){

    Param(

        $APIKey,
        $ProfileID

    )

    $games=(invoke-webrequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/$profileID/xboxonegames).content | convertfrom-json | select -ExpandProperty titles

    foreach($game in $games){
        
        $titleID=$game.titleId
        $gameID='{0:x}' -f $titleID

        $gameInfo=(invoke-webrequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/game-details-hex/$gameID).content | convertfrom-json | select -ExpandProperty items

        $gameInfoName=$gameInfo.Name
        $gameInfoDecription=$gameInfo.Description
        $gameInfoTitleId=$gameInfo.TitleId
        $gameInfoDeveloper=$gameInfo.DeveloperName
        $gameInfoPublisher=$gameInfo.PublisherName
        $gameInfoRating=$gameInfo.ParentalRating
        $gameInfoHexID=$gameID
        $gameInfoRD=$gameInfo.ReleaseDate
        $gameInfoRDDateEnd=$gameInfoRD.indexof("T")
        $gameInfoRDTimeEnd=($gameInfoRD.Indexof("Z"))-$gameInfoRDDateEnd
        $gameInfoRDDate=$gameInfoRD.substring(0,$gameInfoRDDateEnd)
        $gameInfoRDTime=$gameInfoRD.substring(($gameInfoRDDateEnd+1),($gameInfoRDTimeEnd-1))
        $gameInfoRDDateTime="$gameInfoRDDate $gameInfoRDTime"
        $gameInfoReleaseDate=Get-Date $gameInfoRDDate -format "MM-dd-yyyy hh:mm:ss tt"
        
        $sqlitePaths=Set-SQLitePaths
        $sqlitePath=$sqlitePaths.sqlitePath
        $dbPath=$sqlitePaths.dbPath

        Add-Type -Path "$sqlitePath"
    
        $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $con.ConnectionString = "Data Source=$dbPath"
        $con.Open()

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT * FROM GamesInfo WHERE GameTitleId = $gameInfoTitleId"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet
        
        if(($adapter.Fill($data)) -eq 1){
            #do nothing, this title already exists
        }
        else{        
        
            Insert-IntoSqliteDB -table GamesInfo -columns GameTitleID,GameHexID,GameName,GameDescription,GameReleaseDate,GameDeveloper,GamePublisher,GameRating -values $gameInfoTitleId,$gameInfoHexID,$gameInfoName,$gameInfoDecription,$gameInfoReleaseDate,$gameInfoDeveloper,$gameInfoPublisher,$gameInfoRating

            $gameInfoImages=$gameInfo.Images

            foreach($Image in $gameInfoImages){

                $ImageID=$Image.ID
                $ImageURL=$Image.URL
                $ImagePurpose=$Image.Purpose
                $ImageHeight=$Image.Height
                $ImageWidth=$Image.Width

                Insert-IntoSqliteDB -table GamesImages -columns GameTitleID,ImageID,ImageURL,ImagePurpose,ImageHeight,ImageWidth -values $gameInfoTitleId,$ImageID,$ImageURL,$ImagePurpose,$ImageHeight,$ImageWidth

            }
        }
        
        [void]$con.close
    }

}
function Get-RecentPlayersPlayedGames(){

    Param(

        $APIKey,
        $ProfileID

    )

    $games=(invoke-webrequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/$profileID/xboxonegames).content | convertfrom-json | select -ExpandProperty titles

    foreach($game in $games){
        
        $titleID=$game.titleId
        $gameID='{0:x}' -f $titleID

        $gameInfo=(Invoke-WebRequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/game-details-hex/$gameID).content | convertfrom-json | select -ExpandProperty items

        $gameInfoName=$gameInfo.Name
        $gameInfoDecription=$gameInfo.Description
        $gameInfoTitleId=$gameInfo.TitleId
        $gameInfoDeveloper=$gameInfo.DeveloperName
        $gameInfoPublisher=$gameInfo.PublisherName
        $gameInfoRating=$gameInfo.ParentalRating
        $gameInfoHexID=$gameID
        $gameInfoRD=$gameInfo.ReleaseDate
        if(!($gameInfoRD)){
            # No Release Date, defaulting to XBox One Release Date
            $gameInfoReleaseDate=Get-Date "11/23/2013 00:00:00" -format "MM-dd-yyyy hh:mm:ss tt"
        }
        else{
            $gameInfoRDDateEnd=$gameInfoRD.indexof("T")
            $gameInfoRDTimeEnd=($gameInfoRD.Indexof("Z"))-$gameInfoRDDateEnd
            $gameInfoRDDate=$gameInfoRD.substring(0,$gameInfoRDDateEnd)
            $gameInfoRDTime=$gameInfoRD.substring(($gameInfoRDDateEnd+1),($gameInfoRDTimeEnd-1))
            $gameInfoRDDateTime="$gameInfoRDDate $gameInfoRDTime"
            $gameInfoReleaseDate=Get-Date $gameInfoRDDate -format "MM-dd-yyyy hh:mm:ss tt"
        }
        
        # Debug        
        # write-host "Writing to database:`n$gameInfoName`n$gameInfoTitleID`n$gameInfoHexID`n$GameInfoRD`n`n"

        $sqlitePaths=Set-SQLitePaths
        $sqlitePath=$sqlitePaths.sqlitePath
        $dbPath=$sqlitePaths.dbRPPlayedGamesPath

        Add-Type -Path "$sqlitePath"
        
        $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $con.ConnectionString = "Data Source=$dbPath"
        $con.Open()

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT * FROM GamesInfo"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet
        
        Try{
            Invoke-Command -ScriptBlock {[void]$adapter.Fill($data)} -ErrorAction SilentlyContinue
        }
        Catch{
            $checkValues=$false
        }

        $sql = $con.CreateCommand()
        $sql.CommandText = "Attach '$dbPath' as my_db;SELECT name FROM my_db.sqlite_master WHERE type='table';"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet   
        $numberOfDBs=$adapter.fill($data)

        $sql = $con.CreateCommand()
        $sql.CommandText = "DETACH 'my_db';"
        [void]$sql.ExecuteNonQuery()


        if($checkValues=$false){
            $adap="-1"
        }
        else{
            $adap=$adapter.Fill($data)
        }

        if($adap -gt 0){
        
            $sql = $con.CreateCommand()
            $sql.CommandText = "SELECT * FROM GamesInfo WHERE GameTitleId = $gameInfoTitleId"
            $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
            $data = New-Object System.Data.DataSet
        
            if($adapter.fill($data) -eq 1){
                #do nothing, this title already exists
            }
            else{        
        
                Insert-IntoSqliteDB -table GamesInfo -columns GameTitleID,GameHexID,GameName,GameDescription,GameReleaseDate,GameDeveloper,GamePublisher,GameRating -values $gameInfoTitleId,$gameInfoHexID,$gameInfoName,$gameInfoDecription,$gameInfoReleaseDate,$gameInfoDeveloper,$gameInfoPublisher,$gameInfoRating

                $gameInfoImages=$gameInfo.Images

                foreach($Image in $gameInfoImages){

                    $ImageID=$Image.ID
                    $ImageURL=$Image.URL
                    $ImagePurpose=$Image.Purpose
                    $ImageHeight=$Image.Height
                    $ImageWidth=$Image.Width

                    Insert-IntoSqliteDB -table GamesImages -columns GameTitleID,ImageID,ImageURL,ImagePurpose,ImageHeight,ImageWidth -values $gameInfoTitleId,$ImageID,$ImageURL,$ImagePurpose,$ImageHeight,$ImageWidth

                }
            }

        }
        else{

            if($numberOfDBs -eq 0){
                # Create tables
                $sql = $con.CreateCommand()
                $sql.CommandText = "CREATE TABLE GamesInfo(GameTitleId Integer, GameHexID Text, GameName Text, GameDescription Text, GameReleaseDate Text, GameDeveloper Text, GamePublisher Text, GameRating Text);`
                CREATE TABLE GamesImages(GameTitleId Integer, ImageID Text, ImageURL Text, ImagePurpose Text, ImageHeight Integer, ImageWidth Integer);`
                CREATE TABLE GamesShortName(GameTitleId Integer,GameName Text, GameShortName Text);`
                CREATE TABLE RecentPlayers(Gamertag Text,ProfileID Integer)"
                [void]$sql.ExecuteNonQuery()
            }

            $sql = $con.CreateCommand()
            $sql.CommandText = "SELECT * FROM GamesInfo WHERE GameTitleId = $gameInfoTitleId"
            $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
            $data = New-Object System.Data.DataSet
        
            if(($adapter.Fill($data)) -eq 1){
                #do nothing, this title already exists
            }
            else{        
        
                Insert-IntoSqliteDB -table GamesInfo -columns GameTitleID,GameHexID,GameName,GameDescription,GameReleaseDate,GameDeveloper,GamePublisher,GameRating -values $gameInfoTitleId,$gameInfoHexID,$gameInfoName,$gameInfoDecription,$gameInfoReleaseDate,$gameInfoDeveloper,$gameInfoPublisher,$gameInfoRating

                $gameInfoImages=$gameInfo.Images

                foreach($Image in $gameInfoImages){

                    $ImageID=$Image.ID
                    $ImageURL=$Image.URL
                    $ImagePurpose=$Image.Purpose
                    $ImageHeight=$Image.Height
                    $ImageWidth=$Image.Width

                    Insert-IntoSqliteDB -table GamesImages -columns GameTitleID,ImageID,ImageURL,ImagePurpose,ImageHeight,ImageWidth -values $gameInfoTitleId,$ImageID,$ImageURL,$ImagePurpose,$ImageHeight,$ImageWidth

                }
            }
        }
        
        [void]$con.close
    }

}
function New-FolderPaths(){

    Param (

        [string[]]$paths=$(throw "You must enter at least one folder path")
    
    )

    foreach($path in $paths){

        if(Test-Path $path){
            # Do nothing, path already exists
        }
        else{
            # Path does not exist yet, create
            New-Item -Path $path -ItemType Directory | out-null
        }
    }

}