//
//  MIDIObjectRef.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import CoreMIDI

extension MIDIObjectRef {
    var online: Bool {
        return getIntProperty(kMIDIPropertyOffline) == 0
    }

    var displayName: String {
        return getStringProperty(kMIDIPropertyName) as String
    }

    var uniqueID: Int {
        return Int(getIntProperty(kMIDIPropertyUniqueID))
    }

    var connectionUniqueID: Int {
        return Int(getIntProperty(kMIDIPropertyConnectionUniqueID))
    }

    var model: String {
        return getStringProperty(kMIDIPropertyModel)
    }

    var manufacturer: String {
        return getStringProperty(kMIDIPropertyManufacturer)
    }

    func getIntProperty(_ propertyName: CFString) -> Int32 {
        var result = Int32()
        let status = MIDIObjectGetIntegerProperty(self, propertyName, &result)
        if status == OSStatus(noErr) {
            return result
        } else {
            return INT32_MAX
        }
    }

    func getStringProperty(_ propertyName: CFString) -> String {
        var result: Unmanaged<CFString>? = nil
        let status = MIDIObjectGetStringProperty(self, propertyName, &result)
        if status == OSStatus(noErr) {
            return String(result!.takeRetainedValue())
        } else {
            print("Error while getting property: \(propertyName)")
            return ""
        }
    }
}
