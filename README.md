# Qt Calculator

A calculator built with Rust and CXX-Qt (Qt 6 QML).

## Features

- Six modes: Basic, Advanced, Financial, Programming, Keyboard, Conversion
- Full keyboard shortcut support
- Dark theme

## Build

Requires Rust, Qt 6 development packages, and CXX-Qt build tooling.

\`\`\`bash
RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo build --release
\`\`\`

The binary is produced at `target/release/qt-calculator-rust`.
