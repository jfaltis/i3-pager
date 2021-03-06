import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Styles 1.3
import org.kde.plasma.plasmoid 2.0
import QtQuick.Window 2.13
import I3Pager 1.0

ColumnLayout {
    id: root
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Layout.fillHeight: true
    spacing: 0

    I3Pager {
        id: i3pager
        currentScreen: Screen.name
    }

    // Hack to update current screen
    Screen.onNameChanged: {
        i3pager.currentScreen = Screen.name
    }

    Row  {
        id: workspaceRow
        Layout.alignment: Layout.AlignVCenter | Layout.AlignHCenter
        spacing: 2

        Repeater {
            id: repeater
            model: i3pager.workspaces

            MouseArea {
                id: mouseArea
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { i3pager.activateWorkspace(modelData.id) }

                width: textRow.width
                height: root.height

                Rectangle {
                    function getColor() {
                        if(mouseArea.containsMouse && modelData.visible) {
                            return "#d19a66";
                        } else if (modelData.visible) {
                            return "#e5c07b";
                        } else if (mouseArea.containsMouse) {
                            return "#56b6c2";
                        }
                        return "transparent";
                    }
                    color: getColor()
                    height: 3
                    width: parent.width
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                }

                Rectangle {
                    color: "#bd2c40"
                    visible: modelData.urgent
                    height: textRow.height
                    width: textRow.width
                }

                RowLayout {
                    id: textRow
                    height: parent.height
                    Text {
                        leftPadding: 10
                        font.family: "Noto Sans"
                        height: textRow.height
                        minimumPixelSize: 10
                        font.pixelSize: 15
                        fontSizeMode: Text.VerticalFit
                        color: "#dfdfdf"
                        text: modelData.index
                        verticalAlignment: Text.AlignHCenter
                    }
                    Label {
                        id: icon
                        rightPadding: 3
                        leftPadding: 3
                        bottomPadding: 0
                        height: textRow.height
                        minimumPixelSize: 10
                        font.pixelSize: 15
                        fontSizeMode: Text.VerticalFit
                        font.family: "Font Awesome 5 Free Solid"
                        font.styleName: "Solid"
                        color: "#dfdfdf"
                        text: modelData.icon
                        verticalAlignment: Text.AlignHCenter
                    }
                    Text {
                        rightPadding: 10
                        height: textRow.height
                        minimumPixelSize: 10
                        font.pixelSize: 15
                        fontSizeMode: Text.VerticalFit
                        font.family: "Noto Sans"
                        color: "#dfdfdf"
                        text: modelData.name
                        verticalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        Item {
            width: modeText.width
            height: modeText.height
            anchors.verticalCenter: parent.verticalCenter
            visible: i3pager.mode != "default"
            Rectangle {
                color: "#e5c07b"
                height: parent.height
                width: parent.width
            }
            Text {
                id: modeText
                rightPadding: 10
                leftPadding: 10
                minimumPixelSize: 10
                font.pixelSize: 15
                fontSizeMode: Text.VerticalFit
                font.family: "Noto Sans"
                color: "#333333"
                text: i3pager.mode
            }
        }
    }
}
