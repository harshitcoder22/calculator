import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import gnome.calculator 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 340
    height: 530
    minimumWidth: 340
    minimumHeight: 530
    maximumWidth: 340
    maximumHeight: 530
    title: "Qt Calculator"
    color: "#1e1e1e"

    Calculator { id: calc }

    Shortcut { sequence: "0"; onActivated: calc.input_digit("0") }
    Shortcut { sequence: "1"; onActivated: calc.input_digit("1") }
    Shortcut { sequence: "2"; onActivated: calc.input_digit("2") }
    Shortcut { sequence: "3"; onActivated: calc.input_digit("3") }
    Shortcut { sequence: "4"; onActivated: calc.input_digit("4") }
    Shortcut { sequence: "5"; onActivated: calc.input_digit("5") }
    Shortcut { sequence: "6"; onActivated: calc.input_digit("6") }
    Shortcut { sequence: "7"; onActivated: calc.input_digit("7") }
    Shortcut { sequence: "8"; onActivated: calc.input_digit("8") }
    Shortcut { sequence: "9"; onActivated: calc.input_digit("9") }
    Shortcut { sequence: "."; onActivated: calc.input_decimal() }
    Shortcut { sequence: ","; onActivated: calc.input_decimal() }
    Shortcut { sequence: "+"; onActivated: calc.set_operator("+") }
    Shortcut { sequence: "-"; onActivated: calc.set_operator("-") }
    Shortcut { sequence: "*"; onActivated: calc.set_operator("×") }
    Shortcut { sequence: "x"; onActivated: calc.set_operator("×") }
    Shortcut { sequence: "/"; onActivated: calc.set_operator("÷") }
    Shortcut { sequence: "="; onActivated: calc.calculate() }
    Shortcut { sequence: "Return"; onActivated: calc.calculate() }
    Shortcut { sequence: "Enter"; onActivated: calc.calculate() }
    Shortcut { sequence: "Backspace"; onActivated: calc.backspace() }
    Shortcut { sequence: "Delete"; onActivated: calc.clear_entry() }
    Shortcut { sequence: "Escape"; onActivated: calc.clear_all() }
    Shortcut { sequence: "%"; onActivated: calc.percentage() }

    Shortcut { sequence: "Ctrl+Alt+B"; onActivated: calc.change_mode("Basic") }
    Shortcut { sequence: "Ctrl+Alt+A"; onActivated: calc.change_mode("Advanced") }
    Shortcut { sequence: "Ctrl+Alt+F"; onActivated: calc.change_mode("Financial") }
    Shortcut { sequence: "Ctrl+Alt+P"; onActivated: calc.change_mode("Programming") }
    Shortcut { sequence: "Ctrl+Alt+K"; onActivated: calc.change_mode("Keyboard") }
    Shortcut { sequence: "Ctrl+Alt+C"; onActivated: calc.change_mode("Conversion") }

    Shortcut { sequence: "Ctrl+N"; onActivated: calc.clear_all() }
    Shortcut { sequence: "Ctrl+Escape"; onActivated: calc.clear_history() }
    Shortcut { sequence: "Ctrl+,"; onActivated: prefsDialog.open() }
    Shortcut { sequence: "Ctrl+?"; onActivated: shortcutsDialog.open() }
    Shortcut { sequence: "F1"; onActivated: helpDialog.open() }

    component CalcBtn : Button {
        property color bg: "#3c3c3c"
        property color fg: "#ffffff"
        property int fs: 16
        property bool bold: false
        Layout.fillWidth: true
        Layout.fillHeight: true

        background: Rectangle {
            color: parent.down ? Qt.darker(bg, 1.15) : bg
            radius: 5
        }
        contentItem: Text {
            text: parent.text
            color: parent.fg
            font.pixelSize: parent.fs
            font.bold: parent.bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    component RadioRow : ItemDelegate {
        property string label: ""
        property string shortcutText: ""
        property bool selected: false
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        background: Rectangle {
            color: parent.hovered ? "#3c3c3c" : "transparent"
            radius: 4
        }

        contentItem: RowLayout {
            spacing: 8
            Item { Layout.preferredWidth: 4 }
            Rectangle {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                radius: 7
                color: "transparent"
                border.color: parent.parent.selected ? "#ffffff" : "#777777"
                border.width: 1.5
                Rectangle {
                    anchors.centerIn: parent
                    width: 6; height: 6; radius: 3
                    color: "#ffffff"
                    visible: parent.parent.parent.selected
                }
            }
            Text {
                text: parent.parent.label
                color: "#ffffff"; font.pixelSize: 13
                Layout.fillWidth: true
            }
            Text {
                text: parent.parent.shortcutText
                color: "#888888"; font.pixelSize: 11
            }
            Item { Layout.preferredWidth: 4 }
        }
    }

    component MenuRow : ItemDelegate {
        property string label: ""
        property string shortcutText: ""
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        background: Rectangle {
            color: parent.hovered ? "#3c3c3c" : "transparent"
            radius: 4
        }

        contentItem: RowLayout {
            spacing: 8
            Item { Layout.preferredWidth: 10 }
            Text {
                text: parent.parent.label
                color: "#ffffff"; font.pixelSize: 13
                Layout.fillWidth: true
            }
            Text {
                text: parent.parent.shortcutText
                color: "#888888"; font.pixelSize: 11
            }
            Item { Layout.preferredWidth: 10 }
        }
    }

    component Separator : Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        color: "#444444"
    }

    Popup {
        id: modeMenu
        width: 230
        padding: 4

        property var modes: [
            { mode: "Basic",       shortcut: "Ctrl+Alt+B" },
            { mode: "Advanced",    shortcut: "Ctrl+Alt+A" },
            { mode: "Financial",   shortcut: "Ctrl+Alt+F" },
            { mode: "Programming", shortcut: "Ctrl+Alt+P" },
            { mode: "Keyboard",    shortcut: "Ctrl+Alt+K" },
            { mode: "Conversion",  shortcut: "Ctrl+Alt+C" }
        ]

        background: Rectangle {
            color: "#2e2e2e"; radius: 8
            border.color: "#555555"; border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 1
            Repeater {
                model: modeMenu.modes
                delegate: RadioRow {
                    label: modelData.mode
                    shortcutText: modelData.shortcut
                    selected: calc.mode === modelData.mode
                    onClicked: {
                        calc.change_mode(modelData.mode)
                        modeMenu.close()
                    }
                }
            }
        }
    }

    Popup {
        id: mainMenu
        width: 260
        padding: 4

        background: Rectangle {
            color: "#2e2e2e"; radius: 8
            border.color: "#555555"; border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 1

            MenuRow {
                label: "New Window"; shortcutText: "Ctrl+N"
                onClicked: { calc.clear_all(); mainMenu.close() }
            }
            MenuRow {
                label: "Clear History"; shortcutText: "Ctrl+Escape"
                onClicked: { calc.clear_history(); mainMenu.close() }
            }

            Separator {}

            MenuRow {
                label: "Mode: " + calc.mode; shortcutText: ""
                onClicked: { mainMenu.close(); openModeMenuFromMenu() }
            }

            Separator {}

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.topMargin: 4
                Layout.bottomMargin: 2
                text: "Result Format"
                color: "#bbbbbb"; font.pixelSize: 12; font.bold: true
            }
            RadioRow {
                label: "Automatic"
                selected: calc.result_format === "Automatic"
                onClicked: { calc.change_result_format("Automatic"); mainMenu.close() }
            }
            RadioRow {
                label: "Fixed"
                selected: calc.result_format === "Fixed"
                onClicked: { calc.change_result_format("Fixed"); mainMenu.close() }
            }
            RadioRow {
                label: "Scientific"
                selected: calc.result_format === "Scientific"
                onClicked: { calc.change_result_format("Scientific"); mainMenu.close() }
            }
            RadioRow {
                label: "Engineering"
                selected: calc.result_format === "Engineering"
                onClicked: { calc.change_result_format("Engineering"); mainMenu.close() }
            }

            Separator {}

            MenuRow {
                label: "Preferences"; shortcutText: "Ctrl+,"
                onClicked: { mainMenu.close(); prefsDialog.open() }
            }
            MenuRow {
                label: "Keyboard Shortcuts"; shortcutText: "Ctrl+?"
                onClicked: { mainMenu.close(); shortcutsDialog.open() }
            }

            Separator {}

            MenuRow {
                label: "Help"; shortcutText: "F1"
                onClicked: { mainMenu.close(); helpDialog.open() }
            }
            MenuRow {
                label: "About Calculator"
                onClicked: { mainMenu.close(); aboutDialog.open() }
            }
        }
    }

    function openModeMenuFromMenu() {
        let p = hamburgerBtn.mapToItem(root.contentItem, 0, hamburgerBtn.height + 2)
        modeMenu.x = p.x
        modeMenu.y = p.y
        modeMenu.open()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            Button {
                id: hamburgerBtn
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                onClicked: {
                    if (mainMenu.visible) { mainMenu.close() }
                    else {
                        let p = hamburgerBtn.mapToItem(root.contentItem, 0, hamburgerBtn.height + 2)
                        mainMenu.x = p.x
                        mainMenu.y = p.y
                        mainMenu.open()
                    }
                }
                background: Rectangle {
                    color: parent.down ? "#4a4a4a" : "#3c3c3c"
                    radius: 5; border.color: "#555555"; border.width: 1
                }
                contentItem: Text {
                    text: "☰"; color: "#ffffff"; font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                text: calc.mode
                color: "#dddddd"
                font.pixelSize: 14
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 95
            color: "#1e1e1e"
            border.color: "#3c3c3c"
            border.width: 2
            radius: 6
            visible: calc.mode !== "Keyboard"

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 12
                anchors.bottomMargin: 12
                text: calc.display
                color: "#ffffff"
                font.pixelSize: 30
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 8
                text: "⌫"
                color: "#767676"
                font.pixelSize: 12
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calc.backspace()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 95
            color: "#1e1e1e"
            border.color: "#3c3c3c"
            border.width: 2
            radius: 6
            visible: calc.mode === "Keyboard"

            TextField {
                id: kbField
                anchors.fill: parent
                anchors.margins: 8
                text: calc.keyboard_expr
                color: "#ffffff"
                placeholderText: "e.g. 2+3*4 or sin(pi/2)"
                placeholderTextColor: "#666666"
                font.pixelSize: 16
                background: Rectangle { color: "transparent" }
                onTextEdited: calc.update_keyboard_expr(text)
                Keys.onReturnPressed: calc.evaluate_keyboard()
                Keys.onEnterPressed: calc.evaluate_keyboard()
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: {
                switch (calc.mode) {
                    case "Basic": return 0;
                    case "Advanced": return 1;
                    case "Financial": return 2;
                    case "Programming": return 3;
                    case "Keyboard": return 4;
                    case "Conversion": return 5;
                }
                return 0;
            }

            GridLayout {
                columns: 5; rowSpacing: 5; columnSpacing: 5
                CalcBtn { text: "C";  bg: "#767676"; fs: 15; onClicked: calc.clear_all() }
                CalcBtn { text: "⌫";  bg: "#767676"; fs: 15; onClicked: calc.backspace() }
                CalcBtn { text: "÷";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("÷") }
                CalcBtn { text: "×";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("×") }
                CalcBtn { text: "%";  bg: "#767676"; fs: 15; onClicked: calc.percentage() }
                CalcBtn { text: "7"; onClicked: calc.input_digit("7") }
                CalcBtn { text: "8"; onClicked: calc.input_digit("8") }
                CalcBtn { text: "9"; onClicked: calc.input_digit("9") }
                CalcBtn { text: "−";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("-") }
                CalcBtn { text: "±";  bg: "#767676"; fs: 15; onClicked: calc.toggle_sign() }
                CalcBtn { text: "4"; onClicked: calc.input_digit("4") }
                CalcBtn { text: "5"; onClicked: calc.input_digit("5") }
                CalcBtn { text: "6"; onClicked: calc.input_digit("6") }
                CalcBtn { text: "+";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("+") }
                CalcBtn { text: "√";  bg: "#767676"; fs: 15; onClicked: calc.apply_unary("sqrt") }
                CalcBtn { text: "1"; onClicked: calc.input_digit("1") }
                CalcBtn { text: "2"; onClicked: calc.input_digit("2") }
                CalcBtn { text: "3"; onClicked: calc.input_digit("3") }
                CalcBtn { text: "x²"; bg: "#767676"; fs: 15; onClicked: calc.apply_unary("sqr") }
                CalcBtn {
                    text: "="; bg: "#f5923e"; fs: 20; bold: true
                    Layout.rowSpan: 2
                    onClicked: calc.calculate()
                }
                CalcBtn { text: "0"; onClicked: calc.input_digit("0") }
                CalcBtn { text: "."; onClicked: calc.input_decimal() }
                CalcBtn { text: "1/x"; bg: "#767676"; fs: 13; onClicked: calc.apply_unary("inv") }
                CalcBtn { text: "n!";  bg: "#767676"; fs: 13; onClicked: calc.apply_unary("fact") }
            }

            ColumnLayout {
                spacing: 5
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5; Layout.fillWidth: true
                    CalcBtn { text: "sin"; bg: "#767676"; fs: 12; onClicked: calc.apply_unary("sin") }
                    CalcBtn { text: "cos"; bg: "#767676"; fs: 12; onClicked: calc.apply_unary("cos") }
                    CalcBtn { text: "tan"; bg: "#767676"; fs: 12; onClicked: calc.apply_unary("tan") }
                    CalcBtn { text: "ln";  bg: "#767676"; fs: 12; onClicked: calc.apply_unary("ln") }
                    CalcBtn { text: "log"; bg: "#767676"; fs: 12; onClicked: calc.apply_unary("log") }
                    CalcBtn { text: "asin"; bg: "#767676"; fs: 11; onClicked: calc.apply_unary("asin") }
                    CalcBtn { text: "acos"; bg: "#767676"; fs: 11; onClicked: calc.apply_unary("acos") }
                    CalcBtn { text: "atan"; bg: "#767676"; fs: 11; onClicked: calc.apply_unary("atan") }
                    CalcBtn { text: "π";    bg: "#767676"; fs: 14; onClicked: calc.insert_constant("pi") }
                    CalcBtn { text: "e";    bg: "#767676"; fs: 14; onClicked: calc.insert_constant("e") }
                    CalcBtn { text: "|x|"; bg: "#767676"; fs: 12; onClicked: calc.apply_unary("abs") }
                    CalcBtn { text: "x²";  bg: "#767676"; fs: 14; onClicked: calc.apply_unary("sqr") }
                    CalcBtn { text: "x³";  bg: "#767676"; fs: 14; onClicked: calc.apply_unary("cube") }
                    CalcBtn { text: "1/x"; bg: "#767676"; fs: 12; onClicked: calc.apply_unary("inv") }
                    CalcBtn { text: "n!";  bg: "#767676"; fs: 14; onClicked: calc.apply_unary("fact") }
                }
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5
                    Layout.fillWidth: true; Layout.fillHeight: true
                    CalcBtn { text: "C";  bg: "#767676"; fs: 15; onClicked: calc.clear_all() }
                    CalcBtn { text: "⌫";  bg: "#767676"; fs: 15; onClicked: calc.backspace() }
                    CalcBtn { text: "÷";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("÷") }
                    CalcBtn { text: "×";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("×") }
                    CalcBtn { text: "%";  bg: "#767676"; fs: 15; onClicked: calc.percentage() }
                    CalcBtn { text: "7"; onClicked: calc.input_digit("7") }
                    CalcBtn { text: "8"; onClicked: calc.input_digit("8") }
                    CalcBtn { text: "9"; onClicked: calc.input_digit("9") }
                    CalcBtn { text: "−";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("-") }
                    CalcBtn { text: "±";  bg: "#767676"; fs: 15; onClicked: calc.toggle_sign() }
                    CalcBtn { text: "4"; onClicked: calc.input_digit("4") }
                    CalcBtn { text: "5"; onClicked: calc.input_digit("5") }
                    CalcBtn { text: "6"; onClicked: calc.input_digit("6") }
                    CalcBtn { text: "+";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("+") }
                    CalcBtn { text: "xʸ"; bg: "#767676"; fs: 14; onClicked: calc.set_operator("^") }
                    CalcBtn { text: "1"; onClicked: calc.input_digit("1") }
                    CalcBtn { text: "2"; onClicked: calc.input_digit("2") }
                    CalcBtn { text: "3"; onClicked: calc.input_digit("3") }
                    CalcBtn { text: "e"; bg: "#767676"; fs: 14; onClicked: calc.insert_constant("e") }
                    CalcBtn {
                        text: "="; bg: "#f5923e"; fs: 20; bold: true
                        Layout.rowSpan: 2
                        onClicked: calc.calculate()
                    }
                    CalcBtn { text: "0"; onClicked: calc.input_digit("0") }
                    CalcBtn { text: "."; onClicked: calc.input_decimal() }
                    CalcBtn { text: "("; bg: "#767676"; fs: 15; enabled: false }
                    CalcBtn { text: ")"; bg: "#767676"; fs: 15; enabled: false }
                }
            }

            ColumnLayout {
                spacing: 5
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5; Layout.fillWidth: true
                    CalcBtn { text: "Ctrm"; bg: "#767676"; fs: 12; onClicked: finDlg.ask("ctrm") }
                    CalcBtn { text: "Ddb";  bg: "#767676"; fs: 12; onClicked: finDlg.ask("ddb") }
                    CalcBtn { text: "Fv";   bg: "#767676"; fs: 12; onClicked: finDlg.ask("fv") }
                    CalcBtn { text: "Gpm";  bg: "#767676"; fs: 12; onClicked: finDlg.ask("gpm") }
                    CalcBtn { text: "Pmt";  bg: "#767676"; fs: 12; onClicked: finDlg.ask("pmt") }
                }
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5; Layout.fillWidth: true
                    CalcBtn { text: "Pv";   bg: "#767676"; fs: 12; onClicked: finDlg.ask("pv") }
                    CalcBtn { text: "Rate"; bg: "#767676"; fs: 12; onClicked: finDlg.ask("rate") }
                    CalcBtn { text: "Sln";  bg: "#767676"; fs: 12; onClicked: finDlg.ask("sln") }
                    CalcBtn { text: "Syd";  bg: "#767676"; fs: 12; onClicked: finDlg.ask("syd") }
                    CalcBtn { text: "Term"; bg: "#767676"; fs: 12; onClicked: finDlg.ask("nper") }
                }
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5
                    Layout.fillWidth: true; Layout.fillHeight: true
                    CalcBtn { text: "C";  bg: "#767676"; fs: 15; onClicked: calc.clear_all() }
                    CalcBtn { text: "⌫";  bg: "#767676"; fs: 15; onClicked: calc.backspace() }
                    CalcBtn { text: "÷";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("÷") }
                    CalcBtn { text: "×";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("×") }
                    CalcBtn { text: "%";  bg: "#767676"; fs: 15; onClicked: calc.percentage() }
                    CalcBtn { text: "7"; onClicked: calc.input_digit("7") }
                    CalcBtn { text: "8"; onClicked: calc.input_digit("8") }
                    CalcBtn { text: "9"; onClicked: calc.input_digit("9") }
                    CalcBtn { text: "−";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("-") }
                    CalcBtn { text: "±";  bg: "#767676"; fs: 15; onClicked: calc.toggle_sign() }
                    CalcBtn { text: "4"; onClicked: calc.input_digit("4") }
                    CalcBtn { text: "5"; onClicked: calc.input_digit("5") }
                    CalcBtn { text: "6"; onClicked: calc.input_digit("6") }
                    CalcBtn { text: "+";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("+") }
                    CalcBtn { text: "Ctrm"; bg: "#767676"; fs: 10; onClicked: finDlg.ask("ctrm") }
                    CalcBtn { text: "1"; onClicked: calc.input_digit("1") }
                    CalcBtn { text: "2"; onClicked: calc.input_digit("2") }
                    CalcBtn { text: "3"; onClicked: calc.input_digit("3") }
                    CalcBtn { text: "Pmt"; bg: "#767676"; fs: 10; onClicked: finDlg.ask("pmt") }
                    CalcBtn {
                        text: "="; bg: "#f5923e"; fs: 20; bold: true
                        Layout.rowSpan: 2
                        onClicked: calc.calculate()
                    }
                    CalcBtn { text: "0"; onClicked: calc.input_digit("0") }
                    CalcBtn { text: "."; onClicked: calc.input_decimal() }
                    CalcBtn { text: "("; bg: "#767676"; fs: 15; enabled: false }
                    CalcBtn { text: ")"; bg: "#767676"; fs: 15; enabled: false }
                }
            }

            ColumnLayout {
                spacing: 5
                RowLayout {
                    Layout.fillWidth: true; spacing: 5
                    Repeater {
                        model: ["HEX", "DEC", "OCT", "BIN"]
                        CalcBtn {
                            text: modelData
                            Layout.preferredHeight: 30
                            bg: calc.radix === modelData ? "#f5923e" : "#767676"
                            fs: 12
                            onClicked: calc.change_radix(modelData)
                        }
                    }
                }
                GridLayout {
                    columns: 6; rowSpacing: 5; columnSpacing: 5; Layout.fillWidth: true
                    CalcBtn { text: "AND"; bg: "#767676"; fs: 11; onClicked: calc.programming_op("AND") }
                    CalcBtn { text: "OR";  bg: "#767676"; fs: 11; onClicked: calc.programming_op("OR") }
                    CalcBtn { text: "XOR"; bg: "#767676"; fs: 11; onClicked: calc.programming_op("XOR") }
                    CalcBtn { text: "NOT"; bg: "#767676"; fs: 11; onClicked: calc.apply_unary("not") }
                    CalcBtn { text: "<<";  bg: "#767676"; fs: 13; onClicked: calc.programming_op("<<") }
                    CalcBtn { text: ">>";  bg: "#767676"; fs: 13; onClicked: calc.programming_op(">>") }
                }
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5
                    Layout.fillWidth: true; Layout.fillHeight: true
                    CalcBtn { text: "C";  bg: "#767676"; fs: 15; onClicked: calc.clear_all() }
                    CalcBtn { text: "⌫";  bg: "#767676"; fs: 15; onClicked: calc.backspace() }
                    CalcBtn { text: "÷";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("÷") }
                    CalcBtn { text: "×";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("×") }
                    CalcBtn { text: "mod"; bg: "#767676"; fs: 12; onClicked: calc.percentage() }
                    CalcBtn { text: "7"; onClicked: calc.input_digit("7") }
                    CalcBtn { text: "8"; onClicked: calc.input_digit("8") }
                    CalcBtn { text: "9"; onClicked: calc.input_digit("9") }
                    CalcBtn { text: "−";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("-") }
                    CalcBtn { text: "%";  bg: "#767676"; fs: 15; onClicked: calc.percentage() }
                    CalcBtn { text: "4"; onClicked: calc.input_digit("4") }
                    CalcBtn { text: "5"; onClicked: calc.input_digit("5") }
                    CalcBtn { text: "6"; onClicked: calc.input_digit("6") }
                    CalcBtn { text: "+";  bg: "#f5923e"; fs: 18; bold: true; onClicked: calc.set_operator("+") }
                    CalcBtn { text: "("; bg: "#767676"; fs: 15; enabled: false }
                    CalcBtn { text: "1"; onClicked: calc.input_digit("1") }
                    CalcBtn { text: "2"; onClicked: calc.input_digit("2") }
                    CalcBtn { text: "3"; onClicked: calc.input_digit("3") }
                    CalcBtn { text: "e"; bg: "#767676"; fs: 14; onClicked: calc.insert_constant("e") }
                    CalcBtn {
                        text: "="; bg: "#f5923e"; fs: 20; bold: true
                        Layout.rowSpan: 2
                        onClicked: calc.calculate()
                    }
                    CalcBtn { text: "0"; onClicked: calc.input_digit("0") }
                    CalcBtn { text: "."; onClicked: calc.input_decimal() }
                    CalcBtn { text: "("; bg: "#767676"; fs: 15; enabled: false }
                    CalcBtn { text: ")"; bg: "#767676"; fs: 15; enabled: false }
                }
            }

            ColumnLayout {
                spacing: 5
                CalcBtn {
                    text: "Calculate"; bg: "#f5923e"; fs: 16; bold: true
                    Layout.preferredHeight: 40; Layout.fillWidth: true
                    onClicked: {
                        calc.update_keyboard_expr(kbField.text)
                        calc.evaluate_keyboard()
                    }
                }
                CalcBtn {
                    text: "Clear"; bg: "#767676"; fs: 14
                    Layout.preferredHeight: 32; Layout.fillWidth: true
                    onClicked: calc.clear_all()
                }
                Item { Layout.fillHeight: true }
                Text {
                    Layout.fillWidth: true
                    text: "Supported: +  -  *  /  %  ^  ( )\n" +
                          "Functions: sin, cos, tan, sqrt, ln, log, abs\n" +
                          "Constants: pi, e"
                    color: "#777777"; font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ColumnLayout {
                spacing: 6
                ComboBox {
                    id: catCombo
                    Layout.fillWidth: true; Layout.preferredHeight: 30
                    model: ["Length", "Mass", "Temperature", "Time"]
                    background: Rectangle { color: "#3c3c3c"; radius: 5; border.color: "#555555" }
                    contentItem: Text {
                        leftPadding: 10; text: catCombo.displayText
                        color: "#ffffff"; font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                    }
                    indicator: Text {
                        x: catCombo.width - width - 8
                        y: (catCombo.height - height) / 2
                        text: "▾"; color: "#ffffff"; font.pixelSize: 11
                    }
                    popup: Popup {
                        y: catCombo.height; width: catCombo.width
                        implicitHeight: contentItem.implicitHeight; padding: 1
                        background: Rectangle { color: "#3c3c3c"; radius: 5; border.color: "#555555" }
                        contentItem: ListView {
                            clip: true; implicitHeight: contentHeight
                            model: catCombo.popup.visible ? catCombo.delegateModel : null
                            currentIndex: catCombo.highlightedIndex
                        }
                    }
                    delegate: ItemDelegate {
                        width: catCombo.width
                        contentItem: Text {
                            text: modelData; color: "#ffffff"; font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle { color: highlighted ? "#f5923e" : "transparent" }
                        highlighted: catCombo.highlightedIndex === index
                    }
                    property var unitsByCat: ({
                        "Length": ["mm","cm","m","km","in","ft","yd","mi"],
                        "Mass": ["mg","g","kg","t","oz","lb","st"],
                        "Temperature": ["C","F","K"],
                        "Time": ["ms","s","min","h","day","week"]
                    })
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    ComboBox {
                        id: fromCombo
                        Layout.fillWidth: true; Layout.preferredHeight: 30
                        model: catCombo.unitsByCat[catCombo.currentText] || []
                        background: Rectangle { color: "#3c3c3c"; radius: 5; border.color: "#555555" }
                        contentItem: Text {
                            leftPadding: 10; text: fromCombo.displayText
                            color: "#ffffff"; font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }
                        indicator: Text {
                            x: fromCombo.width - width - 8
                            y: (fromCombo.height - height) / 2
                            text: "▾"; color: "#ffffff"; font.pixelSize: 11
                        }
                        popup: Popup {
                            y: fromCombo.height; width: fromCombo.width
                            implicitHeight: contentItem.implicitHeight; padding: 1
                            background: Rectangle { color: "#3c3c3c"; radius: 5; border.color: "#555555" }
                            contentItem: ListView {
                                clip: true; implicitHeight: contentHeight
                                model: fromCombo.popup.visible ? fromCombo.delegateModel : null
                                currentIndex: fromCombo.highlightedIndex
                            }
                        }
                        delegate: ItemDelegate {
                            width: fromCombo.width
                            contentItem: Text {
                                text: modelData; color: "#ffffff"; font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { color: highlighted ? "#f5923e" : "transparent" }
                            highlighted: fromCombo.highlightedIndex === index
                        }
                    }
                    Text { text: "→"; color: "#ffffff"; font.pixelSize: 18 }
                    ComboBox {
                        id: toCombo
                        Layout.fillWidth: true; Layout.preferredHeight: 30
                        model: catCombo.unitsByCat[catCombo.currentText] || []
                        currentIndex: 1
                        background: Rectangle { color: "#3c3c3c"; radius: 5; border.color: "#555555" }
                        contentItem: Text {
                            leftPadding: 10; text: toCombo.displayText
                            color: "#ffffff"; font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }
                        indicator: Text {
                            x: toCombo.width - width - 8
                            y: (toCombo.height - height) / 2
                            text: "▾"; color: "#ffffff"; font.pixelSize: 11
                        }
                        popup: Popup {
                            y: toCombo.height; width: toCombo.width
                            implicitHeight: contentItem.implicitHeight; padding: 1
                            background: Rectangle { color: "#3c3c3c"; radius: 5; border.color: "#555555" }
                            contentItem: ListView {
                                clip: true; implicitHeight: contentHeight
                                model: toCombo.popup.visible ? toCombo.delegateModel : null
                                currentIndex: toCombo.highlightedIndex
                            }
                        }
                        delegate: ItemDelegate {
                            width: toCombo.width
                            contentItem: Text {
                                text: modelData; color: "#ffffff"; font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { color: highlighted ? "#f5923e" : "transparent" }
                            highlighted: toCombo.highlightedIndex === index
                        }
                    }
                }
                CalcBtn {
                    text: "Convert current value"; bg: "#f5923e"; fs: 14; bold: true
                    Layout.preferredHeight: 36; Layout.fillWidth: true
                    onClicked: {
                        let v = parseFloat(calc.display)
                        if (isNaN(v)) v = 0
                        calc.convert(catCombo.currentText, fromCombo.currentText, toCombo.currentText, v)
                    }
                }
                GridLayout {
                    columns: 5; rowSpacing: 5; columnSpacing: 5
                    Layout.fillWidth: true; Layout.fillHeight: true
                    CalcBtn { text: "C";  bg: "#767676"; fs: 15; onClicked: calc.clear_all() }
                    CalcBtn { text: "⌫";  bg: "#767676"; fs: 15; onClicked: calc.backspace() }
                    CalcBtn { text: "7"; onClicked: calc.input_digit("7") }
                    CalcBtn { text: "8"; onClicked: calc.input_digit("8") }
                    CalcBtn { text: "9"; onClicked: calc.input_digit("9") }
                    CalcBtn { text: "4"; onClicked: calc.input_digit("4") }
                    CalcBtn { text: "5"; onClicked: calc.input_digit("5") }
                    CalcBtn { text: "6"; onClicked: calc.input_digit("6") }
                    CalcBtn { text: "1"; onClicked: calc.input_digit("1") }
                    CalcBtn { text: "2"; onClicked: calc.input_digit("2") }
                    CalcBtn { text: "3"; onClicked: calc.input_digit("3") }
                    CalcBtn { text: "0"; onClicked: calc.input_digit("0") }
                    CalcBtn { text: "±"; bg: "#767676"; fs: 15; onClicked: calc.toggle_sign() }
                    CalcBtn { text: "."; onClicked: calc.input_decimal() }
                    CalcBtn {
                        text: "="; bg: "#f5923e"; fs: 18; bold: true
                        Layout.rowSpan: 2
                        onClicked: {
                            let v = parseFloat(calc.display)
                            if (isNaN(v)) v = 0
                            calc.convert(catCombo.currentText, fromCombo.currentText, toCombo.currentText, v)
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: finDlg
        anchors.centerIn: parent
        width: 320
        modal: true
        padding: 16
        property string currentFunc: ""

        function ask(func) {
            currentFunc = func
            finField.text = ""
            open()
            finField.forceActiveFocus()
        }

        background: Rectangle {
            color: "#2e2e2e"; radius: 8
            border.color: "#555555"; border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 10
            Text {
                text: "Enter comma-separated arguments for " + finDlg.currentFunc
                color: "#ffffff"; font.pixelSize: 12
                wrapMode: Text.WordWrap; Layout.fillWidth: true
            }
            TextField {
                id: finField
                Layout.fillWidth: true; Layout.preferredHeight: 32
                color: "#ffffff"
                placeholderText: "e.g. 0.05, 12, 1000"
                placeholderTextColor: "#666666"
                font.pixelSize: 14
                background: Rectangle {
                    color: "#1e1e1e"; radius: 4; border.color: "#555555"
                }
                Keys.onReturnPressed: {
                    calc.financial(finDlg.currentFunc, finField.text)
                    finDlg.close()
                }
            }
            RowLayout {
                spacing: 8; Layout.fillWidth: true
                CalcBtn {
                    text: "Cancel"; bg: "#767676"; fs: 13
                    Layout.preferredHeight: 30
                    onClicked: finDlg.close()
                }
                CalcBtn {
                    text: "Calculate"; bg: "#f5923e"; fs: 13; bold: true
                    Layout.preferredHeight: 30
                    onClicked: {
                        calc.financial(finDlg.currentFunc, finField.text)
                        finDlg.close()
                    }
                }
            }
        }
    }

    component InfoDialog : Dialog {
        id: infoRoot
        property string headerText: ""
        property string bodyText: ""
        anchors.centerIn: parent
        width: 300
        modal: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#2e2e2e"; radius: 8
            border.color: "#555555"; border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#2e2e2e"
                radius: 8
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#444444"
                }
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    text: infoRoot.headerText
                    color: "#ffffff"; font.pixelSize: 15; font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 14
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 260
                    text: infoRoot.bodyText
                    color: "#dddddd"; font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                CalcBtn {
                    text: "Close"; bg: "#f5923e"; fs: 13; bold: true
                    Layout.preferredHeight: 30
                    Layout.fillWidth: true
                    Layout.maximumWidth: 120
                    Layout.alignment: Qt.AlignRight
                    onClicked: infoRoot.close()
                }
            }
        }
    }

    InfoDialog {
        id: prefsDialog
        headerText: "Preferences"
        bodyText: "Preferences are managed through the Result Format option in the hamburger menu.\n\nAvailable formats:\n" +
                  "  • Automatic — trims trailing zeros\n" +
                  "  • Fixed — 2 decimal places\n" +
                  "  • Scientific — e-notation, 6 decimals\n" +
                  "  • Engineering — e-notation with exponent in multiples of 3"
    }

    InfoDialog {
        id: shortcutsDialog
        headerText: "Keyboard Shortcuts"
        bodyText: "Digits:          0–9\n" +
                  "Decimal:         .  or  ,\n" +
                  "Operators:       +  -  *  /\n" +
                  "Equals:          =  or  Enter\n" +
                  "Backspace:       Backspace\n" +
                  "Clear Entry:     Delete\n" +
                  "Clear All:       Escape\n" +
                  "Percentage:      %\n\n" +
                  "Mode switching:\n" +
                  "  Ctrl+Alt+B  Basic\n" +
                  "  Ctrl+Alt+A  Advanced\n" +
                  "  Ctrl+Alt+F  Financial\n" +
                  "  Ctrl+Alt+P  Programming\n" +
                  "  Ctrl+Alt+K  Keyboard\n" +
                  "  Ctrl+Alt+C  Conversion\n\n" +
                  "Menus:\n" +
                  "  Ctrl+N       New Window\n" +
                  "  Ctrl+Escape  Clear History\n" +
                  "  Ctrl+,       Preferences\n" +
                  "  Ctrl+?       This list\n" +
                  "  F1           Help"
    }

    InfoDialog {
        id: helpDialog
        headerText: "Help"
        bodyText: "Qt Calculator\n\n" +
                  "Basic mode supports standard arithmetic. Use the hamburger menu to switch between Basic, Advanced, Financial, Programming, Keyboard, and Conversion modes.\n\n" +
                  "The Keyboard mode lets you type expressions such as:\n" +
                  "  • 2 + 3 * 4\n" +
                  "  • sin(pi/2)\n" +
                  "  • sqrt(2)^3\n\n" +
                  "Financial mode buttons ask for comma-separated arguments (rate, nper, pv, etc.).\n\n" +
                  "Programming mode supports HEX/DEC/OCT/BIN radixes and bitwise AND/OR/XOR/NOT shifts."
    }

    InfoDialog {
        id: aboutDialog
        headerText: "About Calculator"
        bodyText: "Qt Calculator\n" +
                  "A simple calculator in Qt6\n\n" +
                  "Built with Rust and CXX-Qt.\n" +
                  "Uses the Qt 6 QML stack for the UI."
    }
}
