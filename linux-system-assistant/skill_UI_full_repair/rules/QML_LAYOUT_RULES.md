# QML Layout Rules

1. Panel phải có `clip: true`.
2. Nội dung dài phải có `ScrollView` hoặc `ListView`.
3. Text dài:
   - một dòng: `elide: Text.ElideRight`
   - nhiều dòng: `wrapMode: Text.WordWrap`
4. Button không được tự kéo rộng vượt parent.
5. Table/list phải có column width rõ ràng.
6. Row hover/pressed không được làm thay đổi kích thước.
7. Không dùng width/height quá nhỏ cho nội dung tiếng Việt.
8. Dùng `anchors.margins` hoặc `padding` nhất quán.
9. Không để content sát mép panel.
10. Nếu panel nằm dưới cùng, kiểm tra không bị cắt bởi screen bounds.
