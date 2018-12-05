//
//  AudioEngineTest.swift
//  NoteDetectionTests
//
//  Created by Erik Werner on 04.12.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import XCTest
import Dispatch
@testable import NoteDetection

class AudioEngineIOSTests: XCTestCase {
    var audioEngine = try! AudioEngine()

    override func setUp() {
        audioEngine = try! AudioEngine()
    }

    func testInputIsEnabled() {
        XCTAssertFalse(audioEngine.inputIsEnabled)
        try! audioEngine.startMicrophone()
        XCTAssertTrue(audioEngine.inputIsEnabled)
    }

    func testInputIsDisabled() {
        try! audioEngine.startMicrophone()
        try! audioEngine.stopMicrophone()

        XCTAssertFalse(audioEngine.inputIsEnabled)
    }

    func testIfOnAudioDataIsCalled() {
        let onAudioDataWasCalled = XCTestExpectation(
            description: "onAudioData callback is called"
        )
        audioEngine.set(onAudioData:  { _, _ in
            onAudioDataWasCalled.fulfill()
        })
        try! audioEngine.startMicrophone()
        wait(for: [onAudioDataWasCalled], timeout: 0.1)
    }

    func testIfAudioDataIsNonZero() {
        let audioRuntimeDuration = 0.1
        var aggregatedAudioData: [Float] = []
        let audioDataIsNonZero = XCTestExpectation(
            description: "collected audio data is non-zero"
        )
        audioEngine.set(onAudioData:  { audioData, _ in
            aggregatedAudioData.append(contentsOf: audioData)
        })

        try! audioEngine.startMicrophone()
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + audioRuntimeDuration,
            execute: {
                try! self.audioEngine.stopMicrophone()
                let rms = rootMeanSquare(aggregatedAudioData)
                if rms > 0 {
                    audioDataIsNonZero.fulfill()
                }
            }
        )

        wait(for: [audioDataIsNonZero], timeout: audioRuntimeDuration + 0.1)
    }

    func testIfAudioTimeIsInMilliseconds() {
        // the longer we test, the lower the accuracy parameter can be
        let audioTestDurationS = 2.0
        let accuracy = 0.01
        let audioTimeIsInMS = XCTestExpectation(
            description: "audio time is in milliseconds"
        )
        var audioTimes: [AudioTime] = []
        var referenceTimes: [Double] = []

        audioEngine.set(onAudioData:  { _, audioTime in
            audioTimes.append(audioTime)
            referenceTimes.append(Date().timeIntervalSince1970.toMilliseconds())
        })

        try! audioEngine.startMicrophone()
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + audioTestDurationS,
            execute: {
                try! self.audioEngine.stopMicrophone()
                let audioTimeDiffMean = mean(audioTimes.getDifferences())
                let referenceTimeDiffMean = mean(referenceTimes.getDifferences())
                XCTAssertEqual(audioTimeDiffMean, referenceTimeDiffMean, accuracy: accuracy)
                audioTimeIsInMS.fulfill()
            }
        )

        wait(for: [audioTimeIsInMS], timeout: audioTestDurationS + 1)
    }

    func testGetDifferences() {
        let arr: [Double] = [2, 4, 5, 10]
        XCTAssertEqual(arr.getDifferences(), [2, 1, 5])
    }
}

fileprivate extension TimeInterval {
    func toMilliseconds() -> Double {
        return self * 1000
    }
}

fileprivate extension Array where Element == Double {
    func getDifferences() -> [Double] {
        assert(self.count > 1)
        var diffs: [Double] = []
        for (offset, element) in self.enumerated() {
            guard offset < self.count - 1 else {
                break
            }
            let diff = self[offset + 1] - element
            diffs.append(diff)
        }
        return diffs
    }
}
