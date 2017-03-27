//
//  CrossPlatformHelper.swift
//  NativePitchDetection
//
//  Created by flowing erik on 11.05.16.
//  Copyright © 2016 Geordie Jay. All rights reserved.
//

// TODO
// swiftlint:disable variable_name

#if os(Android)
import Glibc
let USEC_PER_SEC = 1000000
#else
import Darwin
#endif

let MSEC_PER_SEC = 1000

// MARK: Timestamp

public func getTimeInSecondsSince1970() -> Double {
    var now: timeval = timeval()
    gettimeofday(&now, nil)
    return Double(now.tv_sec) + (Double(now.tv_usec) / Double(USEC_PER_SEC))
}

public func getTimeInMillisecondsSince1970() -> Double {
    var now: timeval = timeval()
    gettimeofday(&now, nil)
    return (Double(now.tv_sec) * Double(MSEC_PER_SEC)) + (Double(now.tv_usec) / Double(MSEC_PER_SEC))
}
