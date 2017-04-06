//
//  MIDIEngine+debug.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

/*
 * MARK: For debug purposes only
 */

extension MIDIEngine {

    fileprivate func printSourcesDestinations() {
        let destCount = MIDIGetNumberOfDestinations()
        print("Number of Destinations: \(destCount)")

        for destIndex in 0 ..< destCount {
            let endpoint = MIDIGetDestination(destIndex)
            print("Destination: \(endpoint.displayName)")
        }

        let sourceCount = MIDIGetNumberOfSources()
        print("Number of Sources: \(sourceCount)")
        for sourceIndex in 0 ..< sourceCount {
            let endpoint = MIDIGetSource(sourceIndex)
            print("Source: \(endpoint.displayName)")
        }
    }

    fileprivate func printDevices() {
        let numDevices = MIDIGetNumberOfDevices()
        for i in 0 ..< numDevices {
            let midiDevice = MIDIGetDevice(i)
            print("Device: \(midiDevice.displayName)")

            // Iterate through this device's entities
            let entityCount = MIDIDeviceGetNumberOfEntities(midiDevice)
            for entityIndex in 0 ..< entityCount {
                let entity = MIDIDeviceGetEntity(midiDevice, entityIndex)
                print("Entity: \(entity.displayName)")

                // Iterate through this device's source endpoints (MIDI In)
                let sourceCount = MIDIEntityGetNumberOfSources(entity)
                for sourceIndex in 0 ..< sourceCount {
                    let source  = MIDIEntityGetSource(entity, sourceIndex)
                    print("Source: \(source.displayName)")
                }

                // Iterate through this device's destination endpoints
                let destCount = MIDIEntityGetNumberOfDestinations(entity)
                for destIndex in 0 ..< destCount {
                    let destination = MIDIEntityGetDestination(entity, destIndex)
                    print("Destination: \(destination.displayName)")
                }
            }

        }
    }

}
