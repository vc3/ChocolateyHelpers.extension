Write-Verbose "Loading 'Build\psake-tasks.ps1'..."

properties {
    Write-Verbose "Applying properties from 'Build\psake-tasks.ps1'..."

    $chocoOutDir = $outDir
    $chocoPkgsDir = "$root\Output"

    $moduleSpecFile = "$root\module.psd1"
    $moduleDestination = "$root\Output"

    $projectLicense = 'MIT'
    $projectUrl = 'https://github.com/vc3/ChocolateyHelpers.extension'

    $packageVersion = (Import-PSData $moduleSpecFile).Version
    $packageTitle = 'ChocolateyHelpers.extension (Chocolatey Extension)'

    $changeLogFile = "$root\ChangeLog.md"
}

include '.\Build\Modules\Psake-Choco\psake-tasks.ps1'
include '.\Build\Modules\Psake-ModuleBuilder\psake-tasks.ps1'

task EnsureApiKey {
	if (-not $chocoApiKey) {
		throw "Psake property 'chocoApiKey' must be configured."
	}
}

task UpdateOutput -depends ModuleBuilder:Build,Choco:GenerateNuspec

task Build -depends EnsureApiKey,UpdateOutput,Choco:BuildPackages

task Deploy -depends EnsureApiKey,Choco:DeployPackages
