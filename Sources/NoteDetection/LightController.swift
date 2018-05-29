//
//  LightController.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 25.05.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation

public typealias LightControlStatusChangedCallback = (LightControlStatus) -> Void

public enum LightControlStatus {
    case notAvailable   // no compatible device is connected
    case disabled       // compatible device connected but disabled by user
    case enabled        // compatible device connected and enabled by user

    // toggles between enabled and disabled or returns notAvailable
    public func toggled() -> LightControlStatus {
        switch self {
        case .enabled: return .disabled
        case .disabled: return .enabled
        case .notAvailable: return .notAvailable
        }
    }
}

public protocol LightController {
    func set(onLightControlStatusChanged: @escaping LightControlStatusChangedCallback)
    func disableLightControl() throws
    func enableLightControl() throws
}

public enum LightControlError: Error {
    case notAvailable
}

extension NoteDetection: LightController {
    public func set(onLightControlStatusChanged: @escaping (LightControlStatus) -> Void) {
        self.onLightControlStatusChanged = onLightControlStatusChanged
    }

    public func disableLightControl() throws {
        guard let lightControl = lightControl else {
            throw LightControlError.notAvailable
        }
        lightControl.isEnabled = false
        onLightControlStatusChanged?(.disabled)
    }

    public func enableLightControl() throws {
        guard let lightControl = lightControl else {
            throw LightControlError.notAvailable
        }
        lightControl.isEnabled = true
        onLightControlStatusChanged?(.enabled)
    }
}
