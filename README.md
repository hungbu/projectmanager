# Project Manager App

A modern project management application built with Flutter, inspired by Monday.com. This app helps teams collaborate, manage projects, and track tasks efficiently.

## Features

### Core Features
- **Project Management**: Create, edit, and manage projects with detailed information
- **Task Management**: Kanban-style task boards with drag-and-drop functionality
- **User Authentication**: Secure login and registration system
- **Dashboard**: Overview of projects, tasks, and team activities
- **Real-time Collaboration**: Team members can work together seamlessly

### Technical Features
- **Modern UI/UX**: Material Design 3 with custom theming
- **State Management**: Riverpod for efficient state management
- **Navigation**: Go Router for type-safe navigation
- **Local Storage**: Hive for offline data persistence
- **HTTP Client**: Dio for API communication
- **Responsive Design**: Works on various screen sizes

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants (colors, sizes, strings)
│   ├── errors/            # Error handling
│   ├── network/           # API client and network utilities
│   ├── utils/             # Utility functions
│   └── widgets/           # Reusable UI components
├── features/
│   ├── auth/              # Authentication feature
│   ├── dashboard/         # Dashboard feature
│   ├── projects/          # Project management feature
│   └── tasks/             # Task management feature
├── shared/
│   ├── models/            # Shared data models
│   ├── services/          # Shared services
│   └── widgets/           # Shared UI components
├── app.dart               # Main app configuration
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project_manager_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **Code Generation** (if needed)
   ```bash
   flutter packages pub run build_runner build
   ```

2. **Run Tests**
   ```bash
   flutter test
   ```

## Architecture

### Clean Architecture
The app follows Clean Architecture principles with clear separation of concerns:

- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources and repositories

### State Management
- **Riverpod**: For state management and dependency injection
- **Provider Pattern**: For sharing data across widgets

### Navigation
- **Go Router**: For type-safe navigation and deep linking

## Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  go_router: ^12.1.3            # Navigation
  dio: ^5.4.0                   # HTTP client
  hive: ^2.2.3                  # Local storage
  google_fonts: ^6.1.0          # Typography
  equatable: ^2.0.5             # Value equality
  uuid: ^4.2.1                  # Unique identifiers
```

## Features in Development

### Phase 1 (Current)
- [x] Project structure setup
- [x] Basic UI components
- [x] Navigation system
- [x] Authentication pages
- [x] Dashboard layout

### Phase 2 (Next)
- [ ] Project CRUD operations
- [ ] Task management with Kanban board
- [ ] User management
- [ ] Real-time updates
- [ ] File attachments

### Phase 3 (Future)
- [ ] Advanced reporting
- [ ] Team collaboration features
- [ ] Mobile notifications
- [ ] Offline support
- [ ] Multi-language support

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions, please contact:
- Email: support@projectmanager.com
- Documentation: [docs.projectmanager.com](https://docs.projectmanager.com)

## Acknowledgments

- Inspired by Monday.com
- Built with Flutter
- Uses Material Design 3
- Community contributions welcome 