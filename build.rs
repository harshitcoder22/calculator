use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new_qml_module(
        QmlModule::new("gnome.calculator")
            .qml_file("src/qml/Main.qml")
    )
    .qt_module("Quick")
    .qt_module("QuickControls2")
    .file("src/cxxqt_object.rs")
    .build();
}
