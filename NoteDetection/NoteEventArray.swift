//
//  NoteEventArray.swift

//
//  Created by flowing erik on 12.01.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

extension Array where Element == NoteEvent {
    public mutating func updateTimeToNextValues() {
        for index in self.indices {
            let eventHasNotes = !self[index].notes.isEmpty
            guard eventHasNotes,
                let nextIndex = self.getNextEventIndexWithNotes(currentIndex: index)
                else {
                    self[index].timeToNext = 0
                    continue
            }

            self[index].timeToNext = self[nextIndex].t - self[index].t
        }
    }

    func nextEventIndex(currentIndex: Int?) -> Int? {
        guard let currentIndex = currentIndex else { return nil }

        let nextIndex = currentIndex + 1
        if nextIndex < self.count {
            return nextIndex
        } else {
            return nil
        }
    }

    public func getNextEventIndexWithNotes(currentIndex: Int?) -> Int? {
        guard let nextIndex = self.nextEventIndex(currentIndex: currentIndex) else { return nil }

        if !self[nextIndex].notes.isEmpty {
            return nextIndex
        } else {
            return self.getNextEventIndexWithNotes(currentIndex: nextIndex)
        }
    }
}



