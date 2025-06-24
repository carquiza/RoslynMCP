using Microsoft.CodeAnalysis;

namespace RoslynMcpServer.Models
{
    public class SymbolSearchResult
    {
        public string Name { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string ProjectName { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public int LineNumber { get; set; }
        public string Summary { get; set; } = string.Empty;
        public string Accessibility { get; set; } = string.Empty;
        public SymbolKind SymbolKind { get; set; }
        public string Namespace { get; set; } = string.Empty;
    }

    public class ReferenceResult
    {
        public string SymbolName { get; set; } = string.Empty;
        public string DocumentPath { get; set; } = string.Empty;
        public string ProjectName { get; set; } = string.Empty;
        public int LineNumber { get; set; }
        public int ColumnNumber { get; set; }
        public string LineText { get; set; } = string.Empty;
        public List<string> Context { get; set; } = new();
        public bool IsDefinition { get; set; }
        public string ReferenceKind { get; set; } = string.Empty;
    }

    public class SymbolInfo
    {
        public string Name { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Kind { get; set; } = string.Empty;
        public string Accessibility { get; set; } = string.Empty;
        public string DeclaringType { get; set; } = string.Empty;
        public string Namespace { get; set; } = string.Empty;
        public string Assembly { get; set; } = string.Empty;
        public string Documentation { get; set; } = string.Empty;
        public List<string> Parameters { get; set; } = new();
        public string ReturnType { get; set; } = string.Empty;
        public List<string> Attributes { get; set; } = new();
        public string SourceLocation { get; set; } = string.Empty;
    }

    public class DependencyAnalysis
    {
        public string ProjectName { get; set; } = string.Empty;
        public List<ProjectDependency> Dependencies { get; set; } = new();
        public List<NamespaceUsage> NamespaceUsages { get; set; } = new();
        public int TotalSymbols { get; set; }
        public int PublicSymbols { get; set; }
        public int InternalSymbols { get; set; }
    }

    public class ProjectDependency
    {
        public string Name { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty; // ProjectReference, PackageReference, etc.
        public int UsageCount { get; set; }
    }

    public class NamespaceUsage
    {
        public string Namespace { get; set; } = string.Empty;
        public int UsageCount { get; set; }
        public List<string> UsedTypes { get; set; } = new();
    }

    public class ComplexityResult
    {
        public string MethodName { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        public int LineNumber { get; set; }
        public int Complexity { get; set; }
        public string ClassName { get; set; } = string.Empty;
        public string Namespace { get; set; } = string.Empty;
    }

    public class AnalysisResult
    {
        public int ProcessedDocuments { get; set; }
        public List<SymbolSearchResult> Symbols { get; set; } = new();
        public List<ComplexityResult> ComplexityIssues { get; set; } = new();
        public DateTime AnalysisStartTime { get; set; }
        public DateTime AnalysisEndTime { get; set; }
        public TimeSpan Duration => AnalysisEndTime - AnalysisStartTime;
    }
}