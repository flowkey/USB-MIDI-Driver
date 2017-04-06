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
#else
import Darwin
#endif

let MSEC_PER_SEC = 1000

/// A Double signifying the time an event arrived, in milliseconds
public typealias Timestamp = Double

extension Timestamp {
    static var now: Timestamp { return getTimeInMillisecondsSince1970() }
}


//private func getTimeInSecondsSince1970() -> Double {
//    var now: timeval = timeval()
//    gettimeofday(&now, nil)
//    return Double(now.tv_sec) + (Double(now.tv_usec) / Double(USEC_PER_SEC))
//}

private func getTimeInMillisecondsSince1970() -> Double {
    var now: timeval = timeval()
    gettimeofday(&now, nil)
    return (Double(now.tv_sec) * Double(MSEC_PER_SEC)) + (Double(now.tv_usec) / Double(MSEC_PER_SEC))
}
