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

    $contributeReturn=Set-ContributeOption -runState $runState

    $contribute=$contributeReturn.bool
    $contributeOption=$contributeReturn.String


    $sqlitePaths=Set-SQLitePaths
    $sqlitePath=$sqlitePaths.sqlitePath
    $dbPath=$sqlitePaths.dbPath

    Add-Type -Path "$sqlitePath"
    
    $con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
    $con.ConnectionString = "Data Source=$dbPath"
    $con.Open()

    $sql = $con.CreateCommand()
    $sql.CommandText = "SELECT ContributeGames FROM UserInfo"
    $adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
    $data = New-Object System.Data.DataSet
    [void]$adapter.Fill($data)

    $currentContributeGames=$data.tables.ContributeGames

    $sql = $con.CreateCommand()
    $sql.CommandText = "UPDATE UserInfo SET ContributeGames = $contribute WHERE ContributeGames = $currentContributeGames";
    [void]$sql.ExecuteNonQuery()

    $con.close()

}