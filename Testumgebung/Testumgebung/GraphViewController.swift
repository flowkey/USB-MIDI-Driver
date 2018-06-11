//
//  GraphViewController.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 12.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import Foundation
import UIKit
import NoteDetection

class GraphViewController: UIViewController, GraphViewDataSource {
    
    var displayLink: CADisplayLink?
    
    @IBOutlet var graphView: GraphView? {
        didSet {
            graphView?.datasource = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let graphView = graphView {
            // A display link calls us on every frame (60 fps).
            displayLink = CADisplayLink(target: graphView, selector: #selector(GraphView.onDisplayLink))
            displayLink?.frameInterval = 1
            displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        } else {
            assertionFailure("Couldn't set up graphView")
        }
    }

    @IBAction func Start(_ sender: UIButton) {
        try! audioEngine.startMicrophone()
    }

    @IBAction func Stop(_ sender: UIButton) {
        try! audioEngine.stopMicrophone()
    }

    override func viewWillDisappear(_ animated: Bool) {
        displayLink?.invalidate()
        displayLink = nil
        super.viewWillDisappear(animated)
    }
    
    // The actual data structure
    var graphPoints = [Float](repeating: 0.00001, count: 12)
    var onsetFeatureValue: Float?
    var onsetThreshold: Float?
    var onsetDetected: Bool?
    var similarity: Float = 0 {
        // Average between current and previous value
        didSet { similarity = (similarity + oldValue) / 2 }
    }
    
    // Update the graphPoints from an external input. Again this should be in the view controller, not here.
    func updateView(_ data: [Float]) {
        graphPoints = data
    }

    func updateView(_ onsetFeatureValue: Float, onsetThreshold: Float, onsetDetected: Bool) {
        self.onsetFeatureValue = onsetFeatureValue
        self.onsetThreshold = onsetThreshold
        self.onsetDetected = onsetDetected
    }

    func clear() {
        graphPoints = []
        onsetFeatureValue = nil
        onsetThreshold = nil
        onsetDetected = nil
    }
}
