$moduleRoot = Split-Path $MyInvocation.MyCommand.Path

# Importing public functions (these are exposed through the module after import)
"$moduleRoot\Public\*.ps1" |
	Resolve-Path |
	ForEach-Object {
		. $_.ProviderPath
	}

# Importing all private helper functions (that are not exposed to the user through the module)
"$moduleRoot\Private\*.ps1" |
	Resolve-Path |
	ForEach-Object {
		. $_.ProviderPath
	}