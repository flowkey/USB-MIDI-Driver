//
//  InputType.swift
//  NoteDetection
//
//  Created by flowing erik on 29.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public enum InputType {
    case audio
    case midi

    func createNoteDetection() -> NoteDetectionProtocol {
        switch self {
        case .audio: return AudioNoteDetection()
        case .midi: return MIDINoteDetection()
        }
    }
}
