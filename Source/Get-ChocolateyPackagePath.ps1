<#
.SYNOPSIS
Gets the path where the Chocolatey package is currently being installed or uninstalled from.

.DESCRIPTION

Chocolatey has provided a 'chocolateyPackageFolder' environment variable since
v0.9.8.20 (late 2012), so you should use that instead, unless you have a need to
support really old chocolatey clients (if that's even possible).

.EXAMPLE

PS> $packagePath = Get-ChocolateyPackagePath
// => 'C:\ProgramData\chocolatey\lib\mypackage'

Gets the package folder that the current chocolatey script is being run from.

#>
[CmdletBinding()]
param(
    [string]$CommandPath=$MyInvocation.PSCommandPath
)

if ($env:chocolateyPackageFolder) {
    Write-Host "HINT: Use the 'chocolateyPackageFolder' environment variable instead." -ForegroundColor Magenta
    return $env:chocolateyPackageFolder
}

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
