// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "NoteDetection",
    products: [
        .library(name: "NoteDetection", type: .dynamic, targets: ["NoteDetection"])
    ],
    targets: [
        .target(name: "CAndroidAudioEngine"),
        .target(
            name: "NoteDetection",
            dependencies: ["CAndroidAudioEngine"],
            exclude: [
                // exclude all iOS-only files
                "FlowMathApple.swift",
                "PlatformApple.swift",
                "NoteDetectionIOS.swift",
                "AudioEngineIOS.swift",
                "AudioUnitExtensions.swift",
                "MIDIEngineIOS.swift",
                "MIDIEngine+Debug.swift",
                "MIDIMessage+MIDIPacket.swift",
                "MIDIObjectRef.swift",
                "OSStatus+LocalizedError.swift"
            ]
        )
    ]
)
