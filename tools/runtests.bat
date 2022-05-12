@ECHO OFF

FOR /f "usebackq tokens=*" %%a in ("%~dp0.env") DO (
  FOR /F "tokens=1,2 delims==" %%b IN ("%%a") DO (
    set "%%b=%%c"
  )
)

@docker-compose --file %~dp0docker-compose.yml up --build -d
@oscript %~dp0nextcloud\checkenv.os
IF %ERRORLEVEL% NEQ 0 GOTO END

@oscript %~dp0..\tasks\test.os

:END
@docker-compose --file %~dp0docker-compose.yml down
@exit /b %ERRORLEVEL%