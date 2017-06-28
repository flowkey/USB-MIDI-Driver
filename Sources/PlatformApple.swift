//
//  SendNotificationApple.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.12.15.
//  Copyright © 2015 flowkey. All rights reserved.
//

import Foundation


// func postNotification(_ name: String, data: AnyObject? = nil) {
//     performOnMainThread {
//         NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: data)
//     }
// }

func performOnMainThread(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
