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
