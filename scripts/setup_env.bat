@echo off
echo Setting up AIFA development environment...
echo.

REM Check if .env exists
if exist .env (
    echo .env file already exists!
    echo Please check your configuration manually.
    pause
    exit /b 1
)

REM Copy example file
if not exist .env.example (
    echo Error: .env.example file not found!
    echo Please ensure you're in the project root directory.
    pause
    exit /b 1
)

copy .env.example .env
echo.
echo ✅ Created .env file from template
echo.
echo ⚠️  IMPORTANT: Please edit .env file and add your actual credentials:
echo    - SUPABASE_URL=your_actual_supabase_url
echo    - SUPABASE_ANON_KEY=your_actual_anon_key
echo.
echo 🔒 Security reminder:
echo    - Never commit .env to version control
echo    - Share credentials securely with team members
echo    - Rotate keys regularly
echo.
echo Opening .env file for editing...
notepad .env
echo.
echo Setup complete! Run 'flutter pub get' and 'flutter run' to start the app.
pause