//
//  Filterbank+ChromaVector.swift
//  NoteDetection
//
//  Created by Geordie Jay on 05.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

extension FilterBank {
    func getChroma(for detectionMode: PitchDetection.DetectionMode) -> ChromaVector {
        // These only get calculated if you actually access them:
        /// Extracted from filterbank magnitudes within __LOW__ range
        var lowChroma: ChromaVector {
            return ChromaVector(from: magnitudes, startingAt: lowRange.first!, range: lowRange)
        }

        /// Extracted from filterbank magnitudes within __HIGH__ range
        var highChroma: ChromaVector {
            return ChromaVector(from: magnitudes, startingAt: lowRange.first!, range: highRange)
        }

        switch detectionMode {
        case .lowPitches:  return lowChroma
        case .highPitches: return highChroma
        case .highAndLow:  return lowChroma + highChroma
        }
    }
}
