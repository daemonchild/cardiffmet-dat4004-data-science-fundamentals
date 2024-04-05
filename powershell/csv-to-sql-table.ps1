
Function Get-FieldTitlesFromCSV () {
#
#
# Returns: SystemArray of Strings

    param (
        [Parameter(Mandatory=$True)]
        [String] $Path,
        [Parameter(Mandatory=$False)]
        [String] $Delimiter = ",",
        [Parameter(Mandatory=$False)]
        [Switch] $Raw = $False
    )

    $FieldRowText = (Get-Content -Path $Path)[0]
    $FieldsArray = $FieldRowText.Split($Delimiter)

    Write-Host "Lifted:" -ForegroundColor Cyan
    Write-Host ($FieldsArray)
    Write-Host "That is" $FieldsArray.Length

    # Process and Make MySQL Safe
    If ($Raw -ne $True) {

        $FixedFields = @()

        Foreach ($Field in $FieldsArray) {

            $Field = $Field.Replace(' ','_').ToLower()
            $Field = $Field -Replace "[^a-zA-Z0-9_]"

            $FixedFields = $FixedFields + $Field
        }

        Return @($FixedFields)

    } Else {

        Return @($FieldsArray)

    }


} # End Function


Function New-CreateTableMySql () {
#
#
# Returns: String
    param (
        [Parameter(Mandatory=$True)]
        [String] $TableName,
        [Parameter(Mandatory=$True)]
        [Hashtable] $FieldsWithCount
    )

    $SQLTemplateHeader = "CREATE TABLE table_name ("
    $SQLTemplateLine   = "`tcolumn_name data_type"
    $SQLTemplateFooter = ");"

    $SQLText = ""
    $NL = "`r`n"

    $Counter = 1

    # Add Header
    $SQLText = $SQLText + $SQLTemplateHeader.Replace('table_name',$TableName) + $NL

    # Process Fields List
    Foreach ($Field in $FieldsWithCount.Keys) {

        $DataType = "varchar("+$FieldsWithCount.$Field+"),"
        $FieldDef = ($SQLTemplateLine.Replace('column_name',$Field)).Replace('data_type', $DataType)

        # Remove Last Comma
        If ($Counter -eq $FieldsWithCount.Count) {
            $FieldDef = $FieldDef.Trim(",")
        }

        $SQLText = $SQLText+ $FieldDef + $NL
        $Counter ++
    }

    # Add Footer
    $SQLText = $SQLText + $SQLTemplateFooter + $NL

    Return $SQLText


} # End Function

Function Measure-ColumnMax () {
#
#
# Returns: String
    param (
        [Parameter(Mandatory=$True)]
        [String] $Path,
        [Parameter(Mandatory=$False)]
        [String] $Delimiter = ",",
        [Parameter(Mandatory=$False)]
        [Int16] $Padding = 10
    )

    Write-Host "[WAIT] Loading Data" -ForegroundColor Cyan
    $FileFields = Get-FieldTitlesFromCSV -Path $Path -Delimiter "," -Raw
    $CSVData = (Get-Content -Path $Path | ConvertFrom-CSV)

    $MaxData = @{}

    # Setup Empty Records
    Foreach ($Field in $FileFields) {
        
        $MaxData.($Field.Replace('"','')) = 0
        #Write-Host $Field ":" $MaxData.$Field 
    }

    Write-Host "[WAIT] Processing "$Fields.Length" fields across "$CSVData.Length" rows." -ForegroundColor Cyan
    Write-Host "[NOTE] Adding +"$Padding" to each value." -ForegroundColor DarkCyan
    Foreach ($Line in $CSVData) {

        $MaxCopy = $MaxData.Clone()
        Foreach ($Key in $MaxData.Keys) {
            If (($Line.$Key).Length -gt $MaxData.$Key) {
                $MaxCopy.$Key = ($Line.$Key).Length + $Padding
                If ($MaxCopy.$Key -gt 255) {
                    $MaxCopy.$Key = 255
                }
            }
        }
        $MaxData = $MaxCopy.Clone()

    }

    Return $MaxData

}

# Usage:

# > $FieldList = Get-FieldTitlesFromCSV -Path ./datasets/dataset.csv
# > $SQLText = New-CreateTableMySql -TableName "My Table Name" -Fields $FieldList

