function Add-Log
{
    [CmdletBinding()]
    [Alias("Log")]
    param
    (
        [parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [parameter(Mandatory=$true,Position=1)]
        [ValidateSet("Normal","Error","Warning","Debug","Verbose")]
        [string]$Type,
        [parameter(Mandatory=$false,Position=2)]
        [switch]$Out
    )
    process
    {
        "[$(Get-Date -format 'G') | $($pid) | $($env:username) | $($Type.ToUpper())] $Message" | Out-File -FilePath $Logfile -Append

        if($Out)
        {
            switch ($Type)
            {
                Normal { Write-Output $Message }
                Error { Write-Error -Message $Message }
                Warning { Write-Warning -Message $Message }
                Debug { Write-Debug -Message $Message -Debug }
                Verbose { Write-Verbose -Message $Message -Verbose }
            }
        }
    }
}