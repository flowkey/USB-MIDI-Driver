//
//  MainViewController.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 04.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import UIKit
@testable import NoteDetection

public let audioEngine = try! AudioEngine()
public let noteDetection = try! NoteDetection(input: .audio, audioSampleRate: audioEngine.sampleRate)

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
                let chromaAsFloatArray: [Float] = data.chromaVector.map { return $0 }
                graphViewController?.updateView(chromaAsFloatArray)
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
        audioEngine.set(onAudioData: noteDetection.process)
        try! audioEngine.start()

        (noteDetection.noteDetector as? AudioNoteDetector)?.onAudioProcessed = { processedAudio in
            self.lastProcessedBlock = processedAudio
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        try? audioEngine.stop()
        delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
}
