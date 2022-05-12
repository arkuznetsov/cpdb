@ECHO OFF

@docker-compose --file %~dp0docker-compose.yml down
@exit /b %ERRORLEVEL%