//
//  PlatformAndroid.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.12.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//
import Dispatch


func performOnMainThread(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}


@discardableResult
@_silgen_name("__android_log_write")
public func androidPrint(_ prio: Int32, _ tag: UnsafePointer<CChar>, _ text: UnsafePointer<CChar>) -> Int32

func print(_ string: String) {
    androidPrint(5, "NoteDetection", string)
}

