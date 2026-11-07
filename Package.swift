// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CozyQuickNoteDesk",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CozyQuickNoteDesk",
            path: "Sources/CozyQuickNoteDesk",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CozyQuickNoteDeskTests",
            dependencies: ["CozyQuickNoteDesk"],
            path: "Tests/CozyQuickNoteDeskTests"
        )
    ]
)
