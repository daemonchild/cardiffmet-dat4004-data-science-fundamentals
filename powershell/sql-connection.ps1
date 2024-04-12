# Connect to the MySQL database
Add-Type -Path './mysql/MySql.Data.dll'

$Path = "/home/tom/development/dat4004-data-science-fundamentals/datasets/10032870-36f2-4426-aa33-b339b906de66_Data.csv"

$Fields = Get-FieldTitlesFromCSV -Path $Path -Delimiter "," -Raw
$MySQLFields = Get-FieldTitlesFromCSV -Path $Path -Delimiter ","

$InsertFields = $MySQLFields -Join ","

$DBUser = "root"
$DBPassword = ConvertTo-SecureString -String "NotAPassw0rd!" -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DBUser, $DBPassword

$sqlConnect = Open-MySqlConnection -ConnectionName mysqlConn -Server 127.0.0.1 -Database dat4004 -Port 43306 -Credential $creds -WarningAction SilentlyContinue

#$data = Invoke-SqlQuery -query "SELECT * FROM some_data" -ConnectionName mysqlConn

$Path = "datasets/10032870-36f2-4426-aa33-b339b906de66_Data.csv"
$TableName = (ConvertTo-MySqlFriendly -Value "World Bank Data")

$Upload = (Get-Content -Path $Path | ConvertFrom-CSV)

$Keys = @()
Foreach ($Property in $Upload[0].PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'}) {

    $Key = $Property.Name
    $Keys += $Key

}

Foreach ($Item in $Upload) {


    $InsertValues = ""

 

    $InsertValues = $FixedValues -join ','

    $Query = ("INSERT INTO $TableName (fields) VALUES (values)".Replace('fields', $InsertFields)).Replace('values',$InsertValues)
    $Query = $Query.Replace('values',$InsertValues)

    Write-Host $Query
    #Write-Host "." -NoNewline

    Try {
        Invoke-SqlUpdate -ConnectionName mysqlConn -Query $Query
    }
    Catch {

        Write-Host "Failed"
        Pause

    }

    
}