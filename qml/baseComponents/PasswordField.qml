import QtQuick
import QtQuick.Controls

Item {
    id: root
    implicitWidth: field.implicitWidth
    implicitHeight: field.implicitHeight

    property alias text: field.text
    property alias placeholder: field.placeholder
    property alias readOnly: field.readOnly
    property alias label: field.label
    property alias font: field.font
    property bool showPassword: false

    SuretyTextField {
        id: field
        anchors.fill: parent
        echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 20; height: 20
        source: root.showPassword ? "qrc:/qml/images/eye-open.svg" : "qrc:/qml/images/eye-closed.svg"
        sourceSize.width: 40; sourceSize.height: 40
        fillMode: Image.PreserveAspectFit
        smooth: true
        z: 1

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.showPassword = !root.showPassword
        }
    }
}
