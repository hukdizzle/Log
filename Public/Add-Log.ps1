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
        if(-not $logFile)
        {
            Set-LogFile -LogFileName $MyInvocation.ScriptName -LogFileSizeThreshold 1GB
        }
        
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

        if(((Get-Item $logFile).Length / $logThreshold) -ge '1')
        {
            Set-LogFile -LogFileName ([IO.Path]::GetFileNameWithoutExtension($logFile)) -LogFileSizeThreshold $logThreshold
        }
    }
}