# Tech Stack

## Stack chính

```text
Language:       Python 3.11+
GUI:            PySide6
UI language:    QML / Qt Quick
System stats:   psutil
Config:         YAML / JSON
Packaging:      PyInstaller hoặc Nuitka
Linux desktop:  KDE Plasma ưu tiên
```

## Python packages

Bắt buộc:

```txt
PySide6
psutil
PyYAML
```

Tùy chọn:

```txt
pynvml
pyinstaller
```

## Linux packages

Ubuntu/Kubuntu/Debian:

```bash
sudo apt install python3-pip python3-venv lm-sensors power-profiles-daemon
```

Tùy GPU:

```bash
sudo apt install mesa-utils
```

NVIDIA:

```bash
nvidia-smi
```

Lưu ý: `nvidia-smi` thường có sẵn khi driver NVIDIA proprietary được cài đúng.

## Công nghệ UI

Dùng QML/Qt Quick cho:

- Glass panel.
- Animation.
- Hover effect.
- Card layout.
- Circular gauge.
- Smooth popup.
- Toggle/switch.
- Table process.

Dùng Python/PySide6 cho:

- QApplication.
- QQmlApplicationEngine.
- QObject bridge.
- Signal/Slot.
- Data model.
- System access.

## Vì sao không dùng Electron?

Không ưu tiên Electron vì:

- Tốn RAM.
- Không hợp với app monitor nhẹ.
- Phụ thuộc Chromium.
- App dạng floating widget cần nhẹ và responsive.

## Vì sao không dùng GTK?

GTK cũng được, nhưng project ưu tiên KDE/Kubuntu, nên Qt/PySide6 hợp hơn về hệ sinh thái và giao diện.

## Vì sao chưa làm KDE Plasmoid ngay?

Plasmoid tích hợp sâu với KDE nhưng:

- Cần học QML/KDE API kỹ hơn.
- Khó portable sang desktop khác.
- Đóng gói phức tạp hơn cho người mới.

Do đó MVP nên dùng PySide6 + QML. Sau này có thể chuyển sang KDE Plasmoid.
