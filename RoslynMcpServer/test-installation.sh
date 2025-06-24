#!/bin/bash

# Test script for Roslyn MCP Server
# This script validates the installation and basic functionality

echo "=== Roslyn MCP Server Installation Test ==="
echo

# Check .NET installation
echo "1. Checking .NET installation..."
if command -v dotnet &> /dev/null; then
    dotnet_version=$(dotnet --version)
    echo "   ✓ .NET SDK found: $dotnet_version"
else
    echo "   ✗ .NET SDK not found. Please install .NET 8.0 SDK or later."
    exit 1
fi

# Check project files
echo
echo "2. Checking project structure..."
required_files=(
    "RoslynMcpServer.csproj"
    "Program.cs"
    "Services/CodeAnalysisService.cs"
    "Services/SymbolSearchService.cs"
    "Services/SecurityValidator.cs"
    "Tools/CodeNavigationTools.cs"
    "Models/SearchModels.cs"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✓ $file exists"
    else
        echo "   ✗ $file missing"
        exit 1
    fi
done

# Restore packages
echo
echo "3. Restoring NuGet packages..."
if dotnet restore > /dev/null 2>&1; then
    echo "   ✓ NuGet packages restored successfully"
else
    echo "   ✗ Failed to restore NuGet packages"
    exit 1
fi

# Build project
echo
echo "4. Building project..."
if dotnet build -c Release > /dev/null 2>&1; then
    echo "   ✓ Project built successfully"
else
    echo "   ✗ Build failed"
    echo "   Run 'dotnet build' to see detailed error messages"
    exit 1
fi

# Test basic functionality
echo
echo "5. Testing basic server startup..."
timeout 10 dotnet run --no-build > /dev/null 2>&1 &
SERVER_PID=$!
sleep 3

if kill -0 $SERVER_PID 2>/dev/null; then
    echo "   ✓ Server started successfully"
    kill $SERVER_PID
else
    echo "   ✗ Server failed to start"
    exit 1
fi

# Check MCP Inspector availability
echo
echo "6. Checking MCP Inspector availability..."
if command -v npx &> /dev/null; then
    echo "   ✓ npm/npx found - MCP Inspector can be used for testing"
    echo "   Run: npx @modelcontextprotocol/inspector dotnet run --project ."
else
    echo "   ⚠ npm/npx not found - MCP Inspector testing not available"
    echo "   Install Node.js to use MCP Inspector for testing"
fi

echo
echo "=== Installation Test Complete ==="
echo
echo "✓ All tests passed! The Roslyn MCP Server is ready to use."
echo
echo "Next steps:"
echo "1. Add the server configuration to Claude Desktop"
echo "2. Restart Claude Desktop"
echo "3. Test with a C# solution file"
echo
echo "Configuration path:"
echo "  Windows: %APPDATA%\\Claude\\claude_desktop_config.json"
echo "  macOS: ~/Library/Application Support/Claude/claude_desktop_config.json"