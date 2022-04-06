@ECHO OFF

FOR /f "usebackq tokens=*" %%a in (".env") DO (
  FOR /F "tokens=1,2 delims==" %%b IN ("%%a") DO (
    set "%%b=%%c"
  )
)

@oscript %~dp0startenv.os
@oscript %~dp0..\..\tasks\test.os
@oscript %~dp0stopenv.os
@exit /b %ERRORLEVEL%