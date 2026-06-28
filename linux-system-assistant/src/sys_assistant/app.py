from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QSystemTrayIcon

from sys_assistant.bridge import SysAssistantBridge
from sys_assistant.services.logger_service import LoggerService
from sys_assistant.services.notification_service import NotificationService


def run() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Linux System Assistant")
    app.setOrganizationName("linux-system-assistant")
    app.setQuitOnLastWindowClosed(False)

    logger = LoggerService()
    logger.info("Application starting")

    bridge = SysAssistantBridge()
    bridge.start_polling()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("sysBridge", bridge)

    qml_root = Path(__file__).resolve().parent / "ui" / "qml"
    engine.addImportPath(str(qml_root))

    main_qml = qml_root / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(main_qml)))

    if not engine.rootObjects():
        logger.error("Failed to load QML")
        return 1

    if QSystemTrayIcon.isSystemTrayAvailable():
        tray = QSystemTrayIcon(QIcon.fromTheme("utilities-system-monitor"))
        tray.setToolTip("Linux System Assistant")
        tray.show()
        notifications = NotificationService(logger)
        notifications.attach_tray(tray)

    return app.exec()
