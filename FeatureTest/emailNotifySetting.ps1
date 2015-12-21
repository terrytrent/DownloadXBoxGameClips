. .\functions.ps1

$setupValue=Check-SetupValue

if($setupValue -eq 2){
    write-host "Sorry, the database does not exist.  Please run the setup script to create the database and set all initial values."
    Write-Host "Press any key to close this window ..."

    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
elseif($setupValue -ne 1){
    write-host "Sorry, something has gone wrong.  Please run the script to (re-)create the database and (re-)set all initial values."
    Write-Host "Press any key to close this window ..."

    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
else{

    $runState="standalone"

    $emailNotifyReturn=Set-EmailNotifyOption -runState $runState

    $emailNotify=$emailNotifyReturn.bool
    $emailNotifyOption=$emailNotifyReturn.String


    $sqlitePaths=Set-SQLitePaths
    $sqlitePath=$sqlitePaths.sqlitePath
    $dbPath=$sqlitePaths.dbPath

    Add-Type -Path "$sqlitePath"
    
    $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
    $con.ConnectionString = "Data Source=$dbPath"
    $con.Open()

    $sql = $con.CreateCommand()
    $sql.CommandText = "SELECT NotificationEmail FROM UserInfo"
    $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
    $data = New-Object System.Data.DataSet
    [void]$adapter.Fill($data)

    $currentemailNotify=$data.tables.NotificationEmail

    $sql = $con.CreateCommand()
    $sql.CommandText = "UPDATE UserInfo SET NotificationEmail = $emailNotify WHERE NotificationEmail = $currentemailNotify";
    [void]$sql.ExecuteNonQuery()

    $con.close()

    if($emailNotify -eq 1){

        Set-EmailNotifySettings

    }
    else{

        Set-EmailNotifySettings -disable

    }
}