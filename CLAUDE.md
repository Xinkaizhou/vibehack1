# vibehack1

A macOS SwiftUI application.

## Tech Stack

- **Platform**: macOS 15.5+
- **Language**: Swift 5.0
- **Framework**: SwiftUI
- **IDE**: Xcode 16.4
- **Testing**: Swift Testing framework
- **Bundle ID**: com.xinkai.vibehack1

## Project Structure

```
vibehack1/
├── vibehack1/                 # Main app source
│   ├── vibehack1App.swift    # App entry point
│   ├── ContentView.swift     # Main view
│   ├── vibehack1.entitlements # App permissions
│   └── Assets.xcassets/      # Images, colors, icons
├── vibehack1Tests/           # Unit tests
├── vibehack1UITests/         # UI tests
└── vibehack1.xcodeproj/      # Xcode project
```

## Development Commands

### Build & Run
```bash
# Build project
xcodebuild -scheme vibehack1 -configuration Debug

# Build for release
xcodebuild -scheme vibehack1 -configuration Release

# Open in Xcode
open vibehack1.xcodeproj
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme vibehack1 -destination 'platform=macOS'

# Run UI tests
xcodebuild test -scheme vibehack1 -destination 'platform=macOS' -only-testing:vibehack1UITests
```

## App Configuration

- **Sandbox**: Enabled
- **Permissions**: Read-only access to user-selected files
- **Deployment Target**: macOS 15.5
- **Architecture**: Universal (Apple Silicon + Intel)

## Code Style

- Use SwiftUI declarative syntax
- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Prefer `struct` over `class` for views
- Use `@State`, `@Binding`, `@ObservedObject` appropriately for state management
- Keep views small and focused

## Build Configurations

- **Debug**: Development builds with debugging enabled
- **Release**: Production builds with optimizations

## File Organization

- Place reusable views in separate Swift files
- Keep business logic separate from UI code
- Use meaningful file and folder names
- Follow Xcode's default project structure