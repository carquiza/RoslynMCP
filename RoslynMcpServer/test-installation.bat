@echo off
setlocal enabledelayedexpansion

echo === Roslyn MCP Server Installation Test ===
echo.

REM Check .NET installation
echo 1. Checking .NET installation...
dotnet --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('dotnet --version') do set dotnet_version=%%i
    echo    ✓ .NET SDK found: !dotnet_version!
) else (
    echo    ✗ .NET SDK not found. Please install .NET 8.0 SDK or later.
    exit /b 1
)

REM Check project files
echo.
echo 2. Checking project structure...
set "required_files=RoslynMcpServer.csproj Program.cs Services\CodeAnalysisService.cs Services\SymbolSearchService.cs Services\SecurityValidator.cs Tools\CodeNavigationTools.cs Models\SearchModels.cs"

for %%f in (%required_files%) do (
    if exist "%%f" (
        echo    ✓ %%f exists
    ) else (
        echo    ✗ %%f missing
        exit /b 1
    )
)

REM Restore packages
echo.
echo 3. Restoring NuGet packages...
dotnet restore >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ NuGet packages restored successfully
) else (
    echo    ✗ Failed to restore NuGet packages
    exit /b 1
)

REM Build project
echo.
echo 4. Building project...
dotnet build -c Release >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ Project built successfully
) else (
    echo    ✗ Build failed
    echo    Run 'dotnet build' to see detailed error messages
    exit /b 1
)

REM Test basic functionality
echo.
echo 5. Testing basic server startup...
start /b dotnet run --no-build >nul 2>&1
timeout /t 3 >nul
tasklist /fi "imagename eq dotnet.exe" | find "dotnet.exe" >nul
if %errorlevel% equ 0 (
    echo    ✓ Server started successfully
    taskkill /f /im dotnet.exe >nul 2>&1
) else (
    echo    ✗ Server failed to start
    exit /b 1
)

REM Check MCP Inspector availability
echo.
echo 6. Checking MCP Inspector availability...
where npx >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ npm/npx found - MCP Inspector can be used for testing
    echo    Run: npx @modelcontextprotocol/inspector dotnet run --project .
) else (
    echo    ⚠ npm/npx not found - MCP Inspector testing not available
    echo    Install Node.js to use MCP Inspector for testing
)

echo.
echo === Installation Test Complete ===
echo.
echo ✓ All tests passed! The Roslyn MCP Server is ready to use.
echo.
echo Next steps:
echo 1. Add the server configuration to Claude Desktop
echo 2. Restart Claude Desktop
echo 3. Test with a C# solution file
echo.
echo Configuration path:
echo   Windows: %%APPDATA%%\Claude\claude_desktop_config.json
echo   macOS: ~/Library/Application Support/Claude/claude_desktop_config.json
echo.
pause