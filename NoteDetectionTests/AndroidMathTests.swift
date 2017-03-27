//
//  FlowMathAndroidTest.swift
//  NativePitchDetection
//
//  Created by flowing erik on 12.01.16.
//  Copyright © 2016 Geordie Jay. All rights reserved.
//

import XCTest
import Accelerate
@testable import NoteDetection

class MathTest: XCTestCase {

    let accuracy: Float = 0.0000001

    // MARK: Set up / tear down tests:

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    // MARK: test functions: some simple sanity checks for functions running under android

    func testMax() {
        let arr: [Float] = [1.5, 1.5000001, 1.49999999]

        let maxValue1 = max(arr)
        var maxValue2: Float = 0.0
        vDSP_maxv(arr, 1, &maxValue2, vDSP_Length(arr.count))

        XCTAssertEqual(maxValue1, arr[1])
        XCTAssertEqual(maxValue2, arr[1])


        var maxValue: Float = 0
        vDSP_maxv(sampleSpectrum, 1, &maxValue, vDSP_Length(sampleSpectrum.count))

        XCTAssertEqual(max(sampleSpectrum), maxValue)

    }

    func testMin() {
        let arr: [Float] = [1.5, 1.5000001, 1.49999999]

        let minValue1 = min(arr)
        var minValue2: Float = 0.0
        vDSP_minv(arr, 1, &minValue2, vDSP_Length(arr.count))

        XCTAssertEqual(minValue1, arr[2])
        XCTAssertEqual(minValue2, arr[2])


        var minValue: Float = 0
        vDSP_minv(sampleSpectrum, 1, &minValue, vDSP_Length(sampleSpectrum.count))

        XCTAssertEqual(min(sampleSpectrum), minValue)
    }

    func testSum() {

        let sumValue1 = sum(sampleAudioFrame)
        var sumValue2: Float = 0
        vDSP_sve(sampleAudioFrame, 1, &sumValue2, vDSP_Length(sampleAudioFrame.count))

        XCTAssertEqualWithAccuracy(sumValue1, sumValue2, accuracy: accuracy)
        // XCTAssertEqual(sumValue1, sumValue2)
    }

    func testSqrt() {

        XCTAssertEqual([Float(3.0)], sqrt([9.0]))
    }

    func testRMS() {

        let rms1 = rootMeanSquare(sampleAudioFrame)
        var rms2: Float = 0
        vDSP_rmsqv(sampleAudioFrame, 1, &rms2, vDSP_Length(sampleAudioFrame.count))


        XCTAssertEqualWithAccuracy(rms1, rms2, accuracy: accuracy)
        // XCTAssertEqual(rms1, rms2)
    }

    func testMean() {

        let meanValue1 = mean(sampleAudioFrame)
        var meanValue2: Float = 0
        vDSP_meanv(sampleAudioFrame, 1, &meanValue2, vDSP_Length(sampleAudioFrame.count))

        XCTAssertEqualWithAccuracy(meanValue1, meanValue2, accuracy: accuracy)
        // XCTAssertEqual(meanValue1, meanValue2)
    }

    func testMedian() {
        let arr: [Float] = [3, 4, 1]

        let medianValue = median(arr)

        XCTAssertEqual(medianValue, 3)
    }

}
