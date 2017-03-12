function Set-LogFile
{
    <#
    .NOTES
	    Title:			Set-LogFile.ps1
	    Author:			Curtis Jones
	    Date:			March 10th, 2017
	    Version:		1.0.0
	    Requirements:		Powershell 3.0
	
    .SYNOPSIS
        Facilitates log function generation in the $env:LOCALAPPDATA\PowerShellLogging folder and also manages log file size threshold and renaming of old log files.
    .DESCRIPTION
        Set-LogFile provides an effective way to create and manage log files within the $env:LOCALAPPDATA\PowerShellLogging folder. This function requires a log file name string and log file threshold integer input with an optional switch parameter to show the log file location. Set-LogFile will attempt to create the log file path if necessary and establish a global log file size threshold and logfile path to be used by Add-Log. If the ShowLocation switch is used the MessageBox show method will display the location of the generated log file.
    .PARAMETER LogFileName

        Provide a simple name with no spaces such as < ScriptName >
    .PARAMETER ShowLocation

        Use switch to utilize the Forms.MessageBox method to display the log file name and location.
    .EXAMPLE
        Set-LogFile -LogFileName TestLogName -ShowLocation

        The example above will create the following log file/location, $env:LOCALAPPDATA\PowerShellLogging\TestLogName\TestLogName.log. The log file size threshold will be set to 10MB and the location of the log file will be displayed using the MessageBox show method.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory=$true,HelpMessage="Provide a simple name with no spaces such as < ScriptName >.")]
        [string]$LogFileName,
        [parameter(Mandatory=$false,HelpMessage="Use switch to utilize the Forms.MessageBox method to display the log file name and location.")]
        [switch]$ShowLocation
    )
    process
    {
        #A logPath string variable is set utilizing an IO.Path method to combine the local AppData, PowerShellLogging, and the logFileName param after it's been sanitized of any extensions or invalid characters that may have been erroneously input to the function.

        $logPath = ([IO.Path]::Combine($env:LOCALAPPDATA,'PowerShellLogging',[IO.Path]::GetFileNameWithoutExtension($logFileName)))
        
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

        [string]$logFile = $logPath + '\' + $([IO.Path]::GetFileNameWithoutExtension($logFileName)) + ".log"

        if(-not (Test-Path $logFile))
        {
            try
            {
                New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
            }
            catch
            {
                throw
            }
        }

        #If the ShowLocation param is used the following block will be entered. The Win32 Forms assembly will be loaded to expose the MessageBox class and methods. The Show method is used to pop up a Windows forms box to indicate the log file location and the user must acknowledge this by clicking on the OK button within the message box dialog.

        if($ShowLocation -and ([Environment]::UserInteractive))
        {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("Please refer to the log file located at the following location.`r`n`n$($logFile)","Log File Setup") | Out-Null
        }
    }
    end
    {
        return $logFile
    }
}