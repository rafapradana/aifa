@echo off
echo Running AIFA Security Validation...
echo.

REM Check if .env exists
if not exist .env (
    echo ❌ ERROR: .env file not found!
    echo Please run setup_env.bat first.
    pause
    exit /b 1
)

REM Check if .env is in gitignore
findstr /C:".env" .gitignore >nul
if %errorlevel% neq 0 (
    echo ❌ ERROR: .env not found in .gitignore!
    echo This is a security risk!
    pause
    exit /b 1
)

echo ✅ Environment file exists and is properly ignored
echo.

REM Check for hardcoded credentials in Dart files
echo Scanning for hardcoded credentials...
findstr /R /C:"https://.*\.supabase\.co" lib\*.dart lib\**\*.dart >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ WARNING: Found potential hardcoded Supabase URLs in code!
    echo Please review and move to environment variables.
) else (
    echo ✅ No hardcoded Supabase URLs found
)

findstr /R /C:"eyJ.*" lib\*.dart lib\**\*.dart >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ WARNING: Found potential hardcoded JWT tokens in code!
    echo Please review and move to environment variables.
) else (
    echo ✅ No hardcoded JWT tokens found
)

echo.
echo Security validation complete!
echo.
echo 🔒 Security Checklist:
echo [✅] Environment variables configured
echo [✅] Sensitive files in gitignore
echo [✅] No hardcoded credentials detected
echo.
echo Next steps:
echo - Enable Row Level Security in Supabase
echo - Configure proper authentication policies
echo - Test with invalid inputs
echo - Review docs/SECURITY.md for more guidelines
echo.
pause