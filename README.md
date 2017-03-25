# Log

Log is a PowerShell module that is designed to give a simple and intuitive experience with local machine PowerShell script/function execution logging and stream output. There is no need to declare any paths or file names with this module, just call the Log function in your scripts and the module will take care of the rest!

### Installation

The Log module can be installed utilizing the Install-Module cmdlet on any machine running WMF 5.0 or later. The following code snippet can be used to install the module.

```posh
Install-Module -Name Log -Repository PSGallery
```

### Usage

Once the module is installed on the local machine just start calling the Log function from within your script/function such as the following example.

```posh
Log -Message 'I am a robot!' -Type Normal -Out
```
For this example, lets say that the name of the script/function you are writing is SuperCoolStuff.ps1. The above example would log the string 'I am a robot!' to the log file SuperCoolStuff.log located in the $env:LOCALAPPDATA\PowerShellLogging\SuperCoolStuff directory. The string message would also be passed into the output stream and output to the console with the Write-Output cmdlet. Here is an example of what the log entry would look like within the log file.

```
[3/25/2017 2:36:29 PM | 10852 | SUPERCOOLUSER | NORMAL] I am a robot!
```

As you can see there is some additional helpful information automatically injected with the Log function call. The date/time is stamped, the process id of the executing PowerShell executable, the executing windows user name, and the type parameter that was passed in with the Log function call. All of this is omitted when output to the console , only the message string is passed to the console.

### Useful Features
* **Automatic Log File Size Maintenance**
  * Each time the Log function is called it evaluates the size of the current log file. If the log file grows larger than 100MB a new log file is created automatically and the old log file is renamed to LogFileName_DateTime.old. This ensures no loss of logging data and that the log files do not grow too large to be useful under heavy use.
* **All Native PowerShell Output Streams Supported**
  * The Type parameter of the Log function supports all native PowerShell output streams such as **Normal**, **Error**, **Warning**, **Debug**, and **Verbose**. To pass the message string to the corresponding output stream make sure to call the Out switch parameter along with the correct Type value.
* **Log File Location Notification**
  * If the Log function is being called for the first time in a PSSession and the current PSSession environment is in UserInterative mode the .NET MessageBox class Show method is used to advise the executing user of the log file location. The user must click with the mouse on the OK button for the script/function execution to proceed. This notification only happens once per PSSession. If the script/function is being executed in Non-UserInteractive mode such as a PowerShell scheduled job, the MessageBox Show method will NOT be called as it is not necessary.