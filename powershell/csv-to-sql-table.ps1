
Function Get-FieldTitlesFromCSV () {
#
#
# Returns: SystemArray of Strings

    param (
        [Parameter(Mandatory=$True)]
        [String] $Path,
        [Parameter(Mandatory=$False)]
        [String] $Delimiter = ","
    )

    $FieldRowText = (Get-Content -Path $Path)[0]
    $Fields = $FieldRowText.Split($Delimiter).Replace("`"", "")

    Return $Fields

} # End Function


Function New-CreateTableMySql () {
#
#
# Returns: String
    param (
        [Parameter(Mandatory=$True)]
        [String] $TableName,
        [Parameter(Mandatory=$True)]
        [System.Array] $Fields
    )

    $SQLTemplateHeader = "CREATE TABLE table_name ("
    $SQLTemplateLine   = "`t'column_name' data_type"
    $SQLTemplateFooter = ");"

    $SQLText = ""
    $NL = "`r`n"

    $Counter = 1

    $SQLText = $SQLText + $SQLTemplateHeader + $NL
    
    Foreach ($Field in $Fields) {

        $FieldDef = ($SQLTemplateLine.Replace('column_name',$Field)).Replace('data_type', 'varchar(255),')

        If ($Counter -eq $Fields.Length) {

            $FieldDef -Replace ".$"

        }

        $SQLText = $SQLText+ $FieldDef + $NL

    }

    $SQLText = $SQLText + $SQLTemplateFooter + $NL

    Write-Host $Counter
    $Counter ++

    Return $SQLText


} # End Function