function Set-LogFile
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)]
        [string]$LogFileName,
        [parameter(Mandatory=$true)]
        [int]$LogFileSizeThreshold
    )
    process
    {
        $logPath = ([IO.Path]::Combine($env:LOCALAPPDATA,'PowerShellLogging',[IO.Path]::GetFileNameWithoutExtension($logFileName)))
        
        if(-not (Test-Path $logPath))
        {
            try
            {
                New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
            }
            catch
            {
                throw 
            }
        }
        
        [string]$global:logFile = $logPath + '\' + [IO.Path]::GetFileNameWithoutExtension($logFileName) + ".log"

        try
        {
            $log = Get-Item $logFile -ErrorAction Stop
            if ( ($log.Length / $logFileSizeThreshold) -ge '1')
            {
                Rename-Item -Path $log.FullName -NewName "$($log.BaseName)_$(Get-Date -Format ddMMyyThhmmss).old"
                Log -Message "Log file $($log.Name) is at $($log.length) Bytes size which is larger than the allowed size threshold of $($logFileSizeThreshold) Bytes, prior log file has been renamed to $($log.BaseName)_$(Get-Date -Format ddMMyyThhmmss).log." -Type Warning
            }
            else
            {
                Log -Message "Log file $($log.Name) is currently at $($log.Length) bytes which has not exceeded the allowed size threshold of $($logFileSizeThreshold) bytes, file will continue to be used." -Type Normal
                return
            }
        }
        catch
        {
            Log -Message "$($logFile) could not be retrieved due to the following exception`r`n$($_.Exception.Message)`r`n$($logFile) has now been created." -Type Normal
        }
    }
}