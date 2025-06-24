using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Server;
using Microsoft.Build.Locator;
using RoslynMcpServer.Services;

namespace RoslynMcpServer
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // Create a temporary logger for early initialization
            using var loggerFactory = LoggerFactory.Create(builder =>
                builder.AddConsole(options => options.LogToStandardErrorThreshold = LogLevel.Information));
            var tempLogger = loggerFactory.CreateLogger<Program>();

            // Register MSBuild before any workspace operations
            // This is required for Roslyn to find MSBuild
            if (!MSBuildLocator.IsRegistered)
            {
                try
                {
                    MSBuildLocator.RegisterDefaults();
                    tempLogger.LogInformation("MSBuild registered successfully");
                }
                catch (Exception ex)
                {
                    tempLogger.LogError(ex, "Failed to register MSBuild: {Message}", ex.Message);
                    Environment.Exit(1);
                }
            }

            var builder = Host.CreateApplicationBuilder(args);

            // Configure logging for MCP integration - ensure all logs go to stderr
            builder.Logging.ClearProviders();
            builder.Logging.AddConsole(options =>
            {
                options.LogToStandardErrorThreshold = LogLevel.Trace; // All logs to stderr
            });

            // Register services
            builder.Services.AddSingleton<CodeAnalysisService>();
            builder.Services.AddSingleton<SymbolSearchService>();
            builder.Services.AddSingleton<SecurityValidator>();
            builder.Services.AddSingleton<DiagnosticLogger>();
            builder.Services.AddSingleton<IncrementalAnalyzer>();
            builder.Services.AddSingleton<IPersistentCache, FilePersistentCache>();
            builder.Services.AddSingleton<MultiLevelCacheManager>();
            builder.Services.AddMemoryCache();

            // Configure MCP server
            try
            {
                builder.Services
                    .AddMcpServer()
                    .WithStdioServerTransport()
                    .WithToolsFromAssembly();

                var host = builder.Build();

                var logger = host.Services.GetRequiredService<ILogger<Program>>();
                logger.LogInformation("Starting Roslyn MCP Server...");

                await host.RunAsync();
            }
            catch (Exception ex)
            {
                tempLogger.LogError(ex, "Failed to start MCP server: {Message}", ex.Message);
                Environment.Exit(1);
            }
        }
    }
}