#!/bin/bash

# Angular upgrade script for TeteCore
# This script upgrades Angular from v10 to v18

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLIENT_APP="$PROJECT_ROOT/Tete.Web/ClientApp"

echo "🚀 Starting Angular upgrade from v10 to v18"
echo "Working directory: $CLIENT_APP"

# Navigate to ClientApp
cd "$CLIENT_APP"

# Backup current files
echo "📦 Backing up current configuration..."
cp package.json package.json.backup
cp angular.json angular.json.backup
if [ -f "tslint.json" ]; then
  cp tslint.json tslint.json.backup
fi

# Remove node_modules and package-lock.json for clean install
echo "🧹 Cleaning existing dependencies..."
rm -rf node_modules package-lock.json

# Install new package.json
echo "📋 Installing updated dependencies..."
if [ -f "package.json.new" ]; then
  mv package.json.new package.json
  echo "✅ Updated package.json"
else
  echo "❌ package.json.new not found!"
  exit 1
fi

# Install new angular.json
if [ -f "angular.json.new" ]; then
  mv angular.json.new angular.json
  echo "✅ Updated angular.json"
fi

# Install ESLint config (replaces tslint)
if [ -f "eslint.config.js" ]; then
  echo "✅ Added ESLint configuration"
  # Remove old tslint.json if it exists
  if [ -f "tslint.json" ]; then
    rm tslint.json
    echo "🗑️ Removed deprecated tslint.json"
  fi
fi

# Update tsconfig files for Angular 18
echo "🔧 Updating TypeScript configuration..."

# Update tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "sourceMap": true,
    "declaration": false,
    "experimentalDecorators": true,
    "moduleResolution": "bundler",
    "importHelpers": true,
    "target": "ES2022",
    "module": "ES2022",
    "useDefineForClassFields": false,
    "lib": ["ES2022", "dom"]
  },
  "angularCompilerOptions": {
    "enableI18nLegacyMessageIdFormat": false,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": true
  }
}
EOF

# Create tsconfig.app.json
cat > tsconfig.app.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "./out-tsc/app",
    "types": []
  },
  "files": [
    "src/main.ts"
  ],
  "include": [
    "src/**/*.d.ts"
  ]
}
EOF

# Create tsconfig.spec.json
cat > tsconfig.spec.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "./out-tsc/spec",
    "types": [
      "jasmine"
    ]
  },
  "include": [
    "src/**/*.spec.ts",
    "src/**/*.d.ts"
  ]
}
EOF

# Install dependencies
echo "📦 Installing new dependencies..."
npm install

echo ""
echo "✅ Angular upgrade completed!"
echo ""
echo "📋 Next steps:"
echo "1. Review your component files for breaking changes"
echo "2. Update imports (e.g., HttpClientModule location changed)"
echo "3. Test the build: npm run build"
echo "4. Update any custom code that uses deprecated APIs"
echo ""
echo "🔧 Common Angular 18 changes to check:"
echo "- Bootstrap 5 (instead of 4) - check CSS classes"
echo "- RxJS operators import paths may have changed"
echo "- Router guard interfaces have changed"
echo "- HttpClientModule is now provideHttpClient()"
echo ""
echo "📚 See Angular Update Guide: https://update.angular.io/"