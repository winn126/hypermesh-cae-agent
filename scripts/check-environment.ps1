[CmdletBinding()]
param(
    [switch]$AsJson,
    [switch]$RequireBatch,
    [string]$StateDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ConfigValue {
    param(
        $Config,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($null -eq $Config) {
        return $null
    }
    $property = $Config.PSObject.Properties[$Name]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        return $null
    }
    return [string]$property.Value
}

function Read-WorkstationConfig {
    param([Parameter(Mandatory = $true)][string]$Directory)

    $path = Join-Path $Directory 'workstation.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return [ordered]@{ path = $path; value = $null; error = $null }
    }
    try {
        return [ordered]@{
            path = $path
            value = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop
            error = $null
        }
    }
    catch {
        return [ordered]@{ path = $path; value = $null; error = $_.Exception.Message }
    }
}

function Find-FirstExistingFile {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}

function Find-FirstExistingDirectory {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}

function Test-DirectoryWritable {
    param([Parameter(Mandatory = $true)][string]$Directory)

    try {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        $probe = Join-Path $Directory ('.write-probe-' + [guid]::NewGuid().ToString('N'))
        [System.IO.File]::WriteAllText($probe, 'ok')
        Remove-Item -LiteralPath $probe -Force
        return $true
    }
    catch {
        return $false
    }
}

$pluginRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backendRoot = Join-Path $pluginRoot 'backend\hypermesh-runtime'
$serverScript = Join-Path $backendRoot 'hypermesh_mcp_server.py'
$requirements = Join-Path $pluginRoot 'requirements.txt'
$knowledgeRoot = Join-Path $pluginRoot 'knowledge'
if ([string]::IsNullOrWhiteSpace($StateDirectory)) {
    $StateDirectory = Join-Path $pluginRoot '.local'
}
$statePath = [System.IO.Path]::GetFullPath($StateDirectory)
$configResult = Read-WorkstationConfig -Directory $statePath
$workstation = $configResult.value

$venvPython = Join-Path $pluginRoot '.venv\Scripts\python.exe'
$pythonRequested = if (Test-Path -LiteralPath $venvPython -PathType Leaf) {
    (Resolve-Path -LiteralPath $venvPython).Path
}
else {
    $null
}
$pythonPath = $pythonRequested
$pythonVersion = $null
$pythonVersionSupported = $false
if ($pythonPath) {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $pythonVersionParts = @(& $pythonPath -c 'import sys; print(sys.version_info[0]); print(sys.version_info[1]); print(sys.version_info[2])' 2>&1)
        if ($LASTEXITCODE -eq 0 -and $pythonVersionParts.Count -ge 2) {
            $major = [int]([string]$pythonVersionParts[0]).Trim()
            $minor = [int]([string]$pythonVersionParts[1]).Trim()
            $micro = if ($pythonVersionParts.Count -ge 3) { [int]([string]$pythonVersionParts[2]).Trim() } else { 0 }
            $pythonVersion = "$major.$minor.$micro"
            $pythonVersionSupported = $major -gt 3 -or ($major -eq 3 -and $minor -ge 10)
        }
    }
    catch {
        $pythonVersion = $null
        $pythonVersionSupported = $false
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

$batchEnvironment = [Environment]::GetEnvironmentVariable('HYPERMESH_BATCH_EXE', 'Process')
$guiEnvironment = [Environment]::GetEnvironmentVariable('HYPERMESH_GUI_EXE', 'Process')
$batchConfiguredPath = Get-ConfigValue -Config $workstation -Name 'hypermesh_batch_exe'
$guiConfiguredPath = Get-ConfigValue -Config $workstation -Name 'hypermesh_gui_exe'
$nastranTemplateConfiguredPath = Get-ConfigValue -Config $workstation -Name 'nastran_template_dir'
$nastranTemplateEnvironmentPath = [Environment]::GetEnvironmentVariable('HYPERMESH_NASTRAN_TEMPLATE_DIR', 'Process')
$batchExe = Find-FirstExistingFile @(
    $batchConfiguredPath,
    $batchEnvironment,
    'C:\Program Files\Altair\2017\hm\bin\win64\hmbatch.exe',
    'C:\Program Files\Altair\2020\hwdesktop\hm\bin\win64\hmbatch.exe',
    'C:\Program Files\Altair\2020\hwdesktop\hw\bin\win64\hmbatch.exe'
)
$guiExe = Find-FirstExistingFile @(
    $guiConfiguredPath,
    $guiEnvironment,
    'C:\Program Files\Altair\2017\hw\bin\win64\hw.exe',
    'C:\Program Files\Altair\2020\hwdesktop\hw\bin\win64\hw.exe'
)
$nastranTemplateDir = Find-FirstExistingDirectory @(
    $nastranTemplateConfiguredPath,
    $nastranTemplateEnvironmentPath
)

$mcpRuntime = $false
$mcpVersion = $null
$mcpProbeError = $null
$mcpServerImport = $false
$mcpServerWarningFree = $false
$mcpServerImportError = $null
if ($pythonPath) {
    Push-Location $pluginRoot
    try {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $mcpProbeOutput = @(& $pythonPath -c 'import importlib.metadata; import mcp; import backend.knowledge_runtime.router; print(importlib.metadata.version(mcp.__name__))' 2>&1)
            $mcpRuntime = $LASTEXITCODE -eq 0
            if ($mcpRuntime) {
                $mcpVersion = $mcpProbeOutput | ForEach-Object { [string]$_ } | Select-Object -Last 1
            }
            else {
                $mcpProbeError = ($mcpProbeOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
            }
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
        if ($mcpRuntime -and (Test-Path -LiteralPath $serverScript -PathType Leaf)) {
            $previousErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $serverProbeOutput = @(& $pythonPath -B -W error $serverScript --help 2>&1)
                $mcpServerImport = $LASTEXITCODE -eq 0
                $mcpServerWarningFree = $mcpServerImport
                if (-not $mcpServerImport) {
                    $mcpServerImportError = ($serverProbeOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
                }
            }
            finally {
                $ErrorActionPreference = $previousErrorActionPreference
            }
        }
    }
    finally {
        Pop-Location
    }
}
$mcpVersionMatches = $mcpRuntime -and ([string]$mcpVersion).Trim() -eq '1.27.1'

$assets = [ordered]@{
    mcp_server = Test-Path -LiteralPath $serverScript -PathType Leaf
    connector_review_panel = Test-Path -LiteralPath (Join-Path $backendRoot 'connector_review_panel.tcl') -PathType Leaf
}
$runsRequested = [Environment]::GetEnvironmentVariable('HYPERMESH_CAE_AGENT_RUNS_DIR', 'Process')
$configuredRunsDirectory = Get-ConfigValue -Config $workstation -Name 'runs_directory'
if (-not [string]::IsNullOrWhiteSpace($configuredRunsDirectory)) {
    $runsRequested = $configuredRunsDirectory
}
if ([string]::IsNullOrWhiteSpace($runsRequested)) {
    $localAppData = [Environment]::GetEnvironmentVariable('LOCALAPPDATA', 'Process')
    if ([string]::IsNullOrWhiteSpace($localAppData)) {
        $localAppData = Join-Path $env:USERPROFILE 'AppData\Local'
    }
    $runsRequested = Join-Path $localAppData 'HyperMeshCAEAgent\runs'
}
$runsDirectory = [System.IO.Path]::GetFullPath($runsRequested)
$checks = [ordered]@{
    backend_directory = Test-Path -LiteralPath $backendRoot -PathType Container
    requirements = Test-Path -LiteralPath $requirements -PathType Leaf
    knowledge_root = Test-Path -LiteralPath $knowledgeRoot -PathType Container
    workstation_config_valid = $null -eq $configResult.error
    python = $null -ne $pythonPath
    python_version = $pythonVersionSupported
    mcp_runtime = $mcpRuntime
    mcp_version = $mcpVersionMatches
    mcp_server_import = $mcpServerImport
    mcp_server_warning_free = $mcpServerWarningFree
    gui_exe = $null -ne $guiExe
    batch_exe = $null -ne $batchExe
    nastran_template_dir = $null -ne $nastranTemplateDir
    runs_directory_writable = Test-DirectoryWritable -Directory $runsDirectory
}
foreach ($assetName in $assets.Keys) {
    $checks["asset_$assetName"] = [bool]$assets[$assetName]
}

$coreCheckNames = @(
    'backend_directory', 'requirements', 'knowledge_root', 'workstation_config_valid',
    'python', 'python_version', 'mcp_runtime', 'mcp_version', 'mcp_server_import', 'mcp_server_warning_free', 'runs_directory_writable'
) + @($assets.Keys | ForEach-Object { "asset_$_" })
$coreReady = -not (@($coreCheckNames | Where-Object { -not $checks[$_] }).Count -gt 0)
$availableModes = @()
if ($checks.batch_exe) { $availableModes += 'batch' }
if ($checks.gui_exe) { $availableModes += 'visible_gui' }
$ready = $coreReady -and $availableModes.Count -gt 0
if ($RequireBatch) {
    $ready = $coreReady -and $checks.batch_exe
}

$result = [ordered]@{
    plugin_root = $pluginRoot
    state_directory = $statePath
    workstation_config = $configResult.path
    workstation_config_error = $configResult.error
    python = $pythonPath
    python_requested = $pythonRequested
    python_version = $pythonVersion
    mcp_version = if ($mcpRuntime) { ([string]$mcpVersion).Trim() } else { $null }
    mcp_probe_error = $mcpProbeError
    mcp_server_import_error = $mcpServerImportError
    required_mcp_version = '1.27.1'
    hypermesh_batch_exe = $batchExe
    hypermesh_gui_exe = $guiExe
    nastran_template_dir = $nastranTemplateDir
    supported_modes = @('batch', 'visible_gui')
    available_modes = $availableModes
    runs_directory = $runsDirectory
    checks = $checks
    ready = $ready
    ok = $ready
    next_action = if ($ready) {
        'Start the MCP server, source the generated GUI listener Tcl in HyperMesh, then perform a read-only connection check.'
    }
    elseif (-not $checks.python) {
        'Install Python 3.10 or newer and rerun scripts/install-local.ps1.'
    }
    elseif (-not $checks.mcp_runtime -or -not $checks.mcp_version) {
        'Run scripts/install-local.ps1 without -SkipDependencyInstall to create .venv and install mcp==1.27.1.'
    }
    elseif (-not $checks.gui_exe -and -not $checks.batch_exe) {
        'Run scripts/install-local.ps1 with at least one valid HyperMesh executable path.'
    }
    else {
        'Fix the failed checks and rerun this preflight before starting the MCP server.'
    }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 6
}
else {
    $result | ConvertTo-Json -Depth 6
}
if (-not $ready) {
    exit 1
}
