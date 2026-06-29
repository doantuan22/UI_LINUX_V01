# Protocol 05 — Bug Logging & Evidence

## Mục tiêu

Mọi lỗi phải được ghi lại đủ thông tin để người khác có thể hiểu, tái hiện và sửa.

## Quy tắc ghi lỗi

Mỗi lỗi là một bản ghi riêng.

Không gộp nhiều lỗi khác loại vào một bug.

Ví dụ sai:

```text
UI lỗi, app lag, log có warning.
```

Ví dụ đúng:

```text
BUG-001: Nút Ẩn app bị tràn khỏi panel Công cụ hệ thống.
BUG-002: App dùng CPU 90% khi không thao tác.
BUG-003: Console báo TypeError khi mở Process Manager.
```

## Format bắt buộc

```text
ID: BUG-xxx
Title:
Severity: S0/S1/S2/S3/S4
Category: System/UI/Backend/Frontend/Performance/Dependency/Data/Security
Environment:
Precondition:
Steps to reproduce:
Expected result:
Actual result:
Evidence:
Frequency:
Suspected root cause:
Fix plan:
Regression tests:
Status:
```

## Tiêu chí bằng chứng tốt

Bằng chứng tốt phải:

- Ngắn nhưng đủ.
- Có thời điểm hoặc phiên test.
- Có output/log/screenshot.
- Có đường dẫn file nếu liên quan code.
- Có command nếu là lỗi terminal.

## Trạng thái bug

| Status | Ý nghĩa |
|---|---|
| New | Vừa phát hiện, chưa phân tích |
| Confirmed | Đã tái hiện được |
| Investigating | Đang khoanh vùng |
| Fixed | Đã sửa |
| Verified | Đã test lại và xác nhận |
| Won't fix | Không sửa, có lý do |
| Blocked | Bị chặn bởi thiếu quyền/thông tin/dependency |

## Quy tắc severity

- Crash hoặc mất dữ liệu: S0.
- Chức năng chính không chạy: S1.
- Chức năng phụ lỗi hoặc UI ảnh hưởng sử dụng: S2.
- Lỗi nhỏ không chặn sử dụng: S3.
- Gợi ý tối ưu/cảnh báo nhẹ: S4.
