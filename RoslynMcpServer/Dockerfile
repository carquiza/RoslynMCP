FROM mcr.microsoft.com/dotnet/runtime:8.0-alpine AS base
WORKDIR /app

# Install MSBuild dependencies
RUN apk add --no-cache \
    icu-libs \
    libgcc \
    libgssapi-krb5 \
    libintl \
    libssl3 \
    libstdc++ \
    zlib

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["RoslynMcpServer.csproj", "."]
RUN dotnet restore "RoslynMcpServer.csproj"

# Copy source code and build
COPY . .
RUN dotnet build "RoslynMcpServer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RoslynMcpServer.csproj" -c Release -o /app/publish --self-contained false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create directory for workspace mounting
RUN mkdir -p /workspace

ENTRYPOINT ["dotnet", "RoslynMcpServer.dll"]