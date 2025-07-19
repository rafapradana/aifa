#!/bin/bash

echo "Setting up AIFA development environment..."
echo

# Check if .env exists
if [ -f .env ]; then
    echo ".env file already exists!"
    echo "Please check your configuration manually."
    exit 1
fi

# Copy example file
if [ ! -f .env.example ]; then
    echo "Error: .env.example file not found!"
    echo "Please ensure you're in the project root directory."
    exit 1
fi

cp .env.example .env
echo
echo "✅ Created .env file from template"
echo
echo "⚠️  IMPORTANT: Please edit .env file and add your actual credentials:"
echo "   - SUPABASE_URL=your_actual_supabase_url"
echo "   - SUPABASE_ANON_KEY=your_actual_anon_key"
echo
echo "🔒 Security reminder:"
echo "   - Never commit .env to version control"
echo "   - Share credentials securely with team members"
echo "   - Rotate keys regularly"
echo
echo "Opening .env file for editing..."

# Try to open with common editors
if command -v code &> /dev/null; then
    code .env
elif command -v nano &> /dev/null; then
    nano .env
elif command -v vim &> /dev/null; then
    vim .env
else
    echo "Please edit .env file manually with your preferred editor"
fi

echo
echo "Setup complete! Run 'flutter pub get' and 'flutter run' to start the app."