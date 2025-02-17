FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

COPY RollAttendanceServer.csproj ./
RUN dotnet restore RollAttendanceServer.csproj

COPY . ./
RUN dotnet publish -c Release -o /app/published

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/published ./

ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000

ENTRYPOINT ["dotnet", "RollAttendanceServer.dll"]
