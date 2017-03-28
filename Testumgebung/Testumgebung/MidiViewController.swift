
//
//  MidiViewController.swift
//  Testumgebung
//
//  Created by flowing erik on 13.08.15.
//  Copyright (c) 2015 flowkey GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreAudioKit


class MidiViewController: CABTMIDICentralViewController, MidiViewDataSource {
    
    var displayLink: CADisplayLink?
    
    // The actual data structure
    var velocity = 0
    var key = 0
    var command = 0
    
    @IBOutlet var midiView: MidiView? {
        didSet {
            if let midiView = midiView {
                midiView.datasource = self
                
                // A display link calls us on every frame (60 fps).
                displayLink = CADisplayLink(target: midiView, selector: #selector(GraphView.onDisplayLink))
                displayLink?.frameInterval = 1
                displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    func updateView(_ midiMessage: MidiViewDataSource) {
        print(midiMessage)

    }

}
