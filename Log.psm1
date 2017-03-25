$moduleRoot = Split-Path $MyInvocation.MyCommand.Path

# Importing public functions (these are exposed through the module after import)
"$moduleRoot\Public\*.ps1" |
	Resolve-Path |
	ForEach-Object {
		. $_.ProviderPath
	}