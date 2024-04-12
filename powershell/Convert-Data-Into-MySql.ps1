#

$Logo = '                             _ 
 
    Logo Goes Here :)

'
#   Convert-Data-Into-Mysql.psm1
#   - PowerShell Tools to Get Data into MySQL Servers

#   - 
#



# Public Functions
Function ConvertTo-MySqlFormat () {
#
# Convert data array to MySQL Safe data array
#

    param (
        [Parameter(Mandatory=$True)]
        [System.Array] $Data
    )

    If ($Data.Count -le 0) {
        # Empty dataset
        Write-ErrorMsg -Message "[ERROR] Please supply some data. :)"

    } Else {
        # Process the data
        $Keys = Get-Keys -Object $Data[0]

        Write-OKMsg -Message ("[OK] Working on "+($Data.Count)+" records, with "+($Keys.Count)+" columns")

        # Create Empty Data Structure
        $NewData = @()

        # Iterate through the data records
        $Timer = Measure-Command -Expression {
            Foreach ($Record in $Data) {

                # Dictionary
                $NewRecord = @{}

                Foreach ($Key in $Keys) {

                    $NewRecord.($Key.mysql) = $Record.($Key.original)
                    
                    
                }

                $NewData += $NewRecord

            }
        }

        $TimeTaken = [math]::Round($Timer.Seconds)

        Write-OKMsg -Message ("Returning "+($NewData.Count)+" records in "+$TimeTaken+" seconds.")

        Write-Output -NoEnumerate $NewData

    }

}






# Private Functions

Function Get-Keys () {

    param (
        [Parameter(Mandatory=$True)]
        [PSCustomObject] $Object
    )

    $Keys = @()
    Foreach ($Property in $Object.PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'}) {

        $Key = @{}

        $KeyOrgi = $Property.Name
        $KeyMysql = (ConvertTo-MySqlFriendly -Value $Property.Name)

        $Key.original = $KeyOrgi
        $Key.mysql = $KeyMysql 

        $Keys += $Key

    }

    Return $Keys

}

Function ConvertTo-MySqlFriendly () {
    #
    #
    # Returns: String
    
        param (
            [Parameter(Mandatory=$True)]
            [String] $Value
        )
    
        $NewValue = $Value.Replace(' ','_').ToLower()
        $NewValue  = $NewValue  -Replace "[^a-zA-Z0-9_]"
    
        # What is the max length for a column or table name?
    
        Return $NewValue
    
    }


    Function Write-BoxMessage () {

        param (
            [Parameter(Mandatory=$True)]
            [String] $Title,
            [Parameter(Mandatory=$True)]
            [String] $Message,
            [Parameter(Mandatory=$False)]
            [String] $BoxColour = "White",
            [Parameter(Mandatory=$False)]
            [String] $MsgColour = "Gray"
        )

        $BoxString = "[" + $Title + "]"
        Write-Host $BoxString" " -ForegroundColor $BoxColour -NoNewline
        Write-Host $Message" " -ForegroundColor $MsgColour

    }

    Function Write-OKMsg () {

        param (
            [Parameter(Mandatory=$True)]
            [String] $Message
        )
        Write-BoxMessage -Title "OK" -Message $Message -BoxColour Green
    }

    Function Write-ErrorMsg () {

        param (
            [Parameter(Mandatory=$True)]
            [String] $Message
        )
        Write-BoxMessage -Title "Error" -Message $Message -BoxColour Red
    }

