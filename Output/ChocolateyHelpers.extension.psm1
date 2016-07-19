function Get-ChocolateyPackagePath {
	[CmdletBinding()]
	param(
	    [string]$CommandPath=$MyInvocation.PSCommandPath
	)
	
	$commandName = Split-Path $CommandPath -Leaf
	
	if ($commandName -ne 'chocolateyInstall.ps1' -and $commandName -ne 'chocolateyUninstall.ps1') {
	    Write-Error "Cannot get package path from unsupported script '$($CommandPath)'."
	    return
	}
	
	$commandDir = Split-Path $CommandPath -Parent
	$commandDirName = Split-Path $commandDir -Leaf
	
	if ($commandDirName -eq 'tools') {
	    Write-Output (Split-Path $commandDir -Parent)
	} else {
	    Write-Output $commandDir
	}
}

Export-ModuleMember -Function Get-ChocolateyPackagePath
