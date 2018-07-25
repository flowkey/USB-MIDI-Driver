// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "NoteDetection",
    products: [
        .library(name: "NoteDetection", type: .dynamic, targets: ["NoteDetection"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftAndroid/swift-jni.git", from: "1.4.0")
    ],
    targets: [
        .target(name: "CAndroidAudioEngine"),
        .target(
            name: "NoteDetection",
            dependencies: ["CAndroidAudioEngine", "JNI"],
            exclude: [
                // exclude all iOS-only files
                "FlowMathApple.swift",
                "PlatformApple.swift",
                "NoteDetectionIOS.swift",
                "AudioEngineIOS.swift",
                "AudioUnitExtensions.swift",
                "MIDIEngineApple.swift",
                "MIDIEngineApple+send.swift",
                "MIDIEngine+Debug.swift",
                "MIDIPacket+UInt8Array.swift",
                "MIDIObjectRef.swift",
                "MIDIOutConnectionApple.swift",
                "OSStatus+LocalizedError.swift",
                "AVAudioEngine+Category.swift"
            ]
        )
    ]
)
