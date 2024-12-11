FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["source/RollAttendanceServer/RollAttendanceServer.csproj", "source/RollAttendanceServer/"]
RUN dotnet restore "source/RollAttendanceServer/RollAttendanceServer.csproj"
COPY . .
WORKDIR "/src/source/RollAttendanceServer"
RUN dotnet build "RollAttendanceServer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RollAttendanceServer.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "RollAttendanceServer.dll"]
