using Microsoft.Extensions.Logging;
using System.Diagnostics;
using System.Text.Json;

namespace RoslynMcpServer.Services
{
    public class DiagnosticLogger
    {
        private readonly ILogger _logger;
        
        public DiagnosticLogger(ILogger<DiagnosticLogger> logger)
        {
            _logger = logger;
        }
        
        public async Task<T> LoggedExecutionAsync<T>(
            string operationName, 
            Func<Task<T>> operation,
            object? parameters = null)
        {
            var stopwatch = Stopwatch.StartNew();
            var operationId = Guid.NewGuid().ToString("N")[..8];
            
            _logger.LogInformation(
                "Starting {OperationName} [{OperationId}] with parameters: {Parameters}",
                operationName, operationId, JsonSerializer.Serialize(parameters));
            
            try
            {
                var result = await operation();
                
                _logger.LogInformation(
                    "Completed {OperationName} [{OperationId}] in {ElapsedMs}ms",
                    operationName, operationId, stopwatch.ElapsedMilliseconds);
                
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed {OperationName} [{OperationId}] after {ElapsedMs}ms",
                    operationName, operationId, stopwatch.ElapsedMilliseconds);
                throw;
            }
        }
    }
}