import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services"

PopupWindow {
  id: launcher

  required property var anchorWindow
  property bool open: false

  anchor.window: anchorWindow
  anchor.rect.x: parentWindow ? Math.round(parentWindow.width / 2 - implicitWidth / 2) : 0
  anchor.rect.y: parentWindow ? Math.round(parentWindow.height + 8) : 8

  implicitWidth: 760
  implicitHeight: 520
  visible: open
  color: "transparent"

  onVisibleChanged: {
    if (visible) {
      filterInput.text = ""
      refillModel("")
      Qt.callLater(() => filterInput.forceActiveFocus())
    }
  }

  function refillModel(query) {
    appModel.clear()
    const results = AppIndex.search(query)
    for (const app of results) {
      const desktopId = (app.id || "").replace(/\.desktop$/i, "")
      appModel.append({
        name: app.name || "",
        genericName: app.genericName || "",
        comment: app.comment || "",
        icon: app.icon || "",
        desktopId: desktopId
      })
    }
    appList.currentIndex = appModel.count > 0 ? 0 : -1
  }

  function launchCurrent() {
    if (appList.currentIndex < 0 || appList.currentIndex >= appModel.count) return
    const app = appModel.get(appList.currentIndex)
    if (!app.desktopId) return

    launchProc.command = ["gtk-launch", app.desktopId]
    launchProc.running = true
    AppIndex.noteLaunch(app.desktopId)
    open = false
  }

  ListModel { id: appModel }

  Process {
    id: launchProc
    command: []
    running: false
  }

  Connections {
    target: AppIndex
    function onApplicationsChanged() {
      if (launcher.visible)
        launcher.refillModel(filterInput.text)
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: 14
    color: "#ee111111"
    border.width: 1
    border.color: "#33ffffff"

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 10

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 42
        radius: 10
        color: "#222222"

        TextInput {
          id: filterInput
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          color: "#f5f5f5"
          font.pixelSize: 16
          clip: true
          selectByMouse: true

          onTextChanged: launcher.refillModel(text)
          Keys.forwardTo: [launcher]
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 12
          text: "Buscar aplicativos..."
          color: "#77ffffff"
          font.pixelSize: 15
          visible: filterInput.text.length === 0
        }
      }

      ListView {
        id: appList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: appModel

        delegate: Rectangle {
          required property int index
          required property string name
          required property string genericName
          required property string comment
          required property string icon

          width: ListView.view.width
          implicitHeight: 54
          radius: 8
          color: ListView.isCurrentItem ? "#335577aa" : "transparent"

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Rectangle {
              implicitWidth: 30
              implicitHeight: 30
              radius: 8
              color: "#2a2a2a"

              Image {
                anchors.fill: parent
                anchors.margins: 4
                fillMode: Image.PreserveAspectFit
                source: icon && icon.length > 0
                  ? Quickshell.iconPath(icon, "application-x-executable")
                  : ""
              }

              Text {
                anchors.centerIn: parent
                text: (name && name.length > 0) ? name.charAt(0).toUpperCase() : "A"
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
                visible: !icon || icon.length === 0
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text {
                text: name
                color: "#ffffff"
                font.pixelSize: 14
                elide: Text.ElideRight
                Layout.fillWidth: true
              }

              Text {
                text: genericName || comment
                color: "#bbbbbb"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: appList.currentIndex = index
            onClicked: {
              appList.currentIndex = index
              launcher.launchCurrent()
            }
          }
        }
      }
    }
  }
}
