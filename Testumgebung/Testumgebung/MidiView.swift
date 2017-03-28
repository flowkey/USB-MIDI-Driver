//
//  MidiView.swift
//  Testumgebung
//
//  Created by flowing erik on 13.08.15.
//  Copyright (c) 2015 flowkey GmbH. All rights reserved.
//

import Foundation
import UIKit


protocol MidiViewDataSource {
    var command: Int {get}
    var key: Int {get}
    var velocity: Int {get}
}

@IBDesignable class MidiView: UIView {
    var datasource: MidiViewDataSource?
}
