//
//  FlowMathAndroid.swift
//  NativePitchDetection
//
//  Created by flowing erik on 28.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

#if os(Android) || os(Linux)

import Foundation

func max <T: FloatingPoint>(v: [T]) -> T {
    return v.reduce(v[0]) { return ($1 > $0) ? $1 : $0 }
}

func min <T: FloatingPoint>(v: [T]) -> T {
    return v.reduce(v[0]) { return ($1 < $0) ? $1 : $0 }
}

func sum(v: [Float]) -> Float {
    return v.reduce(0, +)
}

func sum(v: [Double]) -> Double {
    return v.reduce(0, +)
}

func sqrt(v: [Float]) -> [Float] {
    return v.map(sqrt)
}

func sqrt(v: [Double]) -> [Double] {
    return v.map(sqrt)
}

func rootMeanSquare(_ numArray: [Float]) -> Float {
    return sqrt(meanSquare(numArray))
}

func meanSquare (_ v: [Float]) -> Float {
    return (v.reduce(0) { $0 + ($1 * $1) }) / Float(v.count)
}

func mean (_ v: [Float]) -> Float {
    return v.reduce(0, +) / Float(v.count)
}

func median (_ v: [Float]) -> Float {
    // Sort ascending
    var array = v.sorted(by: <)

    let halfway = array.count / 2

    // if array.count is even, take the mean of both center elements
    if (array.count % 2 == 0) {
        return (array[halfway - 1] + array[halfway]) / 2
    } else {
        // use the middle (center) element
        return array[halfway]
    }
}

#endif