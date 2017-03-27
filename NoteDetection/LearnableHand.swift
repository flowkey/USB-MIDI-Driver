//
//  LearnableHand.swift
//  PlayerLogic
//
//  Created by Geordie Jay on 05.10.16.
//  Copyright © 2016 Geordie Jay. All rights reserved.
//

public typealias LearnableHands = Set<LearnableHand>

public enum LearnableHand: CustomStringConvertible {
    case left, right

    public var description: String {
        switch self {
        case .left: return "left"
        case .right: return "right"
        }
    }
}
