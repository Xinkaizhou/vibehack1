# vibehack1

macOS SwiftUI application for hackathon/prototype development.

## Development Philosophy

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Clear intent over clever code** - Readable, maintainable solutions
- **TDD approach** - Write tests first, then implement
- **Maximum 3 attempts** - If stuck after 3 tries, reassess approach
- **Learning from existing code** - Study patterns before implementing

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

## Git Workflow

- **Branch naming**: `feature/description` or `fix/description`
- **Commit format**: `type: brief description` (feat, fix, refactor, test, docs)
- **Small commits**: One logical change per commit
- **Test before commit**: All tests must pass

## Development Commands

### Essential Commands
```bash
# Open project
open vibehack1.xcodeproj

# Build & test (use this before commits)
xcodebuild test -scheme vibehack1 -destination 'platform=macOS'

# Build for release
xcodebuild -scheme vibehack1 -configuration Release
```

## App Configuration

- **Sandbox**: Enabled
- **Permissions**: Read-only access to user-selected files
- **Deployment Target**: macOS 15.5
- **Architecture**: Universal (Apple Silicon + Intel)

## Implementation Process

### Task Breakdown
1. **Plan** - Break complex features into 3-5 small stages
2. **Test First** - Write failing tests before implementation
3. **Implement** - Minimal code to pass tests
4. **Refactor** - Improve while maintaining tests
5. **Review** - Check code quality and patterns

### Problem Solving
- Study existing code patterns first
- Implement smallest working solution
- Test edge cases and error conditions
- Document non-obvious decisions

## SwiftUI Best Practices

### State Management
- `@State` for local view state
- `@Binding` for two-way data flow
- `@StateObject`/`@ObservableObject` for shared data
- Keep state as close to usage as possible

### View Structure
- Single responsibility per view
- Extract complex views into components
- Use `ViewBuilder` for conditional content
- Prefer composition over inheritance

### Code Style
- Descriptive variable names (no abbreviations)
- camelCase for properties/functions, PascalCase for types
- Group related modifiers together
- Extract complex logic into separate functions

## File Organization
- One view per file (except small helper views)
- Business logic separate from UI
- Group related files in folders
- Use meaningful, searchable names