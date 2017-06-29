//
//  FlowMathAndroid.swift
//  NativePitchDetection
//
//  Created by flowing erik on 28.09.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

#if os(Android)

import Glibc

// swiftlint:disable:next variable_name
let M_PI: Double = 3.1415926535897931

func sin(x: Float) -> Float {
    return Glibc.sinf(x)
}

func sin(x: Double) -> Double {
    return Glibc.sin(x)
}

func cos(x: Float) -> Float {
    return Glibc.cosf(x)
}

func cos(x: Double) -> Double {
    return Glibc.cos(x)
}

func round(x: Float) -> Float {
    return Glibc.roundf(x)
}

func round(x: Double) -> Double {
    return Glibc.round(x)
}

func lround(x: Float) -> Int {
    return Glibc.lroundf(x)
}

func lround(x: Double) -> Int {
    return Glibc.lround(x)
}

func pow(base: Float, _ exponent: Float) -> Float {
    return Glibc.powf(base, exponent)
}

func pow(base: Double, _ exponent: Double) -> Double {
    return Glibc.pow(base, exponent)
}

// log(2)x = log(10)x / log(10)2
private let log2b10f = Glibc.log10f(2)
func log2(x: Float) -> Float {
    return Glibc.log10f(x) / log2b10f
}

private let log2b10 = Glibc.log10(Double(2.0))
func log2(x: Double) -> Double {
    return Glibc.log10(x) / log2b10
}

func log10(x: Float) -> Float {
    return Glibc.log10f(x)
}

func log10(x: Double) -> Double {
    return Glibc.log10(x)
}

func sqrt(_ x: Float) -> Float {
    return Glibc.sqrtf(x)
}

func sqrt(_ x: Double) -> Double {
    return Glibc.sqrt(x)
}

#endif

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
