function Set-LogFile
{
    <#
    .NOTES
	    Title:			Set-LogFile.ps1
	    Author:			Curtis Jones
	    Date:			March 24th, 2017
	    Version:		1.0.0
	    Requirements:		Powershell 3.0
	
    .SYNOPSIS
        Provides log file generation in the $env:LOCALAPPDATA\PowerShellLogging folder based on input from the Add-Log function.
    .DESCRIPTION
        Set-LogFile provides an easy and effective way to create a new log file if necessary in the $env:LOCALAPPDATA\PowerShellLogging folder. If necessary the path and the file will be created and a file path string will be returned by the function for use by the Add-Log function. If the ShowLocation switch param is used the MessageBox show method will be used to display the location of the created file.
    .PARAMETER LogFileName

        Provide a simple name with no spaces such as < ScriptName >
    .PARAMETER ShowLocation

        Use switch to utilize the Forms.MessageBox method to display the log file name and location.
    .EXAMPLE
        Set-LogFile -LogFileName TestLogName -ShowLocation

        The example above will create the following log file/location, $env:LOCALAPPDATA\PowerShellLogging\TestLogName\TestLogName.log. The log file location will be displayed using the MessageBox show method.
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
        #A logPath string variable is set utilizing an IO.Path method to combine the local AppData path, PowerShellLogging string, and the logFileName param after it's been sanitized of any extensions or invalid characters that may have been erroneously input to the function.

        $logPath = ([System.IO.Path]::Combine($env:LOCALAPPDATA,'PowerShellLogging',[System.IO.Path]::GetFileNameWithoutExtension($logFileName)))
        
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
        
        #A logFile string variable will be constructed utilzing the logPath string, sanitized logFileName param input, and all necessary delimiters and extensions. If the logFile file path does not exist it will be created by the try/catch.

        [string]$logFile = $logPath + '\' + $([System.IO.Path]::GetFileNameWithoutExtension($logFileName)) + ".log"

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

        #If the ShowLocation param is used and the executing invocation is running in UserInteractive mode the following block will be entered. The Win32 Forms assembly will be loaded to expose the MessageBox class and methods. The Show method is used to pop up a Windows forms box to indicate the log file location and the user must acknowledge this by clicking on the OK button within the message box dialog.

        if($ShowLocation -and ([Environment]::UserInteractive))
        {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("Please refer to the log file located at the following location.`r`n`n$($logFile)","Log File Setup") | Out-Null
        }
    }
    
    #The logFile file path string will be returned to the calling code.

    end
    {
        return $logFile
    }
}