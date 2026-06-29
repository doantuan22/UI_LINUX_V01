# TASK 02 - Chuẩn hóa font và ngôn ngữ

## Mục tiêu

UI không còn chữ quá nhỏ, không lẫn tiếng Anh/Việt không cần thiết.

## Việc cần làm

1. Chuẩn hóa font size trong `Theme.qml` hoặc `Metrics.qml`.
2. Cập nhật các label:
   - `Performance Mode` -> `Chế độ hiệu năng`
   - `Download` -> `Tải xuống`
   - `Upload` -> `Tải lên`
   - `Monitor • Optimize • Protect` -> `Giám sát • Tối ưu • Bảo vệ`
3. Tăng size các title/subtitle quá nhỏ.
4. Text phụ dùng `textSecondary`, không dùng màu quá mờ.
5. Với text dài, dùng:
   - `elide: Text.ElideRight`
   - `maximumLineCount`
   - hoặc `wrapMode`.

## Acceptance criteria

- Ngôn ngữ UI thống nhất, ưu tiên tiếng Việt.
- Không còn text quá nhỏ khó đọc.
- Text phụ rõ hơn.
