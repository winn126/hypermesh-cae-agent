[CmdletBinding()]
param(
    [string]$StateDirectory,
    [switch]$PreflightOnly
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

$pluginRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backendRoot = Join-Path $pluginRoot 'backend\hypermesh-runtime'
$serverScript = Join-Path $backendRoot 'hypermesh_mcp_server.py'
$checkScript = Join-Path $PSScriptRoot 'check-environment.ps1'
if ([string]::IsNullOrWhiteSpace($StateDirectory)) {
    $StateDirectory = Join-Path $pluginRoot '.local'
}
$statePath = [System.IO.Path]::GetFullPath($StateDirectory)
$configPath = Join-Path $statePath 'workstation.json'
$workstation = $null
if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    $workstation = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json -ErrorAction Stop
}

$venvPython = Join-Path $pluginRoot '.venv\Scripts\python.exe'
if (Test-Path -LiteralPath $venvPython -PathType Leaf) {
    $env:PYTHON_EXECUTABLE = (Resolve-Path -LiteralPath $venvPython).Path
}
$configuredGui = Get-ConfigValue -Config $workstation -Name 'hypermesh_gui_exe'
if (-not [string]::IsNullOrWhiteSpace($configuredGui)) {
    $env:HYPERMESH_GUI_EXE = $configuredGui
}
$configuredBatch = Get-ConfigValue -Config $workstation -Name 'hypermesh_batch_exe'
if (-not [string]::IsNullOrWhiteSpace($configuredBatch)) {
    $env:HYPERMESH_BATCH_EXE = $configuredBatch
}
$configuredRuns = Get-ConfigValue -Config $workstation -Name 'runs_directory'
if (-not [string]::IsNullOrWhiteSpace($configuredRuns)) {
    $env:HYPERMESH_CAE_AGENT_RUNS_DIR = $configuredRuns
}
$configuredNastranTemplate = Get-ConfigValue -Config $workstation -Name 'nastran_template_dir'
if (-not [string]::IsNullOrWhiteSpace($configuredNastranTemplate)) {
    $env:HYPERMESH_NASTRAN_TEMPLATE_DIR = $configuredNastranTemplate
}

Set-Location -LiteralPath $pluginRoot
$preflightArguments = @(
    '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass',
    '-File', $checkScript,
    '-StateDirectory', $statePath,
    '-AsJson'
)
& powershell.exe @preflightArguments *> $null
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine('HyperMesh CAE Agent environment check failed. Run scripts/check-environment.ps1 -AsJson for details.')
    exit 1
}
if ($PreflightOnly) {
    Write-Output 'HyperMesh CAE Agent preflight passed.'
    exit 0
}

if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
    [Console]::Error.WriteLine('Package .venv is missing. Run scripts/install-local.ps1 before starting the MCP server.')
    exit 1
}
$python = (Resolve-Path -LiteralPath $venvPython).Path
& $python -u $serverScript
exit $LASTEXITCODE
