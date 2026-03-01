import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "./widgets"
import "./services"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 36
      color: "#d9101010"

      SystemClock {
        id: clock
        precision: SystemClock.Seconds
      }

      AppLauncher {
        id: appLauncher
        anchorWindow: bar
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        RowLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter
          spacing: 8

          Repeater {
            model: Hyprland.workspaces

            Rectangle {
              required property var modelData

              radius: 8
              implicitWidth: 34
              implicitHeight: 24

              color: modelData.focused
                ? "#66a3ff"
                : modelData.active
                  ? "#335577aa"
                  : "#331f1f1f"

              border.width: modelData.urgent ? 1 : 0
              border.color: "#ff5a5a"

              Text {
                anchors.centerIn: parent
                text: modelData.name
                color: "#f5f5f5"
                font.pixelSize: 12
                font.bold: modelData.focused
              }

              MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
                cursorShape: Qt.PointingHandCursor
              }
            }
          }
        }

        Item { Layout.fillWidth: true }

        RowLayout {
          spacing: 10
          Layout.alignment: Qt.AlignVCenter

          Rectangle {
            implicitWidth: 58
            implicitHeight: 26
            radius: 8
            color: "#331f1f1f"

            Text {
              anchors.centerIn: parent
              text: "Apps"
              color: "#f0f0f0"
              font.pixelSize: 12
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: appLauncher.open = !appLauncher.open
            }
          }

          Text {
            text: Qt.formatDateTime(clock.date, "ddd, dd MMM")
            color: "#dcdcdc"
            font.pixelSize: 13
          }

          Rectangle {
            width: 1
            height: 16
            color: "#55ffffff"
          }

          Text {
            text: Qt.formatDateTime(clock.date, "HH:mm:ss")
            color: "#ffffff"
            font.pixelSize: 15
            font.bold: true
          }
        }
      }
    }
  }
}
