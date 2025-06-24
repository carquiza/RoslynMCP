# Roslyn MCP Server

A C# MCP (Model Context Protocol) server that integrates with Microsoft's Roslyn compiler platform to provide Claude Desktop with code analysis and navigation capabilities for C# codebases.

## Features

- **Wildcard Symbol Search** - Find classes, methods, and properties using pattern matching (`*Service`, `Get*User`, etc.)
- **Reference Tracking** - Locate all usages of symbols across entire solutions
- **Symbol Information** - Get detailed information about types, methods, properties, and more
- **Dependency Analysis** - Analyze project dependencies and namespace usage patterns
- **Code Complexity Analysis** - Identify high-complexity methods using cyclomatic complexity metrics
- **Performance Optimized** - Multi-level caching and incremental analysis for large codebases
- **Security** - Input validation and path sanitization

## Prerequisites

- .NET 8.0 SDK or later
- Visual Studio 2022 or VS Code (recommended for development)
- Claude Desktop application

## Installation

1. **Clone or download the project**
   ```bash
   git clone https://github.com/carquiza/RoslynMCP.git
   cd RoslynMCP/RoslynMcpServer
   ```

2. **Restore NuGet packages**
   ```bash
   dotnet restore
   ```

3. **Build the project**
   ```bash
   dotnet build
   ```

4. **Test the server** (optional)
   ```bash
   dotnet run
   ```

## Quick Setup

### Windows
Run the PowerShell setup script:
```powershell
.\setup.ps1
```

### Linux/macOS
Run the installation test:
```bash
./test-installation.sh
```

## Claude Desktop Configuration

To connect this MCP server to Claude Desktop, you need to modify the Claude Desktop configuration file:

### Configuration File Location

- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

### Configuration Content

Add the following to your `claude_desktop_config.json` file:

```json
{
  "mcpServers": {
    "roslyn-code-navigator": {
      "command": "dotnet",
      "args": [
        "run", 
        "--project", 
        "/path/to/RoslynMCP/RoslynMcpServer"
      ],
      "env": {
        "DOTNET_ENVIRONMENT": "Production",
        "LOG_LEVEL": "Information"
      }
    }
  }
}
```

**Important**: Replace `/path/to/RoslynMCP/RoslynMcpServer` with the actual absolute path to your project directory.

## Usage

Once configured, restart Claude Desktop. You should see the Roslyn MCP Server appear in the available tools. Here are some example queries:

### Search for Symbols
```
Search for all classes ending with 'Service' in my solution at C:\MyProject\MyProject.sln
```

### Find References
```
Find all references to the UserRepository class in C:\MyProject\MyProject.sln
```

### Get Symbol Information
```
Get information about the CalculateTotal method in C:\MyProject\MyProject.sln
```

### Analyze Dependencies
```
Analyze dependencies for the solution at C:\MyProject\MyProject.sln
```

### Code Complexity Analysis
```
Find methods with complexity higher than 7 in C:\MyProject\MyProject.sln
```

## Available Tools

1. **SearchSymbols** - Search for symbols using wildcard patterns
2. **FindReferences** - Find all references to a specific symbol
3. **GetSymbolInfo** - Get detailed information about a symbol
4. **AnalyzeDependencies** - Analyze project dependencies and usage patterns
5. **AnalyzeCodeComplexity** - Identify high-complexity methods

## Development and Testing

### Using MCP Inspector

For development and testing, you can use the MCP Inspector:

```bash
# Install the inspector
npm install -g @modelcontextprotocol/inspector

# Test your server
npx @modelcontextprotocol/inspector dotnet run --project ./RoslynMcpServer
```

## Architecture

The server features a modular architecture with:

- **MCP Server Layer**: Handles communication with Claude Desktop
- **Roslyn Integration Layer**: Manages workspaces and compilations
- **Search Engine Layer**: Implements symbol search and analysis
- **Multi-level Caching**: Performance optimization for large codebases
- **Security Layer**: Input validation and sanitization

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Christopher Arquiza

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
