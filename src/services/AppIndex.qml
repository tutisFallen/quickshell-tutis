pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property var apps: []
  readonly property string scriptPath: Qt.resolvedUrl("../../scripts/list_apps.py").toString().replace("file://", "")

  function reload() {
    appScan.running = true
  }

  Process {
    id: appScan
    command: ["python3", root.scriptPath]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.apps = JSON.parse(this.text)
        } catch (e) {
          console.warn(`AppIndex parse error: ${e}`)
          root.apps = []
        }
      }
    }
  }
}
