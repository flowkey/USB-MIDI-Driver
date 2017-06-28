// swift-tools-version:3.1
// Package only intended to work for Linux/Android

import PackageDescription

let package = Package(
    name: "NoteDetection",
    exclude: [
        "Sources/FlowMathApple.swift",
        "Sources/PlatformApple.swift",
        "Sources/PlatformAndroid.old.swift",
        "Sources/AudioEngineIOS.swift",
        "Sources/AudioUnitExtensions.swift",
        "Sources/MIDIEngineIOS.swift",
        "Sources/MIDIEngine+Debug.swift",
        "Sources/MIDIMessage+MIDIPacket.swift",
        "Sources/MIDIObjectRef.swift",
        "Sources/OSStatus+LocalizedError.swift"
    ]
)
