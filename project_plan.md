## Các tính năng chính được đề xuất cho ứng dụng Flutter:

Để tập trung vào các chức năng cốt lõi và phù hợp với việc phát triển ứng dụng di động bằng Flutter, các tính năng sau đây được đề xuất:

1.  **Quản lý dự án và tác vụ (Project and Task Management):**
    *   Tạo và quản lý dự án.
    *   Tạo, chỉnh sửa, xóa tác vụ trong dự án.
    *   Gán người thực hiện cho tác vụ.
    *   Đặt trạng thái cho tác vụ (ví dụ: To Do, In Progress, Done).
    *   Hiển thị tác vụ dưới dạng bảng (Kanban-style boards) hoặc danh sách.

2.  **Công cụ cộng tác (Collaboration Tools):**
    *   Bình luận trên tác vụ.
    *   Gắn thẻ người dùng (@mentions).
    *   Đính kèm tệp cơ bản vào tác vụ.

3.  **Tổng quan dự án (Project Overview):**
    *   Hiển thị tổng quan các dự án và tác vụ chính.
    *   Có thể là một dashboard đơn giản hiển thị số lượng tác vụ theo trạng thái, theo người thực hiện.


## Kiến trúc ứng dụng (Application Architecture):

Ứng dụng sẽ được xây dựng với kiến trúc client-server. Phần mềm Flutter sẽ là client, giao tiếp với một backend API.

### 1. Frontend (Flutter Mobile App):
*   **Ngôn ngữ:** Dart
*   **Framework:** Flutter
*   **Quản lý trạng thái (State Management):** Provider, Riverpod, hoặc BLoC (sẽ lựa chọn cụ thể sau khi phân tích sâu hơn).
*   **Giao diện người dùng (UI):** Thiết kế theo Material Design hoặc Cupertino (iOS-style) tùy theo yêu cầu cụ thể, tập trung vào trải nghiệm người dùng di động.
*   **Kết nối API:** Sử dụng thư viện `http` hoặc `dio` để gọi các API từ backend.

### 2. Backend (API Server):
*   **Ngôn ngữ/Framework:** Python với Flask/FastAPI hoặc Node.js với Express (sẽ lựa chọn cụ thể sau).
*   **Cơ sở dữ liệu (Database):** PostgreSQL hoặc MongoDB (sẽ lựa chọn cụ thể sau khi phân tích yêu cầu dữ liệu).
*   **Authentication/Authorization:** JWT (JSON Web Tokens) để xác thực người dùng và cấp quyền truy cập API.
*   **API:** RESTful API để cung cấp dữ liệu và xử lý logic nghiệp vụ cho ứng dụng Flutter.

### 3. Cấu trúc dữ liệu chính (Core Data Structures):
*   **User:** ID, Tên, Email, Mật khẩu (hashed).
*   **Project:** ID, Tên dự án, Mô tả, Người tạo, Ngày tạo, Danh sách thành viên.
*   **Task:** ID, Tên tác vụ, Mô tả, Trạng thái (enum: To Do, In Progress, Done), Người được giao, Ngày tạo, Ngày đến hạn, Project ID.
*   **Comment:** ID, Nội dung, Người tạo, Ngày tạo, Task ID.
*   **Attachment:** ID, Tên tệp, URL tệp, Task ID.



