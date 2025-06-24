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
   cd D:\Source\RoslynMCP\RoslynMcpServer
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
        "D:\\Source\\RoslynMCP\\RoslynMcpServer"
      ],
      "env": {
        "DOTNET_ENVIRONMENT": "Production",
        "LOG_LEVEL": "Information"
      }
    }
  }
}
```

**Important Notes:**
- Replace `D:\\Source\\RoslynMCP\\RoslynMcpServer` with the actual absolute path to your project
- Use double backslashes (`\\`) in Windows paths for proper JSON escaping
- The path must be absolute - relative paths will not work

### Alternative: Using dotnet run directly

If you prefer to use the built executable:

```json
{
  "mcpServers": {
    "roslyn-code-navigator": {
      "command": "D:\\Source\\RoslynMCP\\RoslynMcpServer\\bin\\Debug\\net8.0\\RoslynMcpServer.exe",
      "args": [],
      "env": {
        "DOTNET_ENVIRONMENT": "Production"
      }
    }
  }
}
```

## Usage

Once configured, restart Claude Desktop. You should see the Roslyn MCP Server appear in the available tools. Here are the available commands:

### 1. Search Symbols
Search for symbols using wildcard patterns:

**Example:**
```
Search for all classes ending with 'Service' in my solution at C:\MyProject\MyProject.sln
```

This will use the `SearchSymbols` tool with pattern `*Service` and symbol types `class`.

### 2. Find References
Find all references to a specific symbol:

**Example:**
```
Find all references to the UserRepository class in C:\MyProject\MyProject.sln
```

### 3. Get Symbol Information
Get detailed information about a specific symbol:

**Example:**
```
Get information about the CalculateTotal method in C:\MyProject\MyProject.sln
```

### 4. Analyze Dependencies
Analyze project dependencies and usage patterns:

**Example:**
```
Analyze dependencies for the solution at C:\MyProject\MyProject.sln
```

### 5. Analyze Code Complexity
Identify methods with high cyclomatic complexity:

**Example:**
```
Find methods with complexity higher than 7 in C:\MyProject\MyProject.sln
```

## Tool Parameters

### SearchSymbols
- `pattern`: Wildcard pattern (* and ? supported)
- `solutionPath`: Absolute path to .sln file
- `symbolTypes`: Comma-separated list (class,interface,method,property,field)
- `ignoreCase`: Boolean (default: true)

### FindReferences
- `symbolName`: Exact symbol name to find
- `solutionPath`: Absolute path to .sln file
- `includeDefinition`: Include symbol definition (default: true)

### GetSymbolInfo
- `symbolName`: Symbol name or fully qualified name
- `solutionPath`: Absolute path to .sln file

### AnalyzeDependencies
- `solutionPath`: Absolute path to .sln file
- `maxDepth`: Maximum analysis depth (default: 3)

### AnalyzeCodeComplexity
- `solutionPath`: Absolute path to .sln file
- `threshold`: Complexity threshold 1-10 (default: 5)

## Development and Testing

### Using MCP Inspector

For development and testing, you can use the MCP Inspector:

```bash
# Install the inspector
npm install -g @modelcontextprotocol/inspector

# Test your server
npx @modelcontextprotocol/inspector dotnet run --project D:\Source\RoslynMCP\RoslynMcpServer
```

### Debugging

The server includes comprehensive logging. Check the console output for detailed information about operations and any errors.

### Performance Considerations

- **Large Solutions**: The server uses caching and incremental analysis for better performance
- **Memory Usage**: Large codebases may require significant memory
- **First Run**: Initial analysis may take longer as caches are populated

## Security

The server includes several security measures:
- Path validation to prevent directory traversal
- Input sanitization for search patterns
- File extension validation
- Error handling and safe error messages

## Troubleshooting

### Common Issues

1. **MSBuild not found**
   - Ensure .NET SDK is properly installed
   - Visual Studio Build Tools may be required

2. **Solution file not found**
   - Check that the path is absolute and correct
   - Ensure the .sln file exists and is accessible

3. **Server not appearing in Claude Desktop**
   - Check JSON syntax in configuration file
   - Verify the path to the project is correct
   - Restart Claude Desktop after configuration changes

4. **Performance issues**
   - Large solutions may require more memory
   - Consider increasing timeout values for complex operations

### Logs

Check the console output for detailed error messages and debugging information. The server logs all major operations and errors.

## Architecture

The server is built with a modular architecture:

- **MCP Server Layer**: Handles communication with Claude Desktop
- **Roslyn Integration Layer**: Manages workspaces and compilations
- **Search Engine Layer**: Implements symbol search and analysis
- **Caching Layer**: Multi-level caching for performance optimization
- **Security Layer**: Input validation and sanitization

## Contributing

This is a complete implementation based on the comprehensive guide. Feel free to extend it with additional features like:

- Support for VB.NET projects
- Additional complexity metrics
- Code quality analysis
- Refactoring suggestions
- Integration with other analysis tools