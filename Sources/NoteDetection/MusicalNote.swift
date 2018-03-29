//
//  MusicalNote.swift

//
//  Created by flowing erik on 04.10.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

public enum MusicalNote: Int, CustomStringConvertible {
    case c = 0, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b

    internal var noteName: String {
        switch self {
        case .c:        return "C"
        case .cSharp:   return "C♯"
        case .d:        return "D"
        case .dSharp:   return "D♯"
        case .e:        return "E"
        case .f:        return "F"
        case .fSharp:   return "F♯"
        case .g:        return "G"
        case .gSharp:   return "G♯"
        case .a:        return "A"
        case .aSharp:   return "A♯"
        case .b:        return "B"
        }
    }

    public var description: String {
        return "♪" + noteName
    }
}
