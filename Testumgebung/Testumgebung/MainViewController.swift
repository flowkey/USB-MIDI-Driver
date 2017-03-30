//
//  MainViewController.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 04.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import UIKit
import NoteDetection
import FlowCommons

public let noteDetection = NoteDetection(type: .audio)

@objc class MainViewController: UITabBarController, UITabBarControllerDelegate {

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
                graphViewController?.updateView(data.chromaVector)
            }
        }
    }


    // Set the graphController we want to update when switching tabs
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        graphViewController = viewController as? GraphViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        self.delegate = self // TabBarControllerDelegate
        graphViewController = self.viewControllers?[0] as? GraphViewController

        noteDetection.start()
        noteDetection.onMIDIDeviceListChanged = { (deviceList: Set<MIDIDevice>) in
            for device in deviceList { print(device.displayName) }
        }
        noteDetection.onMIDIMessageReceived = { (midiMessage: MIDIMessage, device: MIDIDevice?) in
            print(midiMessage)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        noteDetection.onAudioProcessed = { processedAudio in
            self.lastProcessedBlock = processedAudio
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        noteDetection.stop()
        self.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
}
