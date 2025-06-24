# Roslyn MCP Server Setup Script
# This script helps set up the Roslyn MCP Server for Claude Desktop

param(
    [string]$ClaudeConfigPath = "",
    [switch]$SkipBuild,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Roslyn MCP Server Setup Script

Usage: .\setup.ps1 [options]

Options:
  -ClaudeConfigPath <path>   Specify custom path to Claude Desktop config file
  -SkipBuild                 Skip building the project
  -Help                      Show this help message

Examples:
  .\setup.ps1                                    # Auto-detect config path and build
  .\setup.ps1 -SkipBuild                        # Skip building step
  .\setup.ps1 -ClaudeConfigPath "C:\custom\config.json"  # Custom config path
"@
    exit 0
}

Write-Host "=== Roslyn MCP Server Setup ===" -ForegroundColor Cyan
Write-Host

# Get current directory
$currentDir = Get-Location
$projectPath = $currentDir.Path

Write-Host "Project location: $projectPath" -ForegroundColor Green
Write-Host

# Check .NET installation
Write-Host "1. Checking .NET installation..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "   ✓ .NET SDK found: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ .NET SDK not found. Please install .NET 8.0 SDK or later." -ForegroundColor Red
    exit 1
}

# Build project (unless skipped)
if (-not $SkipBuild) {
    Write-Host
    Write-Host "2. Building project..." -ForegroundColor Yellow
    
    Write-Host "   Restoring packages..."
    dotnet restore | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ✗ Failed to restore packages" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "   Building..."
    dotnet build -c Release | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ✗ Build failed" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "   ✓ Project built successfully" -ForegroundColor Green
}

# Determine Claude Desktop config path
Write-Host
Write-Host "3. Configuring Claude Desktop..." -ForegroundColor Yellow

if ($ClaudeConfigPath -eq "") {
    $ClaudeConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
}

Write-Host "   Config path: $ClaudeConfigPath"

# Create config directory if it doesn't exist
$configDir = Split-Path $ClaudeConfigPath -Parent
if (-not (Test-Path $configDir)) {
    Write-Host "   Creating config directory..."
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Prepare configuration
$config = @{
    mcpServers = @{
        "roslyn-code-navigator" = @{
            command = "dotnet"
            args = @("run", "--project", $projectPath)
            env = @{
                DOTNET_ENVIRONMENT = "Production"
                LOG_LEVEL = "Information"
            }
        }
    }
}

# Read existing config if it exists
$existingConfig = @{}
if (Test-Path $ClaudeConfigPath) {
    try {
        $existingConfig = Get-Content $ClaudeConfigPath | ConvertFrom-Json -AsHashtable
        Write-Host "   Found existing configuration"
    } catch {
        Write-Host "   ⚠ Could not parse existing config, creating new one" -ForegroundColor Yellow
    }
}

# Merge configurations
if ($existingConfig.ContainsKey('mcpServers')) {
    $existingConfig.mcpServers['roslyn-code-navigator'] = $config.mcpServers['roslyn-code-navigator']
} else {
    $existingConfig = $config
}

# Write configuration
try {
    $existingConfig | ConvertTo-Json -Depth 10 | Set-Content $ClaudeConfigPath -Encoding UTF8
    Write-Host "   ✓ Configuration written successfully" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to write configuration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test server startup
Write-Host
Write-Host "4. Testing server startup..." -ForegroundColor Yellow

$job = Start-Job -ScriptBlock { 
    Set-Location $using:projectPath
    dotnet run --no-build 
}

Start-Sleep -Seconds 3

if ($job.State -eq "Running") {
    Write-Host "   ✓ Server started successfully" -ForegroundColor Green
    Stop-Job $job
    Remove-Job $job
} else {
    Write-Host "   ✗ Server failed to start" -ForegroundColor Red
    Receive-Job $job
    Remove-Job $job
    exit 1
}

# Summary
Write-Host
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host
Write-Host "✓ Roslyn MCP Server is configured and ready!" -ForegroundColor Green
Write-Host
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart Claude Desktop application"
Write-Host "2. Look for the 'roslyn-code-navigator' tool in Claude"
Write-Host "3. Test with a C# solution file"
Write-Host
Write-Host "Example usage in Claude:" -ForegroundColor Cyan
Write-Host "  'Search for all classes ending with Service in C:\MyProject\MyProject.sln'"
Write-Host "  'Find all references to UserRepository in C:\MyProject\MyProject.sln'"
Write-Host
Write-Host "For testing without Claude Desktop:" -ForegroundColor Yellow
Write-Host "  npx @modelcontextprotocol/inspector dotnet run --project `"$projectPath`""