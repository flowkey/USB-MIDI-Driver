//
//  NoteEventThrower.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 13.04.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//
import PitchDetection
import FlowCommons

class NoteEventThrower {
    
    // This file needs to be a valid .json file somewhere in the app bundle:
    fileprivate let jsonFilename = "pictures" // don't include the .json extension
    
    // static func getEventsFromJSON(_ filename: String) -> [NoteEvent]? {
    //     if
    //         let filePath = Bundle.main.path(forResource: filename, ofType: "json"),
    //         let jsonData = NSData(contentsOfFile: filePath),
    //         let noteEvents = JSON(data: jsonData as Data).array
    //     {
    //         var arr = [NoteEvent]()
    
    //         // Make an actual NoteEvent out of each item in the jsonData:
    //         for item in noteEvents {
    //             if let event = item.dictionaryObject, let noteEvent = NoteEvent(fromJSONDict: event) {
    //                 arr.append(noteEvent)
    //             } else {
    //                 print("Error creating NoteEvent from \(item)")
    //             }
    //         }
    
    //         return arr
    
    //     } else {
    //         // If we couldn't get the file path, json data etc
    //         print("failed to read \(filename).json")
    //         return nil
    //     }
    // }


    fileprivate var noteEvents: [NoteEvent]
    
    var currentEventNumber = 0 {
        willSet (eventNum) {
            print("\n\n\n\n\n\n\n\n\n\n") // clear the console
            if eventNum >= 0 && eventNum < noteEvents.count {
                setCurrentEvent(to: eventNum)
            } else {
                setCurrentEvent(to: 0)
            }
        }
    }
    
    fileprivate func setCurrentEvent(to eventNum: Int) {
        let nextNoteEvent: NoteEvent? = noteEvents[eventNum]
        guard nextNoteEvent != nil else { return }
        AudioEngineIOS.sharedInstance?.setExpectedEvent(nextNoteEvent!)
    }
    
    
    init? () {
        //if let jsonEvents = NoteEventThrower.getEventsFromJSON(jsonFilename) , jsonEvents.count > 0 {
        //    noteEvents = jsonEvents
        //    setCurrentEvent(to: currentEventNumber)
        //} else {
            noteEvents = []
            return nil // initialisation failed
       // }
    }
}
