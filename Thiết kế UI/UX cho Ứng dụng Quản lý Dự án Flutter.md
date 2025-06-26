# Thiết kế UI/UX cho Ứng dụng Quản lý Dự án Flutter

## Nguyên tắc thiết kế

### 1. Thiết kế tập trung vào mobile-first
- Giao diện được tối ưu hóa cho màn hình di động với kích thước từ 5-7 inch
- Sử dụng các thành phần UI phù hợp với thao tác cảm ứng
- Khoảng cách tối thiểu 44px cho các nút bấm để dễ dàng thao tác bằng ngón tay

### 2. Hệ thống màu sắc
- **Màu chính (Primary):** Xanh dương (#2196F3) - tạo cảm giác tin cậy và chuyên nghiệp
- **Màu phụ (Secondary):** Xanh lá (#4CAF50) - cho các hành động tích cực
- **Màu cảnh báo (Warning):** Cam (#FF9800) - cho các thông báo quan trọng
- **Màu nguy hiểm (Danger):** Đỏ (#F44336) - cho các hành động xóa hoặc lỗi
- **Màu nền (Background):** Trắng (#FFFFFF) và xám nhạt (#F5F5F5)
- **Màu văn bản:** Đen (#212121) và xám đậm (#757575)

### 3. Typography
- **Font chính:** Roboto (Android) / San Francisco (iOS)
- **Kích thước font:**
  - Tiêu đề chính: 24sp
  - Tiêu đề phụ: 20sp
  - Nội dung: 16sp
  - Chú thích: 14sp
  - Caption: 12sp

### 4. Spacing và Layout
- **Margin chuẩn:** 16dp
- **Padding chuẩn:** 12dp
- **Border radius:** 8dp cho các card và button
- **Elevation:** 2dp cho các card, 4dp cho floating action button

## Wireframes chính

### 1. Màn hình Dashboard
![Dashboard Wireframe](https://private-us-east-1.manuscdn.com/sessionFile/K2i9e1zhPNUItwg00MCKYT/sandbox/RMv1HR89ul2dfRoeJvDeoH-images_1750210078084_na1fn_L2hvbWUvdWJ1bnR1L3dpcmVmcmFtZV9kYXNoYm9hcmQ.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvSzJpOWUxemhQTlVJdHdnMDBNQ0tZVC9zYW5kYm94L1JNdjFIUjg5dWwyZGZSb2VKdkRlb0gtaW1hZ2VzXzE3NTAyMTAwNzgwODRfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwzZHBjbVZtY21GdFpWOWtZWE5vWW05aGNtUS5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NjcyMjU2MDB9fX1dfQ__&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=Ke0q613hSrDgaCWieTtN9PRhNc1cBvEOOcnenqVOZYFOHxIkC-QMnNiL4hame4n6Ut89VRUtxEKID3TESr9brvVyeyd7uNaN2bp0tI-mqT~bQxPLqoUs-uy4q3fBrrrE45Nt806FZ-DmR6eG7KothpE4vt5uRBg7O~oekqFsMx48zzEqL~N075mohqfmFvXglJmuJSGgLfkw0Jmy~N3CzRJCZMjUgbqd1Ltq4W1FnCOIy6FMTCn3AcE5dM6QgWFnmqaWBQwwsDl3rCCn1-sU16sDv97VYMuuH9AHGP3XHy8cpqsgO9kRPVO62D2e~ADoCrtb6uQQA2UXikAyqfGboA__)

**Mô tả:**
- Header với avatar người dùng và icon thông báo
- Khu vực chính hiển thị tổng quan các dự án
- Các card dự án với thông tin: tên dự án, tiến độ, số lượng tác vụ, thành viên
- Bottom navigation với 5 tab chính

**Thành phần chính:**
- User profile section
- Project overview cards
- Progress indicators
- Team member avatars
- Bottom navigation bar

### 2. Màn hình Project Board (Kanban)
![Project Board Wireframe](https://private-us-east-1.manuscdn.com/sessionFile/K2i9e1zhPNUItwg00MCKYT/sandbox/RMv1HR89ul2dfRoeJvDeoH-images_1750210078085_na1fn_L2hvbWUvdWJ1bnR1L3dpcmVmcmFtZV9wcm9qZWN0X2JvYXJk.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvSzJpOWUxemhQTlVJdHdnMDBNQ0tZVC9zYW5kYm94L1JNdjFIUjg5dWwyZGZSb2VKdkRlb0gtaW1hZ2VzXzE3NTAyMTAwNzgwODVfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwzZHBjbVZtY21GdFpWOXdjbTlxWldOMFgySnZZWEprLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc2NzIyNTYwMH19fV19&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=UvyCJOygazdD~Pr4J2sygbil3eyLjFZt6-6HN17knTqouFz29x91tGbCntJmjRM3P9G2EbACZo8I879QRFmEiceRPsZYkvxBgsTqoFb1ECJrXEXCKQAD7XMPvKtJjx9LrABjRrN9U4wmG7jJaOJfET9iL6bB8jtAed32NYg3b2Sm84YIwIkK0GLr4Oo17bf7TQBaqnwSwsjlrKDvegu6r6i2iwy8-lj4lBwVdtxapktfetGp8gsHQ2O2jixN5FyA0i3A4fKZ9YcM3WYTTmqIoOf8LIZ~8NWgwwgqnqVv1y9j~EUYBfWdKv~N7J5veSpci3S4BJLM-4bzNjhW81Crow__)

**Mô tả:**
- Header với tên dự án và menu
- 3 cột chính: "To Do", "In Progress", "Done"
- Các task card với thông tin: tiêu đề, mô tả ngắn, độ ưu tiên, người được giao
- Nút "Add Task" ở cuối mỗi cột

**Thành phần chính:**
- Project header
- Kanban columns
- Task cards với drag & drop
- Priority indicators
- Assignee avatars
- Add task buttons

### 3. Màn hình Task Detail
![Task Detail Wireframe](https://private-us-east-1.manuscdn.com/sessionFile/K2i9e1zhPNUItwg00MCKYT/sandbox/RMv1HR89ul2dfRoeJvDeoH-images_1750210078086_na1fn_L2hvbWUvdWJ1bnR1L3dpcmVmcmFtZV90YXNrX2RldGFpbA.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvSzJpOWUxemhQTlVJdHdnMDBNQ0tZVC9zYW5kYm94L1JNdjFIUjg5dWwyZGZSb2VKdkRlb0gtaW1hZ2VzXzE3NTAyMTAwNzgwODZfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwzZHBjbVZtY21GdFpWOTBZWE5yWDJSbGRHRnBiQS5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NjcyMjU2MDB9fX1dfQ__&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=IUDRGUZN2mfHa60MK9ckf0dHoAFHkjWYOrRJPw2CChZq7p-sbQnrd04kmK6i4B21H3zDwmLS1Nf2BnPQiE-zVYGEdR7r1dExa2iSaPPZkx4t48YtfVDRf~Wy2vjU6AUWhgDQ57mUce~txvbJjCo7CL~JOTqm5mHR4nLPHCvJ~DLh7PURiPx50w0QCEyd2c-jy3l63fV2f~Sbp7t39i0MdBqh460U0wVeqom58JNDCcJpg6DNd0AjsovJzIer~1hmdWbg21XwyTBYaeavLIkpDKyqsds9BvhHeCm5j0Hps~Dst6KeaHwgBMjF5Pzl35iTSASAgQ~jLjz6ZiD~6e1hOA__)

**Mô tả:**
- Header với nút back và tiêu đề task
- Form chi tiết với các trường: Status, Assignee, Due Date, Priority, Progress
- Khu vực comments với avatar và message bubbles
- Khu vực attachments với nút upload
- Action buttons ở cuối

**Thành phần chính:**
- Task information form
- Status dropdown
- Date picker
- Priority selector
- Progress slider
- Comments section
- File attachments
- Action buttons

## Luồng người dùng (User Flow)

### 1. Luồng đăng nhập
1. Splash screen → Login screen
2. Nhập email/password → Xác thực
3. Thành công → Dashboard

### 2. Luồng quản lý dự án
1. Dashboard → Chọn dự án → Project Board
2. Project Board → Tạo task mới → Task Detail
3. Task Detail → Chỉnh sửa thông tin → Lưu

### 3. Luồng cộng tác
1. Task Detail → Thêm comment → Gửi
2. Task Detail → @mention người dùng → Thông báo
3. Task Detail → Upload file → Chia sẻ

## Responsive Design

### Breakpoints
- **Small phones:** 320-480px
- **Large phones:** 480-768px
- **Tablets:** 768-1024px (landscape mode)

### Adaptive Layout
- Sử dụng Flutter's responsive widgets
- Điều chỉnh số cột trong grid layout theo kích thước màn hình
- Ẩn/hiện các thành phần phụ trên màn hình nhỏ

## Accessibility

### 1. Contrast và Visibility
- Tỷ lệ contrast tối thiểu 4.5:1 cho văn bản thường
- Tỷ lệ contrast tối thiểu 3:1 cho văn bản lớn
- Hỗ trợ dark mode

### 2. Touch Targets
- Kích thước tối thiểu 44x44dp cho tất cả interactive elements
- Khoảng cách tối thiểu 8dp giữa các touch targets

### 3. Screen Reader Support
- Semantic labels cho tất cả UI elements
- Proper heading hierarchy
- Alternative text cho images

## Animation và Micro-interactions

### 1. Transitions
- Page transitions: 300ms ease-in-out
- Card animations: 200ms ease-out
- Button press feedback: 100ms

### 2. Loading States
- Skeleton screens cho loading content
- Progress indicators cho long-running operations
- Pull-to-refresh animation

### 3. Feedback
- Haptic feedback cho important actions
- Visual feedback cho button presses
- Success/error animations cho form submissions

