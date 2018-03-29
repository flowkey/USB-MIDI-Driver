//
//  MIDIEngine+NetworkSession.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 29.09.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

extension MIDIEndpointRef {
    var isADisconnectedNetworkSession: Bool {
        return isNetworkSession && !networkSessionIsConnected()
    }

    private var isNetworkSession: Bool {
        return self == MIDINetworkSession.default().sourceEndpoint()
    }
}

// ios9 bug - keep ref to prevent bad_exec error on removal of the device
// details: http://stackoverflow.com/questions/32686214/removeconnection-results-in-exc-bad-access
private var oldNetworkMIDIConnections: Set<MIDINetworkConnection> = []

private func networkSessionIsConnected() -> Bool {
    let activeConnections = MIDINetworkSession.default().connections()
    if activeConnections.isEmpty { return false }

    oldNetworkMIDIConnections.formUnion(activeConnections)
    return true
}
