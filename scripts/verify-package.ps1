[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackageRoot,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module Microsoft.PowerShell.Utility -ErrorAction Stop

function Test-IsRootGitMetadataRelativePath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $normalized = $RelativePath.Replace('/', '\').TrimStart('\', '/')
    return $normalized -match '^(?i:\.git)(?:\\|$)' -or $normalized -ieq '.gitattributes'
}

function Test-ForbiddenRelativePath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $normalized = $RelativePath.Replace('/', '\')
    $lower = $normalized.ToLowerInvariant()
    $leaf = [System.IO.Path]::GetFileName($normalized)

    if ($lower -eq 'backend\hypermesh-runtime\nastran_property_contract.py') {
        return 'retired-nastran-property-contract'
    }
    if ($lower -eq '.mcp.json') {
        return 'duplicate-mcp-registration'
    }
    if ($lower -match '(^|\\)(\.git|\.worktrees|\.test-tmp|release|__pycache__|runs|wheels)(\\|$)') {
        return 'generated-directory'
    }
    if ($lower -match '(^|\\)(docs|templates)(\\|$)') {
        return 'non-runtime-directory'
    }
    if ($lower -match '(^|\\)tcl(\\|$)' -and $lower -ne 'tcl\visualization\apply-functional-palette.tcl') {
        return 'non-runtime-tcl'
    }
    if ($leaf -ieq 'install.md' -or $leaf -like 'test_*.py' -or $leaf -like 'test-*.ps1') {
        return 'non-runtime-file'
    }
    if ($lower -match '\.(hm|h3d|fem|nas|op2|odb|log|jsonl|pyc|whl|docx)$') {
        return 'generated-or-bundled-artifact'
    }
    return $null
}

function Test-AllowedRelativePath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $normalized = $RelativePath.Replace('/', '\').ToLowerInvariant()
    $staticPaths = @(
        '.codex-plugin\plugin.json',
        'readme.md',
        'architecture.md',
        'requirements.txt',
        'release-manifest.json',
        'scripts\install-local.ps1',
        'scripts\check-environment.ps1',
        'scripts\start-hypermesh-mcp.ps1',
        'scripts\create-codex-mcp-snippet.ps1',
        'scripts\verify-package.ps1',
        'backend\hypermesh-runtime\hypermesh_mcp_server.py',
        'backend\hypermesh-runtime\connector_review_panel.tcl',
        'backend\knowledge_runtime\__init__.py',
        'backend\knowledge_runtime\router.py',
        'backend\knowledge_runtime\store.py',
        'knowledge\manifest.json',
        'skills\vehicle-door-cae\skill.md',
        'skills\vehicle-door-cae\references\baobian-board-interface-guide.md',
        'skills\vehicle-door-cae\references\baobian-interface-node-merge-guide.md',
        'skills\vehicle-door-cae\references\component-visual-palette.md',
        'skills\vehicle-door-cae\references\connector-reference-components-and-file-lifecycle.md',
        'skills\vehicle-door-cae\references\hypermesh17-constraints.md',
        'skills\vehicle-door-cae\references\rbe2-review-lessons.md',
        'skills\vehicle-door-cae\references\vehicle-door-full-workflow.md',
        'skills\vehicle-door-cae\references\workflow-contract.md',
        'tcl\visualization\apply-functional-palette.tcl'
    )
    if ($staticPaths -contains $normalized) {
        return $true
    }
    if ($normalized -match '^knowledge\\(procedures|rules|cases|sources)\\.+\.json$') {
        return $true
    }
    return $false
}

function Get-PortableTextViolation {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    if ($File.Extension -notin @('.ps1', '.py', '.json', '.md', '.tcl', '.tbc')) {
        return $null
    }
    $content = [System.IO.File]::ReadAllText($File.FullName)
    if ($File.Name -ieq 'hypermesh_mcp_server.py' -and $content -match '(?im)^\s*(?:from|import)\s+nastran_property_contract\b') {
        return 'retired-nastran-property-contract-reference'
    }
    if ($content -match '(?i)(?:[a-z]:[\\/](?:asyt|users|documents and settings|desktop|temp|tmp)[\\/]|/(?:home|users|tmp)/)') {
        return 'source-machine-path'
    }
    return $null
}

try {
    $root = (Resolve-Path -LiteralPath $PackageRoot -ErrorAction Stop).Path
    $requiredFiles = @(
        '.codex-plugin\plugin.json',
        'README.md',
        'ARCHITECTURE.md',
        'requirements.txt',
        'scripts\install-local.ps1',
        'scripts\check-environment.ps1',
        'scripts\start-hypermesh-mcp.ps1',
        'scripts\create-codex-mcp-snippet.ps1',
        'scripts\verify-package.ps1',
        'backend\hypermesh-runtime\hypermesh_mcp_server.py',
        'backend\hypermesh-runtime\connector_review_panel.tcl',
        'backend\knowledge_runtime\__init__.py',
        'backend\knowledge_runtime\router.py',
        'backend\knowledge_runtime\store.py',
        'knowledge\manifest.json',
        'knowledge\rules\node_merge_tolerance.json',
        'knowledge\procedures\vehicle_door_full_preprocess_workflow.json',
        'knowledge\cases\baobian_combine_split_pattern.json',
        'knowledge\sources\baobian-neiban-waiban-interface-guide.json',
        'skills\vehicle-door-cae\SKILL.md',
        'skills\vehicle-door-cae\references\baobian-board-interface-guide.md',
        'skills\vehicle-door-cae\references\baobian-interface-node-merge-guide.md',
        'skills\vehicle-door-cae\references\component-visual-palette.md',
        'skills\vehicle-door-cae\references\connector-reference-components-and-file-lifecycle.md',
        'skills\vehicle-door-cae\references\hypermesh17-constraints.md',
        'skills\vehicle-door-cae\references\rbe2-review-lessons.md',
        'skills\vehicle-door-cae\references\vehicle-door-full-workflow.md',
        'skills\vehicle-door-cae\references\workflow-contract.md',
        'tcl\visualization\apply-functional-palette.tcl',
        'RELEASE-MANIFEST.json'
    )

    $missingFiles = @(
        foreach ($relativePath in $requiredFiles) {
            if (-not (Test-Path -LiteralPath (Join-Path $root $relativePath) -PathType Leaf)) {
                $relativePath
            }
        }
    )

    $knowledgeDirectoryErrors = @(
        foreach ($directoryName in @('procedures', 'rules', 'cases', 'sources')) {
            $directoryPath = Join-Path $root "knowledge\$directoryName"
            $cardCount = @(Get-ChildItem -LiteralPath $directoryPath -Recurse -Filter '*.json' -File -ErrorAction SilentlyContinue).Count
            if ($cardCount -eq 0) {
                "knowledge\$directoryName"
            }
        }
    )

    $violations = @()
    Get-ChildItem -LiteralPath $root -Recurse -Force -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($root.Length).TrimStart('\', '/')
        if (Test-IsRootGitMetadataRelativePath -RelativePath $relativePath) {
            return
        }
        $reason = Test-ForbiddenRelativePath -RelativePath $relativePath
        if ($null -eq $reason -and -not (Test-AllowedRelativePath -RelativePath $relativePath)) {
            $reason = 'outside-release-whitelist'
        }
        if ($null -eq $reason) {
            $reason = Get-PortableTextViolation -File $_
        }
        if ($null -ne $reason) {
            $violations += [ordered]@{
                path = $relativePath.Replace('\', '/')
                reason = $reason
            }
        }
    }

    $manifestError = $null
    $manifestFileErrors = @()
    $checksumErrors = @()
    $unexpectedFiles = @()
    $manifestPath = Join-Path $root 'RELEASE-MANIFEST.json'
    if ($missingFiles -notcontains 'RELEASE-MANIFEST.json') {
        try {
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop
            if ($manifest.schema_version -ne 1) {
                $manifestError = 'RELEASE-MANIFEST.json must declare schema_version 1.'
            }
            elseif ([string]::IsNullOrWhiteSpace([string]$manifest.package_name)) {
                $manifestError = 'RELEASE-MANIFEST.json must declare package_name.'
            }
            elseif ($null -eq $manifest.files -or @($manifest.files).Count -eq 0) {
                $manifestError = 'RELEASE-MANIFEST.json must declare a non-empty files array.'
            }
            else {
                $manifestPaths = @()
                foreach ($entry in @($manifest.files)) {
                    $entryPath = [string]$entry.path
                    $entryHash = [string]$entry.sha256
                    if ([string]::IsNullOrWhiteSpace($entryPath) -or $entryPath -eq 'RELEASE-MANIFEST.json') {
                        $manifestFileErrors += "invalid manifest file path: $entryPath"
                        continue
                    }
                    if (Test-IsRootGitMetadataRelativePath -RelativePath $entryPath) {
                        $manifestFileErrors += "reserved Git metadata path: $entryPath"
                        continue
                    }
                    if ($entryPath -match '(^|[\\/])\.\.([\\/]|$)' -or $entryPath.StartsWith('\') -or $entryPath.StartsWith('/')) {
                        $manifestFileErrors += "unsafe manifest file path: $entryPath"
                        continue
                    }
                    if ($entryHash -notmatch '^[A-Fa-f0-9]{64}$') {
                        $manifestFileErrors += "invalid SHA-256 for: $entryPath"
                        continue
                    }
                    $normalizedPath = $entryPath.Replace('\', '/').TrimStart('/')
                    if ($manifestPaths -contains $normalizedPath) {
                        $manifestFileErrors += "duplicate manifest file path: $normalizedPath"
                        continue
                    }
                    $manifestPaths += $normalizedPath
                }

                $actualFiles = @(
                    Get-ChildItem -LiteralPath $root -Recurse -Force -File |
                        ForEach-Object { $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/') } |
                        Where-Object {
                            $_ -ne 'RELEASE-MANIFEST.json' -and
                            -not (Test-IsRootGitMetadataRelativePath -RelativePath $_)
                        }
                )
                foreach ($actualPath in $actualFiles) {
                    if ($manifestPaths -notcontains $actualPath) {
                        $unexpectedFiles += $actualPath
                    }
                }
                foreach ($expectedPath in $manifestPaths) {
                    $expectedFile = Join-Path $root $expectedPath.Replace('/', '\')
                    if (-not (Test-Path -LiteralPath $expectedFile -PathType Leaf)) {
                        $manifestFileErrors += "manifest file is missing: $expectedPath"
                        continue
                    }
                    $actualHash = (Get-FileHash -LiteralPath $expectedFile -Algorithm SHA256).Hash
                    $manifestEntry = @($manifest.files | Where-Object { ([string]$_.path).Replace('\', '/').TrimStart('/') -eq $expectedPath })[0]
                    if (-not $actualHash.Equals(([string]$manifestEntry.sha256), [System.StringComparison]::OrdinalIgnoreCase)) {
                        $checksumErrors += $expectedPath
                    }
                }
                if ([int]$manifest.file_count -ne ($manifestPaths.Count + 1)) {
                    $manifestFileErrors += 'manifest file_count does not match files plus RELEASE-MANIFEST.json.'
                }
            }
        }
        catch {
            $manifestError = "Invalid RELEASE-MANIFEST.json: $($_.Exception.Message)"
        }
    }

    $result = [ordered]@{
        package_root = $root
        required_file_count = $requiredFiles.Count
        missing_files = $missingFiles
        missing_knowledge_directories = $knowledgeDirectoryErrors
        forbidden_items = $violations
        manifest_error = $manifestError
        manifest_file_errors = $manifestFileErrors
        checksum_errors = $checksumErrors
        unexpected_files = $unexpectedFiles
        ready = $missingFiles.Count -eq 0 -and $knowledgeDirectoryErrors.Count -eq 0 -and $violations.Count -eq 0 -and $null -eq $manifestError -and $manifestFileErrors.Count -eq 0 -and $checksumErrors.Count -eq 0 -and $unexpectedFiles.Count -eq 0
    }

    if ($AsJson) {
        $result | ConvertTo-Json -Depth 6
    }
    elseif ($result.ready) {
        Write-Output "Portable package verified: $root"
    }
    else {
        $result | ConvertTo-Json -Depth 6
    }

    if (-not $result.ready) {
        exit 1
    }
}
catch {
    Write-Error $_
    exit 1
}
