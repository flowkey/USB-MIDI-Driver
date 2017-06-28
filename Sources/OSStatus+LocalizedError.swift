//
//  OSStatus+LocalizedError.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 13.03.17.
//  Copyright © 2017 Geordie Jay. All rights reserved.
//

import Foundation

extension OSStatus: LocalizedError {
    /// Allow OSStatus values to throw an error
    func throwOnError() throws {
        if self != noErr { throw self }
    }

    public var localizedDescription: String {
        // It's sometimes possible that OSStatus is actually a 4-byte string
        var message = [CChar](repeating: 0, count: 4)
        message.withUnsafeMutableBytes { buffer in
            // Safe because OSStatus is actually an Int32 which is always 4 bytes long:
            buffer.baseAddress!.assumingMemoryBound(to: OSStatus.self)[0] = self.bigEndian
        }

        for char in message {
            // If there is an invalid character (there usually is), we couldn't convert the code to a string:
            if isprint(Int32(char)) != 1 {
                // NSError is able to convert some errors, so try that. Otherwise, its localizedDescription
                // will still contains the untouched code that you can look up on `http://osstatus.com`:
                return NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: nil).localizedDescription
            }
        }

        // We know we have 4 valid characters, add a null terminating character and convert to ascii:
        return String(cString: message + [0])
    }
}
