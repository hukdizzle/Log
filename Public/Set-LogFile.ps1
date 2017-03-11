function Set-LogFile
{
    <#
    .NOTES
	    Title:			Set-LogFile.ps1
	    Author:			Curtis Jones
	    Date:			March 10th, 2017
	    Version:		1.0.0
	    Requirements:		Powershell 5.0
	
    .SYNOPSIS
        Facilitates log function generation in the $env:LOCALAPPDATA\PowerShellLogging folder and also manages log file size threshold and renaming of old log files.
    .DESCRIPTION
        Set-LogFile provides an effective way to create and manage log files within the $env:LOCALAPPDATA\PowerShellLogging folder. This function requires a log file name string and log file threshold integer input with an optional switch parameter to show the log file location. Set-LogFile will attempt to create the log file path if necessary and establish a global log file size threshold and logfile path to be used by Add-Log. If the ShowLocation switch is used the MessageBox show method will display the location of the generated log file.
    .PARAMETER LogFileName

        Provide a simple name with no spaces such as < ScriptName >
    .PARAMETER LogFileSizeThreshold

        Provide a valid size for a log file threshold such as 1GB, 500MB, 1024KB, etc.
    .PARAMETER ShowLocation

        Use switch to utilize the Forms.MessageBox method to display the log file name and location.
    .EXAMPLE
        Set-LogFile -LogFileName TestLogName -LogFileSizeThreshold 10MB -ShowLocation

        The example above will create a log file in the $env:LOCALAPPDATA\PowerShellLogging\TestLogName\TestLogName.log. The log file size threshold will be set to 10MB and the location of the log file will be displayed using the MessageBox show method.
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true,HelpMessage="Provide a simple name with no spaces such as < ScriptName >.")]
        [string]$LogFileName,
        [parameter(Mandatory=$true,HelpMessage="Provide a valid size for a log file threshold such as 1GB, 500MB, 1024KB, etc.")]
        [int]$LogFileSizeThreshold,
        [parameter(Mandatory=$false,HelpMessage="Use switch to utilize the Forms.MessageBox method to display the log file name and location.")]
        [switch]$ShowLocation
    )
    begin
    {
    }
    process
    {
        #A logPath string variable is set utilizing an IO.Path method to combine the local AppData, PowerShellLogging, and the logFileName param after it's been sanitized of any extensions or invalid characters that may have been erroneously input to the function.

        $logPath = ([IO.Path]::Combine($env:LOCALAPPDATA,'PowerShellLogging',[IO.Path]::GetFileNameWithoutExtension((([char[]]$LogFileName | Where-Object { [IO.Path]::GetInvalidFileNameChars() -notcontains $_ }) -join ''))))
        
        #If the logPath location does not exist the following block will be entered and the directory will be created. If creation fails a terminating error will be thrown.
        
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
        
        #A global logFile string variable will be constructed utilzing the logPath string, sanitized logFileName param input, and all necessary delimiters and extensions. A global logThreshold variable will be set based on the logFileSizeThreshold function input.

        [string]$global:logFile = $logPath + '\' + [IO.Path]::GetFileNameWithoutExtension($logFileName) + ".log"
        $global:logThreshold = $LogFileSizeThreshold

        #An attempt to find the log file based on the logFile variable string will be made and stored to a variable. If no log file is found the Add-Log function will be called to initiate creation of the log file.

        try
        {   
            $log = Get-Item $logFile -ErrorAction Stop

            #If a log file is found the log file size will be evaluated against the logFileSizeThreshold param input. If the log file size divided by the logFileSizeThreshold is found to be greater than or equal to one the if block will be entered, else the Add-Log function will be called to indicate the log file being of acceptable size and it will continue to be used.

            if ( ($log.Length / $logFileSizeThreshold) -ge '1' )
            {
                
                #If the log file size is larger than the specified logFileSizeThreshold the current log file will be renamed to retain log information. Renamed log files will utilize a convention such as follows, FileName_ddMMyyThhmmss.old. The Add-Log function will be called generating a new log file and indicating the name of the old log file.
                
                Rename-Item -Path $log.FullName -NewName "$($log.BaseName)_$(Get-Date -Format ddMMyyThhmmss).old"
                Log -Message "Log file $($log.Name) is at $($log.length) Bytes size which is larger than the allowed size threshold of $($logFileSizeThreshold) Bytes, prior log file has been renamed to $($log.BaseName)_$(Get-Date -Format ddMMyyThhmmss).log." -Type Warning
            }
            else
            {
                Log -Message "Log file $($log.Name) is currently at $($log.Length) bytes which has not exceeded the allowed size threshold of $($logFileSizeThreshold) bytes, file will continue to be used." -Type Normal
            }
        }
        catch
        {
            Log -Message "$($logFile) could not be retrieved due to the following exception`r`n$($_.Exception.Message)`r`n$($logFile) has now been created." -Type Normal
        }

        #If the ShowLocation param is used the following block will be entered. The Win32 Forms assembly will be loaded to expose the MessageBox class and methods. The Show method is used to pop up a Windows forms box to indicate the log file location and the user must acknowledge this by clicking on the OK button within the message box dialog.

        if($ShowLocation)
        {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("Please refer to the log file located at the following location.`r`n`n$($logFile)","Log File Setup")
        }
    }
    end
    {
    }
}