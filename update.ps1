$CWD = [Environment]::CurrentDirectory

Push-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

try {
    $razerSynapseUrl = 'http://rzr.to/synapse-3-pc-download'

    Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Checking for update"

    # Start capture of remote version
    $response = try {
        Invoke-WebRequest -Uri $razerSynapseUrl -UseBasicParsing
    }
    catch {
        $_.Exception.Response
    }

    if (-not $response.BaseResponse.ResponseUri.AbsoluteUri) {
        Add-Content -Path '.\update.log' -Value "[$(Get-Date)] No redirection uri returned when requesting $razerSynapseUrl"
        return
    }

    $downloadUrl = $response.BaseResponse.ResponseUri.AbsoluteUri
    if (-not ($downloadUrl -match '.*_V(?<RemoteVersion>.*)\.exe')) {
        Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Could not determine version from url $downloadUrl"
        return
    }
    $remoteVersion = $matches.RemoteVersion
    $remoteFilename = [System.IO.Path]::GetFileName($downloadUrl)

    # Make sure web installer files folder exists
    if (-not (Test-Path -Path '.\files\web-installer')) {
        New-Item -Path '.\files\web-installer' -ItemType Directory
    }

    # Start capture of local version
    $localVersion = $null
    if (Test-Path -Path '.\files\web-installer\*.exe') {
        $localFileInfo = Get-ItemProperty -Path '.\files\web-installer\*.exe' | Sort-Object -Property Name | Select-Object -Last 1
        if (-not ($localFileInfo.Name -match '.*_V(?<LocalVersion>.*)\.exe')) {
            Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Could not determine version from local file $($localFileInfo.Name)"
            return
        }
        $localVersion = $matches.LocalVersion
    }

    # Check remote version against local version
    if ($null -eq $localVersion -or [System.Version]$remoteVersion -gt [System.Version]$localVersion) {
        # Update found
        if ($null -eq $localVersion) {
            Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Updating to initial version $remoteVersion"
        }
        else {
            Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Updating from version $localVersion to version $remoteVersion"
        }

        # Start install of web installer to get components
        Invoke-WebRequest -Uri $downloadUrl -Outfile ".\files\web-installer\$remoteFilename" -UseBasicParsing

        # Remove previous components and files if any exist
        Remove-Item -Path 'C:\Windows\Installer\Razer\Installer\*' -Recurse -Force

        $script = Start-Process 'AutoHotKey' 'web-install.ahk' -PassThru
        Start-Process ".\files\web-installer\$remoteFilename" -Wait

        $scriptHandle = $script.Handle
        $script.WaitForExit()
        Add-Content -Path '.\update.log' -Value "[$(Get-Date)] AHK Script ExitCode $($script.ExitCode)"

        if ($script.ExitCode -eq 0) {
            Remove-Item -Path ".\files\web-installer\*" -Exclude "RazerSynapseInstaller_V$remoteVersion.exe"
        }
        elseif ($script.ExitCode -ne 0 -and (-not ([string]::IsNullOrEmpty($localVersion)))) {
            Remove-Item -Path ".\files\web-installer\*" -Exclude "RazerSynapseInstaller_V$localVersion.exe"
            
            Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Something went wrong, exiting with error"
            Add-Content -Path '.\update.log' -Value "--------------------------------------------------------------------------------"

            Exit 1
        }
        elseif ($script.ExitCode -ne 0 -and ([string]::IsNullOrEmpty($localVersion))) {
            Remove-Item -Path ".\files\web-installer\*"
            
            Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Something went wrong, exiting with error"
            Add-Content -Path '.\update.log' -Value "--------------------------------------------------------------------------------"

            Exit 1
        }

        # Make sure components files folder exists
        if (-not (Test-Path -Path '.\files\components')) {
            New-Item -Path '.\files\components' -ItemType Directory
        }

        Remove-Item -Path '.\files\components\*'

        Copy-Item -Path 'C:\Windows\Installer\Razer\Installer\*_*.exe' -Destination '.\files\components' -Recurse

        # Get information from each component
        $components = @()
        $componentInfos = Get-ItemProperty -Path '.\files\components\*'
        foreach ($componentInfo in $componentInfos) {
            if (-not ($componentInfo.Name -match ".*(?<ComponentName>Razer\S*|GMS\S*Setup)_.*")) {
                Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Could not determine component name from $($componentInfo.Name)"
            }
            $componentName = $matches.ComponentName.replace('_', '')

            $components += @{
                Name = $componentName;
                Link = "https://cdn.razersynapse.com/$($componentInfo.Name)";
                Hash = (Get-FileHash -Path ".\files\components\$($componentInfo.Name)" -Algorithm 'sha256').Hash;
            }
        }

        # Prep urls and checksums to be replaced in chocolatey install script
        $componentReplaceValues = @{}
        foreach ($component in $components) {
            $componentReplaceValues += @{"(?i)(^[$]$($component.Name)Url\s*=\s*)'.*'" = "`${1}'$($component.Link)'" }
            $componentReplaceValues += @{"(?i)(^[$]$($component.Name)Checksum\s*=\s*)'.*'" = "`${1}'$($component.Hash)'" }
        }

        # Make sure chocolatey packages repo is cloned
        if (-not (Test-Path -Path '.\chocolatey-packages')) {
            git clone https://github.com/Zoullx/chocolatey-packages.git
        }

        # Update chocolatey-packages repo
        Push-Location '.\chocolatey-packages'
        git pull
        Pop-Location

        # Replace urls and checksums in chocolatey install script
        $chocolateyInstallScriptFilename = '.\chocolatey-packages\razer-synapse-3\tools\chocolateyInstall.ps1'
        $fileContent = Get-Content $chocolateyInstallScriptFileName -Encoding UTF8
        $componentReplaceValues.GetEnumerator() | ForEach-Object {
            if (!($fileContent -match $_.name)) { throw "Search pattern not found: '$($_.name)'" }
            $fileContent = $fileContent -replace $_.name, $_.value
        }
        $utf8BomEncoding = New-Object System.Text.UTF8Encoding($true)
        $output = $fileContent | Out-String
        [System.IO.File]::WriteAllText($chocolateyInstallScriptFilename, $output, $utf8BomEncoding)

        # Replace version in nuspec file with new version
        $nuspecFile = '.\chocolatey-packages\razer-synapse-3\razer-synapse-3.nuspec'
        $nuspec = New-Object xml
        $nuspec.PSBase.PreserveWhitespace = $true
        $nuspec.Load($nuspecFile)
        $nuspec.package.metadata.version = $remoteVersion
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($nuspecFile, $nuspec.InnerXml, $utf8NoBomEncoding)

        # Commit update to chocolatey-packages repo
        Push-Location '.\chocolatey-packages'
        git add .
        git commit -m "Update Razer Synapse 3 chocolatey package to version $remoteVersion (auto)"
        git push
        Pop-Location

        Add-Content -Path '.\update.log' -Value "[$(Get-Date)] Finished updating to version $remoteVersion"
        Add-Content -Path '.\update.log' -Value "--------------------------------------------------------------------------------"
    }
    elseif ([System.Version]$remoteVersion -eq [System.Version]$localVersion -and (Get-Item -Path ".\files\web-installer\*" | Measure-Object).Count -gt 1) {
        Remove-Item -Path ".\files\web-installer\*" -Exclude (Get-Item -Path ".\files\web-installer\*.exe" | Sort-Object -Property Name | Select-Object -Last 1).Name
        
        Add-Content -Path '.\update.log' -Value "[$(Get-Date)] No update found"
        Add-Content -Path '.\update.log' -Value "--------------------------------------------------------------------------------"
    }
    else {
        Add-Content -Path '.\update.log' -Value "[$(Get-Date)] No update found"
        Add-Content -Path '.\update.log' -Value "--------------------------------------------------------------------------------"
    }
}
catch {
    Add-Content -Path '.\update.log' -Value "[$(Get-Date)] $PSItem"
    Add-Content -Path '.\update.log' -Value "--------------------------------------------------------------------------------"
}

Pop-Location
[Environment]::CurrentDirectory = $CWD