//
//  MainViewController.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 04.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import UIKit
import PitchDetection
import FlowCommons


@objc class MainViewController: UITabBarController, UITabBarControllerDelegate, AudioProcessorDisplayDelegate {
    

    let audioEngine = AudioEngineIOS.sharedInstance
    
    let midiManager = MIDIManager.sharedInstance
    var graphViewController: GraphViewController?
    var midiViewController: MidiViewController?

    var lastProcessedBlock = ProcessedAudio() {
        didSet {
            let data = lastProcessedBlock
            switch graphViewController?.title {
            case .some("Filter Bank"):
                graphViewController?.updateView(data.filterBandAmplitudes)
            case .some("Waveform"):
                graphViewController?.updateView(data.audioData)
            case .some("Onset"):
                graphViewController?.updateView(data.onsetFeatureValue, onsetThreshold: data.onsetThreshold, onsetDetected: data.onsetDetected)
            default:
                graphViewController?.updateView(data.chromaVector.toRaw)
            }
        }
    }
    
    
    // Set the graphController we want to update when switching tabs
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        graphViewController = viewController as? GraphViewController
    }
    
    func followEventListener(_ nextNoteEvent: NoteEvent?) -> Void {
        guard let noteEvent = nextNoteEvent else { return }
        audioEngine?.setExpectedEvent(noteEvent)
    }

    // MARK: View controller lifecycle stuff:
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.delegate = self // TabBarControllerDelegate
        graphViewController = self.viewControllers?[0] as? GraphViewController
        
        try? audioEngine?.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // bad practice not to handle errors, but this is an internal test app
        audioEngine?.setDisplayDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioEngine?.setDisplayDelegate(nil)
        try? audioEngine?.stop()
        self.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }


    
}
