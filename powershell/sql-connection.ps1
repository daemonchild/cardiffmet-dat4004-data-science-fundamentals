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

$data = Invoke-SqlQuery -query "SELECT * FROM some_data" -ConnectionName mysqlConn

$Path = "datasets/10032870-36f2-4426-aa33-b339b906de66_Data.csv"
$TableName = "some_data"

$upload = (Get-Content -Path $Path)

Foreach ($line in $upload) {

    $InsertValues = ""

    #Write-Host $line -ForegroundColor Green

    $Values = $line.split(',')
    $Values[0] = '"'+$Values[0]+'"'

    $InsertValues = $Values -join ','

    $Query = ("INSERT INTO $TableName (fields) VALUES (values)".Replace('fields', $InsertFields)).Replace('values',$InsertValues)


    $Query = $Query.Replace('values',$InsertValues)
    #Write-Host $Query

    Invoke-SqlQuery -ConnectionName mysqlConn -Query $Query 
    
}