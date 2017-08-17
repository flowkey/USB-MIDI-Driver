//
//  MainViewController.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 04.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import UIKit
@testable import NoteDetection

public let noteDetection = try! NoteDetection(input: .audio)

@objc class MainViewController: UITabBarController, UITabBarControllerDelegate {

    var graphViewController: GraphViewController?
    var midiViewController: MidiViewController?

    var lastProcessedBlock: ProcessedAudio {
        get { return ProcessedAudio([], ChromaVector(), [], 0, 0, false) } // dummy data. we shouldn't ever have to "get" these data
        set {
            let data = newValue
            switch graphViewController?.title {
            case .some("Filter Bank"):
                graphViewController?.updateView(data.filterbankMagnitudes)
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

    override func viewWillAppear(_ animated: Bool) {
        delegate = self // TabBarControllerDelegate
        graphViewController = self.viewControllers?[0] as? GraphViewController
    }

    override func viewDidAppear(_ animated: Bool) {
        try! noteDetection.startMicrophone()

        noteDetection.set(onMIDIDeviceListChanged: { (deviceList: Set<MIDIDevice>) in
            for device in deviceList { print(device.displayName) }
        })

        noteDetection.midiEngine.set(onMIDIMessageReceived: { (midiMessage: MIDIMessage, device: MIDIDevice?, timestamp: Timestamp) in
            print(midiMessage)
        })

        (noteDetection.noteDetector as? AudioNoteDetector)?.onAudioProcessed = { processedAudio in
            self.lastProcessedBlock = processedAudio
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        try? noteDetection.stopMicrophone()
        delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
}
