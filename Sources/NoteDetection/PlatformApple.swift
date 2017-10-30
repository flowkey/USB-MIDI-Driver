//
//  SendNotificationApple.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.12.15.
//  Copyright © 2015 flowkey. All rights reserved.
//

import Foundation

func performOnMainThread(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
