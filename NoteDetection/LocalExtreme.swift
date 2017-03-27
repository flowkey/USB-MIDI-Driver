//
//  LocalExtreme.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public func isLocalMaximum(amplitudes: [Float], centreIndex: Int) -> Bool {
    return isLocalExtreme(findMinimum: false, numArray: amplitudes, checkPosition: centreIndex)
}

public func isLocalMinimum(amplitudes: [Float], centreIndex: Int) -> Bool {
    return isLocalExtreme(findMinimum: true, numArray: amplitudes, checkPosition: centreIndex)
}

private func isLocalExtreme(findMinimum: Bool, numArray: [Float], checkPosition: Int) -> Bool {
    // enumerate gives us a tuple like this: (index, value):
    return numArray.enumerated().reduce(true) {
        (isTrueSoFar, cur: (i: Int, value: Float)) -> Bool in

        // A trough is the opposite of a peak...
        //
        // enteringTrough \     /
        //             --> \   /
        //                  \_/ <-- leavingTrough
        //        index: 0-1-2-3-4
        //                   ^
        //                 checkPos

        if !isTrueSoFar { return false }

        var shouldBeDecreasing: Bool {
            if findMinimum {
                return cur.i < checkPosition
            } else {
                return cur.i >= checkPosition
            }
        }

        // Avoid array out of bounds:
        if cur.i == numArray.count - 1 {
            return isTrueSoFar
        } else if shouldBeDecreasing {
            // we should be entering a trough, meaning that the
            // volume of next block should be less than the current one:
            return isTrueSoFar && numArray[cur.i + 1] < cur.value
        } else {
            // we are coming out of the trough, volume should be increasing from here..
            return isTrueSoFar && numArray[cur.i + 1] > cur.value
        }
    }
}
