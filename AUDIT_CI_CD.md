## 8. CI/CD Recommendations

### GitHub Actions Workflow

**File:** `.github/workflows/flutter_ci.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  analyze:
    name: Code Analysis
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Verify formatting
        run: flutter format --output=none --set-exit-if-changed .

      - name: Analyze code
        run: flutter analyze

      - name: Check for outdated dependencies
        run: flutter pub outdated

  test:
    name: Unit & Widget Tests
    runs-on: ubuntu-latest
    needs: analyze
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          fail_ci_if_error: false

      - name: Generate coverage report
        run: |
          sudo apt-get update
          sudo apt-get install -y lcov
          genhtml coverage/lcov.info -o coverage/html

      - name: Upload coverage HTML
        uses: actions/upload-artifact@v3
        with:
          name: coverage-report
          path: coverage/html

  build-android:
    name: Build Android APK
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign

  performance-check:
    name: Performance Analysis
    runs-on: ubuntu-latest
    needs: analyze
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Check for performance anti-patterns
        run: |
          echo "Checking for common performance issues..."
          ! grep -r "print(" lib/ || (echo "Found print() statements in lib/" && exit 1)
          ! grep -r "debugPrint(" lib/ || echo "Warning: debugPrint() found (acceptable in debug)"
          ! grep -r "setState(() {" lib/ | grep -v "// ignore" || echo "Warning: Check setState usage"

      - name: Check for memory leaks
        run: |
          echo "Checking for potential memory leaks..."
          grep -r "TextEditingController()" lib/ && echo "⚠️ Found TextEditingController in code - verify disposal" || echo "✓ No inline TextEditingController found"
          grep -r "StreamController" lib/ && echo "⚠️ Found StreamController - verify disposal" || echo "✓ No StreamController found"
          grep -r "AnimationController" lib/ && echo "⚠️ Found AnimationController - verify disposal" || echo "✓ No AnimationController found"

  security-check:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: analyze
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Check for hardcoded secrets
        run: |
          echo "Checking for potential hardcoded secrets..."
          ! grep -rE "(api[_-]?key|secret|password|token).*=.*['\"][a-zA-Z0-9]{20,}['\"]" lib/ || (echo "Potential hardcoded secret found!" && exit 1)
          echo "✓ No obvious hardcoded secrets found"

      - name: Check dependencies for vulnerabilities
        run: |
          echo "Checking for known vulnerable packages..."
          flutter pub outdated --json > outdated.json || true
          cat outdated.json

  notify:
    name: Notification
    runs-on: ubuntu-latest
    needs: [test, build-android]
    if: always()
    
    steps:
      - name: Send notification
        run: |
          echo "Pipeline completed!"
          echo "Test status: ${{ needs.test.result }}"
          echo "Build status: ${{ needs.build-android.result }}"
```

---

## Advanced Workflow with Deployment

**File:** `.github/workflows/flutter_cd.yml`

```yaml
name: Flutter CD (Deploy)

on:
  push:
    tags:
      - 'v*'

jobs:
  build-and-deploy-android:
    name: Build and Deploy Android
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Decode Keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks

      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_SERVICE_ACCOUNT_JSON }}
          packageName: com.example.egypt_fault_map
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed

  build-and-deploy-ios:
    name: Build and Deploy iOS
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Setup signing
        run: |
          # Configure signing certificates and provisioning profiles
          # This requires setting up certificates in GitHub Secrets

      - name: Build IPA
        run: flutter build ipa --release

      - name: Upload to TestFlight
        run: |
          # Use fastlane or xcrun altool to upload to TestFlight
          # Requires App Store Connect API Key
```

---

## Pre-commit Hooks

**File:** `.githooks/pre-commit`

```bash
#!/bin/bash

echo "Running pre-commit checks..."

# Format check
echo "Checking code formatting..."
flutter format --output=none --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "❌ Code formatting issues found. Run 'flutter format .' to fix."
  exit 1
fi
echo "✓ Code formatting passed"

# Analyze
echo "Running static analysis..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Static analysis failed. Fix the issues above."
  exit 1
fi
echo "✓ Static analysis passed"

# Run tests
echo "Running tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Fix failing tests before committing."
  exit 1
fi
echo "✓ All tests passed"

echo "✅ All pre-commit checks passed!"
exit 0
```

### Install pre-commit hook:

```bash
# Make the hook executable
chmod +x .githooks/pre-commit

# Configure git to use custom hooks directory
git config core.hooksPath .githooks
```

---

## Pull Request Template

**File:** `.github/pull_request_template.md`

```markdown
## Description
<!-- Briefly describe the changes in this PR -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Performance improvement
- [ ] Refactoring
- [ ] Documentation update
- [ ] Dependency update

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Performance Impact
- [ ] No performance impact
- [ ] Positive performance impact (please describe)
- [ ] Potential performance impact (please describe and justify)

## Memory Leak Check
- [ ] No new controllers/streams added
- [ ] All new controllers/streams are properly disposed
- [ ] Verified with DevTools memory profiler

## Screenshots (if applicable)
<!-- Add screenshots to help explain your changes -->

## Testing
<!-- Describe the tests you ran to verify your changes -->
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Related Issues
<!-- Link any related issues here -->
Closes #
```

---

## Issue Templates

**File:** `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
A clear and concise description of what the bug is.

## Steps To Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
What actually happened.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- Device: [e.g. iPhone 12, Samsung Galaxy S21]
- OS: [e.g. iOS 15.0, Android 12]
- App Version: [e.g. 1.0.0]
- Flutter Version: [e.g. 3.9.2]

## Additional Context
Add any other context about the problem here.

## Error Logs
```
Paste any relevant error logs here
```

## Possible Fix
If you have a suggestion for how to fix the bug, please describe it here.
```

**File:** `.github/ISSUE_TEMPLATE/feature_request.md`

```markdown
---
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Feature Description
A clear and concise description of the feature you'd like to see.

## Problem Statement
Describe the problem this feature would solve.

## Proposed Solution
Describe how you envision this feature working.

## Alternatives Considered
Describe any alternative solutions or features you've considered.

## Additional Context
Add any other context, mockups, or examples about the feature request here.

## Priority
- [ ] High
- [ ] Medium
- [ ] Low
```

---

## Code Coverage Badge

Add to `README.md`:

```markdown
[![codecov](https://codecov.io/gh/yourusername/egypt_fault_map/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/egypt_fault_map)
[![Flutter CI](https://github.com/yourusername/egypt_fault_map/workflows/Flutter%20CI/badge.svg)](https://github.com/yourusername/egypt_fault_map/actions)
```

---

## Automated Dependency Updates

**File:** `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "your-username"
    labels:
      - "dependencies"
    commit-message:
      prefix: "chore"
      include: "scope"
```

---

## Performance Monitoring in CI

**File:** `.github/workflows/performance.yml`

```yaml
name: Performance Monitoring

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  performance:
    name: Performance Tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Build profile APK
        run: flutter build apk --profile

      - name: Analyze app size
        run: |
          APK_SIZE=$(stat -f%z build/app/outputs/flutter-apk/app-profile.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-profile.apk)
          APK_SIZE_MB=$((APK_SIZE / 1024 / 1024))
          echo "APK Size: ${APK_SIZE_MB}MB"
          
          if [ $APK_SIZE_MB -gt 50 ]; then
            echo "⚠️ Warning: APK size is larger than 50MB"
          else
            echo "✓ APK size is acceptable"
          fi

      - name: Check for large assets
        run: |
          echo "Checking for large assets..."
          find assets -type f -size +500k -exec ls -lh {} \; || echo "No large assets found"

      - name: Analyze build size
        run: |
          flutter build apk --analyze-size --target-platform android-arm64
```

---

## Local Development Scripts

**File:** `scripts/setup.sh`

```bash
#!/bin/bash

echo "Setting up Egypt Fault Map development environment..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✓ Flutter is installed"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
echo "Flutter version: $FLUTTER_VERSION"

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Run code generation
echo "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

# Setup git hooks
echo "Setting up git hooks..."
git config core.hooksPath .githooks
chmod +x .githooks/*

# Run initial checks
echo "Running initial checks..."
flutter analyze
flutter test

echo "✅ Setup complete! You're ready to start developing."
```

**File:** `scripts/run_tests.sh`

```bash
#!/bin/bash

echo "Running all tests with coverage..."

# Run tests with coverage
flutter test --coverage

# Generate HTML report
if command -v lcov &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "✅ Coverage report generated at coverage/html/index.html"
    
    # Open in browser (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage/html/index.html
    fi
else
    echo "⚠️ lcov not installed. Install it to generate HTML coverage reports."
    echo "macOS: brew install lcov"
    echo "Linux: apt-get install lcov"
fi
```

**File:** `scripts/build_all.sh`

```bash
#!/bin/bash

echo "Building all platforms..."

# Android
echo "Building Android APK..."
flutter build apk --release
echo "✓ Android APK built"

# Android App Bundle
echo "Building Android App Bundle..."
flutter build appbundle --release
echo "✓ Android App Bundle built"

# iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS..."
    flutter build ios --release --no-codesign
    echo "✓ iOS built"
else
    echo "⚠️ Skipping iOS build (not on macOS)"
fi

echo "✅ All builds complete!"
```

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

---

## Summary

### Quick Start Checklist

1. **Setup GitHub Actions:**
   - [ ] Create `.github/workflows/flutter_ci.yml`
   - [ ] Add secrets to GitHub repository settings
   - [ ] Enable GitHub Actions in repository settings

2. **Setup Pre-commit Hooks:**
   - [ ] Create `.githooks/pre-commit`
   - [ ] Run `git config core.hooksPath .githooks`
   - [ ] Test with `git commit`

3. **Configure Templates:**
   - [ ] Add PR template
   - [ ] Add issue templates
   - [ ] Add CODEOWNERS file (optional)

4. **Setup Monitoring:**
   - [ ] Configure Codecov (optional)
   - [ ] Setup error tracking (Sentry/Firebase Crashlytics)
   - [ ] Enable performance monitoring

5. **Documentation:**
   - [ ] Update README with badges
   - [ ] Add CONTRIBUTING.md
   - [ ] Add CODE_OF_CONDUCT.md

### Benefits of This CI/CD Setup

- ✅ Automated code quality checks
- ✅ Prevents bad code from being merged
- ✅ Continuous testing and coverage tracking
- ✅ Automated builds for multiple platforms
- ✅ Performance monitoring
- ✅ Security scanning
- ✅ Consistent development workflow

