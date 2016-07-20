[CmdletBinding()]
param(
    [Alias('q')]
    [switch]$Quiet,

    [switch]$ImportLocalModules
)

# Basic variables...
$file = $MyInvocation.MyCommand.Path
$dir = Split-Path $file -Parent

if (-not($PSBoundParameters.Keys -contains 'ErrorAction')) {
    if (-not($Quiet.IsPresent)) {
        Write-Host "Defaulting ErrorAction to 'Continue' in order to avoid impacting package install..."
    }
    $ErrorActionPreference = 'Continue'
}

$commandPath = $MyInvocation.PSCommandPath
$commandDir = Split-Path $CommandPath -Parent
$commandDirName = Split-Path $commandDir -Leaf

if ($commandDirName -eq 'tools') {
    $packageFolder = (Split-Path $commandDir -Parent)
} else {
    $packageFolder = $commandDir
}

if (-not($env:chocolateyPackageFolder)) {
    Write-Warning "Environment variable 'chocolateyPackageFolder' is not defined."
    Write-Host "Setting chocolateyPackageFolder=$($packageFolder)"
    $env:chocolateyPackageFolder = $packageFolder
}

$chocoExtensionsFolder = "$env:ChocolateyInstall\extensions"

$loadedModules = [array](Get-Module | foreach { $_.Path })

if (Test-Path "$env:chocolateyPackageFolder\packages.config") {
    if (-not($Quiet.IsPresent)) {
        Write-Host "Ensuring that extension modules are loaded..."
    }

    $packagesConfig = [xml](Get-Content "$env:chocolateyPackageFolder\packages.config")
    $packagesConfig.packages.package | foreach {
        $packageName = $_.id
        if ($packageName -match '^(.+)\.extension$') {
            if (-not($Quiet.IsPresent)) {
                Write-Host "Found chocolatey extension '$($packageName)'."
            }

            $packageNameWithoutExtension = $packageName -replace '^(.+)\.extension$', '$1'
            if (Test-Path "$chocoExtensionsFolder\$packageName") {
                if (-not($Quiet.IsPresent)) {
                    Write-Host "Chocolatey extension '$($packageName)' is installed."
                }

                Get-ChildItem "$chocoExtensionsFolder\$packageName" -Filter '*.psm1' -Recurse | foreach {
                    if (-not($Quiet.IsPresent)) {
                        Write-Host "Ensuring that module '$(Split-Path $_.FullName -Leaf)' is loaded."
                    }
                    if (-not($loadedModules -contains $_.FullName)) {
                        Write-Warning "Extension  module '$(Split-Path $_.FullName -Leaf)' is not loaded."
                        Write-Host "Importing module '$($_.FullName)'..."
                        Import-Module $_.FullName
                        $loadedModules = [array](Get-Module | foreach { $_.Path })
                    }
                }
            } else {
                Write-Warning "Package '$($packageName)' was not found in the extensions folder."
            }
        }
    }
}

if ($ImportLocalModules.IsPresent) {
    if (-not($Quiet.IsPresent)) {
        Write-Host "Importing local modules within '$($env:chocolateyPackageFolder)'..."
    }
    Get-ChildItem $env:chocolateyPackageFolder -Filter '*.psm1' -Recurse | foreach {
        Write-Host "Importing module '$($_.FullName)'..."
        Import-Module $_.FullName
        $loadedModules = [array](Get-Module | foreach { $_.Path })
    }
}
