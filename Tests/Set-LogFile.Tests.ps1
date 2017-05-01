Describe "Public Functions" {
    $logFile = Set-LogFile -LogFileName 'Testing123'
    It "logFile return var should not be null" {
        $logFile | Should Not BeNullorEmpty
    }
    AfterEach {
        Remove-Item -Path ([System.IO.Path]::GetDirectoryName($logFile)) -Recurse -Confirm:$false
    }
}