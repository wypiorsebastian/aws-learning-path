# W12-T01 — Dockerfile dla orders-api (ECR/Fargate)
# Wzorcowy: multi-stage, best practices (Microsoft + Docker)
# Zgodny z: https://learn.microsoft.com/en-us/dotnet/core/docker/container-images
#           https://docs.docker.com/build/building/best-practices/
# Security: non-root user; pinned digests dla reproducibility
# Platform: linux/amd64 (Fargate) — build z: docker build --platform linux/amd64

FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:e362a8dbcd691522456da26a5198b8f3ca1d7641c95624fadc5e3e82678bd08a AS build
WORKDIR /src

# Cache: copy csproj first, restore (Docker + ASP.NET best practice)
COPY ["Orders.Api/Orders.Api.csproj", "Orders.Api/"]
RUN dotnet restore "Orders.Api/Orders.Api.csproj"

# Copy source, publish
COPY ["Orders.Api/", "Orders.Api/"]
RUN dotnet publish "Orders.Api/Orders.Api.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

# Runtime stage — minimal aspnet image (Ubuntu-based, ICU/tzdata)
FROM mcr.microsoft.com/dotnet/aspnet:10.0@sha256:aec87aa74ddf129da573fa69f42f229a23c953a1c6fdecedea1aa6b1fe147d76 AS final
WORKDIR /app

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "Orders.Api.dll"]
