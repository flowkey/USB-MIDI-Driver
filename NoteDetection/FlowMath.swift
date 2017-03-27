//
//  FlowMath.swift
//  NativePitchDetection
//
//  Created by flowing erik on 28.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

import Foundation
import Accelerate

// TODO
// swiftlint:disable variable_name

let M_PI: Double = 3.1415926535897931

func sin(_ x: Float) -> Float {
    return Foundation.sinf(x)
}

func sin(_ x: Double) -> Double {
    return Foundation.sin(x)
}

func cos(_ x: Float) -> Float {
    return Foundation.cosf(x)
}

func cos(_ x: Double) -> Double {
    return Foundation.cos(x)
}

func lround(_ x: Float) -> Int {
    return Foundation.lroundf(x)
}

func sqrt(_ num: Float) -> Float {
    return Foundation.sqrt(num)
}

func sqrt(_ num: Double) -> Double {
    return Foundation.sqrt(num)
}

func max(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_maxv(x, 1, &result, vDSP_Length(x.count))

    return result
}

func max(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_maxvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

func min(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_minv(x, 1, &result, vDSP_Length(x.count))

    return result
}

func min(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_minvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

func sum(_ x: [Float]) -> Float {
    return cblas_sasum(Int32(x.count), x, 1)
}

func sum(_ x: [Double]) -> Double {
    return cblas_dasum(Int32(x.count), x, 1)
}

func sqrt(_ x: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])

    return results
}

func sqrt(_ x: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vvsqrt(&results, x, [Int32(x.count)])

    return results
}


func rootMeanSquare(_ numArray: [Float]) -> Float {
    return sqrtf(meanSquare(numArray))
}


func meanSquare(_ x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_measqv(x, 1, &result, vDSP_Length(x.count))

    return result
}

func meanSquare(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_measqvD(x, 1, &result, vDSP_Length(x.count))

    return result
}


public func mean(_ input: [Float]) -> Float {
    var meanValue = Float(0)
    vDSP_meanv(input, 1, &meanValue, vDSP_Length(input.count))

    return meanValue
}


func median(_ input: [Float], use_vDSP_vsort: Bool = false) -> Float {
    var array = input

    // Sort ascending
    if use_vDSP_vsort == true {
        // use vDSP_vsort for large arrays (100s or 1000s)
        vDSP_vsort(&array, vDSP_Length(array.count), 1)
    } else {
        // use swift sort for smaller arrays
        array.sort( by: < )
    }

    let half = array.count / 2

    // if array.count is even, take the mean of both of center elements
    if (array.count % 2 == 0) {
        return (array[half - 1] + array[half]) / 2.0
    } else {
        // use the middle (center) element
        return array[half]
    }
}
