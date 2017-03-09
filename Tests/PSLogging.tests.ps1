
$workingdir = (get-location).path 
Describe "Meta Validation" {

    Context "Importing the module" {
        It "Should Import" {
            { Import-Module .\PSLogging.psd1 -ErrorAction Stop } | should not throw
        }
    }
}

# example top-level block
Describe "NameOfYourModule" {

	# example of a logical grouping of tests
	Context "LogicalGroupingOfTests" {
	
		# example of a test, the string following the 'It' keyword should reflect the nature of the test, and will be returned to the console
		It "Should behave predictably" {
			$true | Should Be $false
		}
	
	}

}

