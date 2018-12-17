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
public let noteDetection = AudioNoteDetector(sampleRate: audioEngine.sampleRate)

@objc class MainViewController: UITabBarController, UITabBarControllerDelegate, ProcessedAudioDelegate {
    var graphViewController: GraphViewController?
    var midiViewController: MidiViewController?

    // Set the graphController we want to update when switching tabs
    func tabBarController(
        _ tabBarController: UITabBarController, 
        didSelect viewController: UIViewController
    ) {
        graphViewController = viewController as? GraphViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        delegate = self // TabBarControllerDelegate
        graphViewController = self.viewControllers?[0] as? GraphViewController
    }

    override func viewDidAppear(_ animated: Bool) {
        audioEngine.set(onAudioData: noteDetection.process)
        noteDetection.processedAudioDelegate = self
        noteDetection.delegate = self
        try! audioEngine.startMicrophone()
    }

    func onAudioProcessed(_ data: ProcessedAudio) {
        guard let graphViewController = graphViewController else { return }
        switch graphViewController.title {
        case "Filter Bank":
            graphViewController.updateView(data.filterbankMagnitudes)
        case "Waveform":
            graphViewController.updateView(data.audioData)
        case "Onset":
            graphViewController.updateView(data.onsetFeatureValue,
                                           onsetThreshold: data.onsetThreshold,
                                           onsetDetected: data.onsetDetected)
        default:
            graphViewController.updateView(data.chromaVector)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        try? audioEngine.stopMicrophone()
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainViewController: NoteDetectorDelegate {
    func onNoteEventDetected(
        noteDetector: NoteDetector,
        timestamp: TimeInterval,
        detectedEvent: DetectableNoteEvent
    ) -> Void {}
    func onInputLevelChanged(ratio: Float) -> Void {}
    var expectedNoteEvent: DetectableNoteEvent? { return DummyNoteEvent.empty }
}

struct DummyNoteEvent: DetectableNoteEvent {
    var notes: Set<MIDINumber> = []
    static let empty = DummyNoteEvent()
}
