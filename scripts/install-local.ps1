[CmdletBinding()]
param(
    [string]$HyperMeshGuiExe,
    [string]$HyperMeshBatchExe,
    [string]$NastranTemplateDir,
    [string]$PythonExecutable = 'python',
    [string]$CodexExecutable,
    [string]$CodexHome,
    [string]$StateDirectory,
    [string]$RunsDirectory,
    [switch]$SkipDependencyInstall,
    [switch]$SkipSkillInstall,
    [switch]$SkipMcpRegistration,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-OptionalExecutable {
    param(
        [string]$Value,
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }
    if (-not (Test-Path -LiteralPath $Value -PathType Leaf)) {
        throw "$Label does not exist: $Value"
    }
    return (Resolve-Path -LiteralPath $Value).Path
}

function Resolve-PythonExecutable {
    param([Parameter(Mandatory = $true)][string]$Value)

    $command = Get-Command $Value -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Python executable was not found: $Value"
    }
    return $command.Source
}

function Resolve-OptionalDirectory {
    param(
        [string]$Value,
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }
    if (-not (Test-Path -LiteralPath $Value -PathType Container)) {
        throw "$Label does not exist: $Value"
    }
    return (Resolve-Path -LiteralPath $Value).Path
}

function ConvertTo-NormalizedPath {
    param([Parameter(Mandatory = $true)][string]$Value)

    if (Test-Path -LiteralPath $Value -PathType Leaf) {
        return (Resolve-Path -LiteralPath $Value).Path
    }
    return [System.IO.Path]::GetFullPath($Value)
}

function Get-StrictPowerShellFileLauncherArgument {
    param($Transport)

    if ($null -eq $Transport -or [string]$Transport.type -ne 'stdio') {
        return $null
    }
    $commandProperty = $Transport.PSObject.Properties['command']
    if ($null -eq $commandProperty -or [string]::IsNullOrWhiteSpace([string]$commandProperty.Value)) {
        return $null
    }
    $commandName = [System.IO.Path]::GetFileName([string]$commandProperty.Value)
    if (-not $commandName.Equals('powershell.exe', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }
    $argsProperty = $Transport.PSObject.Properties['args']
    if ($null -eq $argsProperty -or $null -eq $argsProperty.Value) {
        return $null
    }
    $arguments = @($argsProperty.Value | ForEach-Object { [string]$_ })
    $fileIndexes = @()
    for ($index = 0; $index -lt $arguments.Count; $index++) {
        if ($arguments[$index] -ieq '-File') {
            $fileIndexes += $index
        }
    }
    if ($fileIndexes.Count -ne 1) {
        return $null
    }
    $fileIndex = $fileIndexes[0]
    if ($fileIndex -ne ($arguments.Count - 2) -or [string]::IsNullOrWhiteSpace($arguments[$fileIndex + 1])) {
        return $null
    }

    $seenNoLogo = $false
    $seenNoProfile = $false
    $seenExecutionPolicy = $false
    for ($index = 0; $index -lt $fileIndex; $index++) {
        $argument = $arguments[$index]
        if ($argument -ieq '-NoLogo') {
            if ($seenNoLogo) {
                return $null
            }
            $seenNoLogo = $true
            continue
        }
        if ($argument -ieq '-NoProfile') {
            if ($seenNoProfile) {
                return $null
            }
            $seenNoProfile = $true
            continue
        }
        if ($argument -ieq '-ExecutionPolicy') {
            if ($seenExecutionPolicy -or ($index + 1) -ge $fileIndex -or $arguments[$index + 1] -ine 'Bypass') {
                return $null
            }
            $seenExecutionPolicy = $true
            $index++
            continue
        }
        return $null
    }
    return $arguments[$fileIndex + 1]
}

function Test-PackageMcpRegistration {
    param(
        $Registration,
        [Parameter(Mandatory = $true)][string]$NormalizedLauncher
    )

    if ($null -eq $Registration) {
        return $false
    }
    $transportProperty = $Registration.PSObject.Properties['transport']
    if ($null -eq $transportProperty -or $null -eq $transportProperty.Value) {
        return $false
    }
    $launcherArgument = Get-StrictPowerShellFileLauncherArgument -Transport $transportProperty.Value
    if ($null -eq $launcherArgument) {
        return $false
    }
    try {
        $candidate = ConvertTo-NormalizedPath -Value $launcherArgument
        return $candidate.Equals($NormalizedLauncher, [System.StringComparison]::OrdinalIgnoreCase)
    }
    catch {
        return $false
    }
}

function Test-HyperMeshCaeAgentPackageRegistration {
    param($Registration)

    if ($null -eq $Registration) {
        return $false
    }
    $transportProperty = $Registration.PSObject.Properties['transport']
    if ($null -eq $transportProperty -or $null -eq $transportProperty.Value) {
        return $false
    }
    $launcherArgument = Get-StrictPowerShellFileLauncherArgument -Transport $transportProperty.Value
    if ($null -eq $launcherArgument -or
        -not [System.IO.Path]::GetFileName($launcherArgument).Equals('start-hypermesh-mcp.ps1', [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $launcherArgument -PathType Leaf)) {
        return $false
    }
    try {
        $launcherPath = (Resolve-Path -LiteralPath $launcherArgument).Path
        $packageCandidate = Split-Path -Parent (Split-Path -Parent $launcherPath)
        $manifestPath = Join-Path $packageCandidate '.codex-plugin\plugin.json'
        if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
            return $false
        }
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop
        return [string]$manifest.name -eq 'hypermesh-cae-agent'
    }
    catch {
        return $false
    }
}

function Test-HyperMeshCaeAgentSkillDirectory {
    param([Parameter(Mandatory = $true)][string]$SkillDirectory)

    $skillFile = Join-Path $SkillDirectory 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        return $false
    }
    try {
        $content = [System.IO.File]::ReadAllText($skillFile, [System.Text.Encoding]::UTF8)
        return $content -match '(?m)^name:\s*vehicle-door-cae\s*$' -and
            $content -match '(?m)^description:\s*This skill should be used when planning, auditing, or executing the stage-gated vehicle-door CAD-to-CAE workflow through the HyperMesh CAE Agent plugin,'
    }
    catch {
        return $false
    }
}

function Get-CodexMcpList {
    param([Parameter(Mandatory = $true)][string]$Executable)

    $output = @(& $Executable mcp list --json 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to list Codex MCP registrations: $($output -join [Environment]::NewLine)"
    }
    try {
        return @((($output -join [Environment]::NewLine) | ConvertFrom-Json -ErrorAction Stop))
    }
    catch {
        throw "Codex returned invalid MCP registration JSON: $($_.Exception.Message)"
    }
}

function Get-CodexMcpRegistration {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $output = @(& $Executable mcp get $Name --json 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read Codex MCP registration '$Name': $($output -join [Environment]::NewLine)"
    }
    try {
        $registration = (($output -join [Environment]::NewLine) | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        throw "Codex returned invalid JSON for MCP registration '$Name': $($_.Exception.Message)"
    }
    if ($null -eq $registration -or [string]$registration.name -ne $Name) {
        throw "Codex returned an unexpected MCP registration while reading '$Name'."
    }
    return $registration
}

function Get-CodexMcpRegistrationFingerprint {
    param([Parameter(Mandatory = $true)]$Registration)

    try {
        return ($Registration | ConvertTo-Json -Depth 12 -Compress)
    }
    catch {
        throw "Cannot serialize Codex MCP registration '$($Registration.name)' for change detection: $($_.Exception.Message)"
    }
}

function Test-CodexMcpRegistrationSnapshot {
    param(
        [Parameter(Mandatory = $true)]$Expected,
        [Parameter(Mandatory = $true)]$Actual
    )

    return (Get-CodexMcpRegistrationFingerprint -Registration $Expected) -ceq
        (Get-CodexMcpRegistrationFingerprint -Registration $Actual)
}

function Get-RestorableStdioTransport {
    param(
        [Parameter(Mandatory = $true)]$Registration
    )

    $enabledProperty = $Registration.PSObject.Properties['enabled']
    if ($null -ne $enabledProperty -and $enabledProperty.Value -ne $true) {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': it is disabled."
    }
    $disabledReasonProperty = $Registration.PSObject.Properties['disabled_reason']
    if ($null -ne $disabledReasonProperty -and -not [string]::IsNullOrWhiteSpace([string]$disabledReasonProperty.Value)) {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': it has a disabled reason."
    }
    foreach ($propertyName in @('enabled_tools', 'disabled_tools')) {
        $property = $Registration.PSObject.Properties[$propertyName]
        if ($null -ne $property -and $null -ne $property.Value -and @($property.Value | ForEach-Object { $_ }).Count -gt 0) {
            throw "Cannot safely restore Codex MCP '$($Registration.name)': it has $propertyName filters that Codex CLI cannot recreate automatically."
        }
    }
    foreach ($propertyName in @('startup_timeout_sec', 'tool_timeout_sec')) {
        $property = $Registration.PSObject.Properties[$propertyName]
        if ($null -ne $property -and $null -ne $property.Value) {
            throw "Cannot safely restore Codex MCP '$($Registration.name)': it has a custom $propertyName value that Codex CLI cannot recreate automatically."
        }
    }

    $transportProperty = $Registration.PSObject.Properties['transport']
    if ($null -eq $transportProperty -or $null -eq $transportProperty.Value) {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': its transport is missing."
    }
    $transport = $transportProperty.Value
    if ([string]$transport.type -ne 'stdio') {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': only stdio registrations are supported."
    }
    $commandProperty = $transport.PSObject.Properties['command']
    if ($null -eq $commandProperty -or [string]::IsNullOrWhiteSpace([string]$commandProperty.Value)) {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': its stdio command is missing."
    }
    $cwdProperty = $transport.PSObject.Properties['cwd']
    if ($null -ne $cwdProperty -and -not [string]::IsNullOrWhiteSpace([string]$cwdProperty.Value)) {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': it has a working directory that Codex CLI cannot recreate automatically."
    }
    $environmentVariableNamesProperty = $transport.PSObject.Properties['env_vars']
    if ($null -ne $environmentVariableNamesProperty -and $null -ne $environmentVariableNamesProperty.Value -and @($environmentVariableNamesProperty.Value | ForEach-Object { $_ }).Count -gt 0) {
        throw "Cannot safely restore Codex MCP '$($Registration.name)': it inherits environment variables that Codex CLI cannot recreate automatically."
    }
    return $transport
}

function Restore-CodexMcpRegistration {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)]$Registration
    )

    $transport = Get-RestorableStdioTransport -Registration $Registration
    $restoreArgs = @('mcp', 'add', [string]$Registration.name)
    $environmentProperty = $transport.PSObject.Properties['env']
    if ($null -ne $environmentProperty -and $null -ne $environmentProperty.Value) {
        foreach ($property in $environmentProperty.Value.PSObject.Properties) {
            if ([string]::IsNullOrWhiteSpace([string]$property.Name)) {
                throw "Cannot safely restore Codex MCP '$($Registration.name)': it has an invalid environment-variable name."
            }
            $restoreArgs += @('--env', ("{0}={1}" -f $property.Name, [string]$property.Value))
        }
    }
    $restoreArgs += @('--', [string]$transport.command)
    $transportArgsProperty = $transport.PSObject.Properties['args']
    if ($null -ne $transportArgsProperty -and $null -ne $transportArgsProperty.Value) {
        $restoreArgs += @($transportArgsProperty.Value | ForEach-Object { [string]$_ })
    }
    & $Executable @restoreArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to restore the previous Codex MCP registration '$($Registration.name)'."
    }
}

$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$requirementsPath = Join-Path $packageRoot 'requirements.txt'
$snippetScript = Join-Path $PSScriptRoot 'create-codex-mcp-snippet.ps1'
$checkScript = Join-Path $PSScriptRoot 'check-environment.ps1'
$launcher = Join-Path $PSScriptRoot 'start-hypermesh-mcp.ps1'
$skillSource = Join-Path $packageRoot 'skills\vehicle-door-cae'

if ([string]::IsNullOrWhiteSpace($StateDirectory)) {
    $StateDirectory = Join-Path $packageRoot '.local'
}
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = [Environment]::GetEnvironmentVariable('CODEX_HOME', 'Process')
}
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Join-Path $env:USERPROFILE '.codex'
}
$CodexHome = [System.IO.Path]::GetFullPath($CodexHome)
if ([string]::IsNullOrWhiteSpace($RunsDirectory)) {
    $localAppData = [Environment]::GetEnvironmentVariable('LOCALAPPDATA', 'Process')
    if ([string]::IsNullOrWhiteSpace($localAppData)) {
        $localAppData = Join-Path $env:USERPROFILE 'AppData\Local'
    }
    $RunsDirectory = Join-Path $localAppData 'HyperMeshCAEAgent\runs'
}

$guiExe = Resolve-OptionalExecutable -Value $HyperMeshGuiExe -Label 'HyperMesh GUI executable'
$batchExe = Resolve-OptionalExecutable -Value $HyperMeshBatchExe -Label 'HyperMesh batch executable'
$nastranTemplate = Resolve-OptionalDirectory -Value $NastranTemplateDir -Label 'Nastran template directory'
if ($null -eq $guiExe -and $null -eq $batchExe) {
    throw 'Provide at least one local HyperMesh executable with -HyperMeshGuiExe or -HyperMeshBatchExe.'
}

$python = Resolve-PythonExecutable -Value $PythonExecutable
$venvDirectory = Join-Path $packageRoot '.venv'
$venvPython = Join-Path $venvDirectory 'Scripts\python.exe'
if (-not $SkipDependencyInstall) {
    & $python -m venv $venvDirectory
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
        throw "Unable to create the package Python environment: $venvDirectory"
    }
    & $venvPython -m pip install -r $requirementsPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to install the package Python requirements.'
    }
}

if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
    throw "Package Python environment is missing: $venvPython. Run without -SkipDependencyInstall first."
}
$runtimePython = (Resolve-Path -LiteralPath $venvPython).Path

$statePath = [System.IO.Path]::GetFullPath($StateDirectory)
$runsPath = [System.IO.Path]::GetFullPath($RunsDirectory)
New-Item -ItemType Directory -Path $statePath -Force | Out-Null
$workstationConfigPath = Join-Path $statePath 'workstation.json'
$workstationConfig = [ordered]@{
    schema_version = 1
    package_root = $packageRoot
    python_executable = $runtimePython
    hypermesh_gui_exe = $guiExe
    hypermesh_batch_exe = $batchExe
    nastran_template_dir = $nastranTemplate
    runs_directory = $runsPath
    created_utc = [DateTime]::UtcNow.ToString('o')
}
$workstationConfig | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $workstationConfigPath -Encoding utf8

$shouldInstallSkill = -not $SkipSkillInstall
if ($shouldInstallSkill) {
    $skillDestination = Join-Path $CodexHome 'skills\vehicle-door-cae'
    if (Test-Path -LiteralPath $skillDestination) {
        if (-not $Force) {
            throw "Codex Skill destination already exists: $skillDestination. Re-run with -Force after reviewing it."
        }
        if (-not (Test-HyperMeshCaeAgentSkillDirectory -SkillDirectory $skillDestination)) {
            throw "Codex Skill destination is not a verifiable HyperMesh CAE Agent Skill and will not be replaced: $skillDestination"
        }
    }
}
else {
    $skillDestination = $null
}

$snippetPath = Join-Path $statePath 'codex-mcp-snippet.toml'
$snippetArgs = @(
    '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass',
    '-File', $snippetScript,
    '-PythonExecutable', $runtimePython,
    '-HyperMeshGuiExe', $guiExe,
    '-RunsDirectory', $runsPath,
    '-StateDirectory', $statePath,
    '-AsJson'
)
if ($null -ne $batchExe) {
    $snippetArgs += @('-HyperMeshBatchExe', $batchExe)
}
if ($null -ne $nastranTemplate) {
    $snippetArgs += @('-NastranTemplateDir', $nastranTemplate)
}
$snippetResultJson = & powershell.exe @snippetArgs
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to generate the Codex MCP registration snippet.'
}
$snippetResult = $snippetResultJson | ConvertFrom-Json
$snippetResult.toml_snippet | Set-Content -LiteralPath $snippetPath -Encoding utf8

$preflightArgs = @(
    '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass',
    '-File', $checkScript,
    '-StateDirectory', $statePath,
    '-AsJson'
)
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    $preflightOutput = @(& powershell.exe @preflightArgs 2>&1)
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}
if ($LASTEXITCODE -ne 0) {
    $preflightText = ($preflightOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($preflightText)) {
        $preflightText = '<no preflight output was captured>'
    }
    throw "Installation completed but the preflight failed. No Codex registration was changed.`nPreflight diagnostics:`n$preflightText"
}

if ($shouldInstallSkill) {
    # Complete the local Skill install before changing Codex MCP registrations.
    # A failed copy or ownership check must never leave a migrated MCP behind.
    New-Item -ItemType Directory -Path (Split-Path -Parent $skillDestination) -Force | Out-Null
    if (-not (Test-Path -LiteralPath $skillDestination)) {
        Copy-Item -LiteralPath $skillSource -Destination $skillDestination -Recurse -Force
    }
    else {
        foreach ($sourceItem in @(Get-ChildItem -LiteralPath $skillSource -Force)) {
            Copy-Item -LiteralPath $sourceItem.FullName -Destination $skillDestination -Recurse -Force
        }
    }
    if (-not (Test-HyperMeshCaeAgentSkillDirectory -SkillDirectory $skillDestination)) {
        throw "Codex Skill installation did not produce a verifiable HyperMesh CAE Agent Skill: $skillDestination"
    }
}

$mcpRegistration = 'skipped'
if (-not $SkipMcpRegistration) {
    if ([string]::IsNullOrWhiteSpace($CodexExecutable)) {
        $codexCommand = Get-Command codex -ErrorAction SilentlyContinue
        $CodexExecutable = if ($null -eq $codexCommand) { $null } else { $codexCommand.Source }
    }
    else {
        $CodexExecutable = Resolve-OptionalExecutable -Value $CodexExecutable -Label 'Codex executable'
    }
    if ([string]::IsNullOrWhiteSpace($CodexExecutable)) {
        throw 'Codex CLI was not found. Install Codex or rerun with -SkipMcpRegistration and paste the generated snippet manually.'
    }

    $serverName = 'hypermesh-cae-agent'
    $legacyServerNames = @('hypermesh-mcp-server')
    $normalizedLauncher = ConvertTo-NormalizedPath -Value $launcher
    $previousCodexHome = [Environment]::GetEnvironmentVariable('CODEX_HOME', 'Process')
    [Environment]::SetEnvironmentVariable('CODEX_HOME', $CodexHome, 'Process')
    try {
        $registrations = Get-CodexMcpList -Executable $CodexExecutable
        $canonicalEntries = @($registrations | Where-Object { $_.name -eq $serverName })
        if ($canonicalEntries.Count -gt 1) {
            throw "Codex has multiple registrations named '$serverName'; resolve them manually before installation."
        }
        if ($canonicalEntries.Count -eq 1 -and -not (Test-HyperMeshCaeAgentPackageRegistration -Registration $canonicalEntries[0])) {
            throw "Codex MCP '$serverName' is not a verifiable HyperMesh CAE Agent package registration and will not be replaced."
        }

        $legacyEntries = @($registrations | Where-Object { $legacyServerNames -contains $_.name })
        $unverifiedLegacyEntries = @(
            $legacyEntries |
                Where-Object { -not (Test-HyperMeshCaeAgentPackageRegistration -Registration $_) }
        )
        if ($unverifiedLegacyEntries.Count -gt 0) {
            $unverifiedNames = ($unverifiedLegacyEntries | ForEach-Object { $_.name } | Sort-Object -Unique) -join ', '
            throw "Legacy MCP registration(s) cannot be proven to belong to this package: $unverifiedNames. Remove or repair them manually before installation; no registration was changed."
        }
        $unknownPackageEntries = @(
            $registrations |
                Where-Object { Test-HyperMeshCaeAgentPackageRegistration -Registration $_ } |
                Where-Object { $_.name -ne $serverName -and $legacyServerNames -notcontains $_.name }
        )
        if ($unknownPackageEntries.Count -gt 0) {
            $unknownNames = ($unknownPackageEntries | ForEach-Object { $_.name }) -join ', '
            throw "Package launcher is registered under unknown MCP name(s): $unknownNames. Resolve them manually before installation."
        }

        $managedEntries = @()
        if ($canonicalEntries.Count -eq 1) {
            $managedEntries += $canonicalEntries
        }
        $managedEntries += $legacyEntries
        if ($managedEntries.Count -gt 0 -and -not $Force) {
            $existingNames = ($managedEntries | ForEach-Object { $_.name }) -join ', '
            throw "Package MCP registration(s) already exist: $existingNames. Re-run with -Force to migrate them to '$serverName'."
        }
        $managedEntrySnapshots = @()
        foreach ($entry in $managedEntries) {
            $snapshot = Get-CodexMcpRegistration -Executable $CodexExecutable -Name ([string]$entry.name)
            if (-not (Test-HyperMeshCaeAgentPackageRegistration -Registration $snapshot)) {
                throw "Codex MCP '$($entry.name)' changed or cannot be verified as a HyperMesh CAE Agent package registration."
            }
            Get-RestorableStdioTransport -Registration $snapshot | Out-Null
            $managedEntrySnapshots += $snapshot
        }
        $managedEntries = $managedEntrySnapshots

        $removedEntries = [System.Collections.Generic.List[object]]::new()
        $replacementAttempted = $false
        $replacementSnapshot = $null
        try {
            foreach ($entry in $managedEntries) {
                $currentEntry = Get-CodexMcpRegistration -Executable $CodexExecutable -Name ([string]$entry.name)
                if (-not (Test-HyperMeshCaeAgentPackageRegistration -Registration $currentEntry) -or
                    -not (Test-CodexMcpRegistrationSnapshot -Expected $entry -Actual $currentEntry)) {
                    throw "Codex MCP '$($entry.name)' changed after verification and will not be removed automatically."
                }
                $removedEntries.Add($entry)
                & $CodexExecutable mcp remove $entry.name
                if ($LASTEXITCODE -ne 0) {
                    throw "Unable to remove the existing Codex MCP registration '$($entry.name)'."
                }
            }

            $registrationArgs = @('mcp', 'add', $serverName, '--env', "PYTHON_EXECUTABLE=$runtimePython")
            if ($null -ne $guiExe) {
                $registrationArgs += @('--env', "HYPERMESH_GUI_EXE=$guiExe")
            }
            if ($null -ne $batchExe) {
                $registrationArgs += @('--env', "HYPERMESH_BATCH_EXE=$batchExe")
            }
            if ($null -ne $nastranTemplate) {
                $registrationArgs += @('--env', "HYPERMESH_NASTRAN_TEMPLATE_DIR=$nastranTemplate")
            }
            $registrationArgs += @('--env', "HYPERMESH_CAE_AGENT_RUNS_DIR=$runsPath")
            $registrationArgs += @('--', 'powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $launcher)
            $replacementAttempted = $true
            & $CodexExecutable @registrationArgs
            if ($LASTEXITCODE -ne 0) {
                throw "Unable to register Codex MCP '$serverName'. Use the generated snippet instead: $snippetPath"
            }

            $finalRegistrations = Get-CodexMcpList -Executable $CodexExecutable
            $finalCanonicalEntries = @($finalRegistrations | Where-Object { $_.name -eq $serverName })
            $finalLegacyEntries = @($finalRegistrations | Where-Object { $legacyServerNames -contains $_.name })
            if ($finalCanonicalEntries.Count -eq 1) {
                $replacementSnapshot = Get-CodexMcpRegistration -Executable $CodexExecutable -Name $serverName
            }
            if ($finalCanonicalEntries.Count -ne 1 -or
                $null -eq $replacementSnapshot -or
                -not (Test-PackageMcpRegistration -Registration $replacementSnapshot -NormalizedLauncher $normalizedLauncher) -or
                $finalLegacyEntries.Count -ne 0) {
                throw "Codex registration verification failed: expected one '$serverName' registration for this package launcher and no legacy registration."
            }
        }
        catch {
            $migrationError = $_.Exception.Message
            $rollbackErrors = [System.Collections.Generic.List[string]]::new()
            if ($replacementAttempted) {
                try {
                    $rollbackRegistrations = Get-CodexMcpList -Executable $CodexExecutable
                    $replacementEntries = @($rollbackRegistrations | Where-Object { $_.name -eq $serverName })
                    if ($replacementEntries.Count -gt 1) {
                        throw "Refusing to remove multiple unexpected '$serverName' registrations during rollback."
                    }
                    if ($replacementEntries.Count -eq 1) {
                        $currentReplacement = Get-CodexMcpRegistration -Executable $CodexExecutable -Name $serverName
                        $safeToRemove = if ($null -ne $replacementSnapshot) {
                            Test-CodexMcpRegistrationSnapshot -Expected $replacementSnapshot -Actual $currentReplacement
                        }
                        else {
                            Test-PackageMcpRegistration -Registration $currentReplacement -NormalizedLauncher $normalizedLauncher
                        }
                        if (-not $safeToRemove) {
                            throw "Refusing to remove '$serverName' during rollback because its registration changed or is not the expected package launcher."
                        }
                        & $CodexExecutable mcp remove $serverName
                        if ($LASTEXITCODE -ne 0) {
                            throw "Unable to remove incomplete replacement registration '$serverName'."
                        }
                    }
                }
                catch {
                    $rollbackErrors.Add($_.Exception.Message)
                }
            }

            foreach ($entry in $removedEntries) {
                try {
                    $currentRegistrations = Get-CodexMcpList -Executable $CodexExecutable
                    $sameNameEntries = @($currentRegistrations | Where-Object { $_.name -eq $entry.name })
                    if ($sameNameEntries.Count -eq 0) {
                        Restore-CodexMcpRegistration -Executable $CodexExecutable -Registration $entry
                    }
                    elseif ($sameNameEntries.Count -eq 1) {
                        $currentEntry = Get-CodexMcpRegistration -Executable $CodexExecutable -Name ([string]$entry.name)
                        if (-not (Test-CodexMcpRegistrationSnapshot -Expected $entry -Actual $currentEntry)) {
                            throw "Refusing to treat Codex MCP '$($entry.name)' as restored because another registration with the same name has changed."
                        }
                    }
                    else {
                        throw "Refusing to restore Codex MCP '$($entry.name)' because multiple same-name registrations exist."
                    }
                }
                catch {
                    $rollbackErrors.Add("$($entry.name): $($_.Exception.Message)")
                }
            }

            if ($rollbackErrors.Count -gt 0) {
                throw "Codex MCP migration failed: $migrationError Automatic rollback was incomplete: $($rollbackErrors -join ' | '). Previous registration name(s): $(($removedEntries | ForEach-Object { $_.name }) -join ', ')."
            }
            throw "Codex MCP migration failed: $migrationError Previous package registration(s) were restored."
        }
        $mcpRegistration = if ($managedEntries.Count -gt 0) { 'migrated' } else { 'registered' }
    }
    finally {
        [Environment]::SetEnvironmentVariable('CODEX_HOME', $previousCodexHome, 'Process')
    }
}

$result = [ordered]@{
    success = $true
    package_root = $packageRoot
    workstation_config = $workstationConfigPath
    codex_mcp_snippet = $snippetPath
    codex_skill_destination = $skillDestination
    mcp_registration = $mcpRegistration
    python_executable = $runtimePython
    hypermesh_gui_exe = $guiExe
    hypermesh_batch_exe = $batchExe
    nastran_template_dir = $nastranTemplate
    next_action = if ($mcpRegistration -in @('registered', 'migrated')) {
        'Restart Codex or open a new task, then run the read-only smoke test from README.md.'
    }
    else {
        'Paste the generated TOML snippet into the target computer Codex config, restart Codex, then run the read-only smoke test from README.md.'
    }
}
$result | ConvertTo-Json -Depth 4
