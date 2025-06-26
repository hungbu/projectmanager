# Cấu trúc Dự án Flutter - Project Manager App

## Tổng quan
Dự án đã được thiết lập với cấu trúc Clean Architecture và các dependencies cần thiết cho việc phát triển ứng dụng quản lý dự án.

## Cấu trúc thư mục

### Core Layer
- **constants/**: Chứa các hằng số như màu sắc, kích thước, chuỗi văn bản
- **errors/**: Xử lý exceptions và failures
- **network/**: API client và network utilities
- **utils/**: Các utility functions và extensions
- **widgets/**: Shared UI components

### Features Layer
Mỗi feature được tổ chức theo Clean Architecture:

#### Auth Feature
- **data/**: Data sources, models, repository implementations
- **domain/**: Entities, repository interfaces, use cases
- **presentation/**: Pages, providers (Riverpod), widgets

#### Dashboard Feature
- Tổng quan dự án và thống kê
- Recent activities
- Quick actions

#### Projects Feature
- CRUD operations cho projects
- Project list và detail views
- Team member management

#### Tasks Feature
- Kanban board implementation
- Task CRUD operations
- Task detail với comments và attachments

#### Profile Feature
- User profile management
- Settings và preferences

### Shared Layer
- **models/**: Shared data models
- **services/**: App-wide services (storage, notifications, etc.)
- **widgets/**: Common UI components

## Dependencies đã cài đặt

### State Management
- `flutter_riverpod`: State management solution
- `riverpod_annotation`: Code generation cho Riverpod

### Navigation
- `go_router`: Declarative routing

### Network
- `dio`: HTTP client cho API calls

### Local Storage
- `hive`: NoSQL database cho local storage
- `hive_flutter`: Flutter integration cho Hive
- `shared_preferences`: Simple key-value storage

### UI Components
- `google_fonts`: Custom fonts
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching
- `lottie`: Animations

### Utilities
- `intl`: Internationalization
- `uuid`: UUID generation
- `equatable`: Value equality
- `jwt_decoder`: JWT token handling

### File Handling
- `file_picker`: File selection
- `image_picker`: Image selection

### Development
- `build_runner`: Code generation
- `flutter_lints`: Linting rules
- `mockito`: Testing mocks

## Các bước tiếp theo

1. **Cài đặt dependencies**:
   ```bash
   flutter pub get
   ```

2. **Chạy code generation**:
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Phát triển từng feature theo thứ tự**:
   - Authentication (login/register)
   - Dashboard (overview)
   - Projects management
   - Tasks management (Kanban board)
   - Profile management

4. **Testing**:
   - Unit tests cho business logic
   - Widget tests cho UI components
   - Integration tests cho user flows

## Theme và Design System

Ứng dụng sử dụng Material Design 3 với:
- **Primary Color**: Blue (#2196F3)
- **Secondary Color**: Green (#4CAF50)
- **Typography**: Roboto font family
- **Spacing**: Consistent spacing system (4, 8, 16, 24, 32, 48dp)
- **Border Radius**: 8dp cho cards và buttons

## Architecture Patterns

- **Clean Architecture**: Separation of concerns với 3 layers
- **Repository Pattern**: Data access abstraction
- **Provider Pattern**: State management với Riverpod
- **MVVM**: Model-View-ViewModel cho presentation layer

Cấu trúc này cung cấp foundation vững chắc cho việc phát triển ứng dụng quản lý dự án với khả năng mở rộng và bảo trì tốt.

