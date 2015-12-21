. .\functions.ps1

$APIKey="e228a48d184f1deb8506b59b2234be8fcd4c6a01"

$recentPlayers=(Invoke-WebRequest -Headers @{"X-AUTH" = "$APIKey"} https://xboxapi.com/v2/recent-players).content | convertfrom-json

$recentPlayerProfiles=$recentplayers.profile_link | select -First 120

foreach($r in $recentPlayerProfiles){

    $profileAddress=$r

    $recentPlayerProfile=(Invoke-WebRequest -Headers @{"X-AUTH" = "$APIKey"} $profileAddress).content | ConvertFrom-Json

    $recentPlayerGamertag=$recentPlayerProfile.gamertag

    $ProfileID=$recentPlayerProfile.id
    
    $sqlitePaths=Set-SQLitePaths
    $sqlitePath=$sqlitePaths.sqlitePath
    $dbPath=$sqlitePaths.dbRPPlayedGamesPath

    Add-Type -Path "$sqlitePath"
        
    $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
    $con.ConnectionString = "Data Source=$dbPath"
    $con.Open()

    $sql = $con.CreateCommand()
    $sql.CommandText = "Attach '$dbPath' as my_db;SELECT name FROM my_db.sqlite_master WHERE type='table';"
    $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
    $data = New-Object System.Data.DataSet   
    $numberOfTables=$adapter.fill($data)

    $sql = $con.CreateCommand()
    $sql.CommandText = "DETACH 'my_db';"
    [void]$sql.ExecuteNonQuery()

    if($numberOfTables -gt 0){

        $sql = $con.CreateCommand()
        $sql.CommandText = "SELECT * FROM RecentPlayers WHERE ProfileID = $ProfileID"
        $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
        $data = New-Object System.Data.DataSet
    
        [int]$playerLookup=$adapter.Fill($data)

        if($playerLookup -eq "1"){

            # Player has been checked for games and been processed, do nothing
            # Debug
            # write-host player already in database

        }
        else{

            # Debug
            # write-host "Processing $recentPlayerGamertag, Profile ID: $profileID"
    
            Get-RecentPlayersPlayedGames -APIKey $APIKey -ProfileID $ProfileID

            Insert-IntoSqliteDB -table RecentPlayers -columns Gamertag,ProfileID -values $recentPlayerGamertag,$ProfileID

        }
    }
    else{

         # Debug
        # write-host "Processing $recentPlayerGamertag, Profile ID: $profileID"
    
        Get-RecentPlayersPlayedGames -APIKey $APIKey -ProfileID $ProfileID

        Insert-IntoSqliteDB -table RecentPlayers -columns Gamertag,ProfileID -values $recentPlayerGamertag,$ProfileID

    }

    $con.close()

}