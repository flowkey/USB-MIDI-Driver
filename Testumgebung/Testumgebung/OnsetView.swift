//
//  OnsetView.swift
//  Testumgebung
//
//  Created by flowing erik on 13.07.15.
//  Copyright (c) 2015 flowkey GmbH. All rights reserved.
//

import UIKit

fileprivate let dataCount = 256

@IBDesignable class OnsetView: GraphView {

    @IBInspectable var thresholdColour: UIColor = .black
    private let defaultThresholdOpacity = Float(0.25)

   var onsetScale: Float = 1_000_000 // SpectralFlux
    // var onsetScale: Float = 10_0000      // RMS

    override var columnGap: CGFloat { return 0 }

    fileprivate var viewOnsetData = [Float](repeating: 0, count: dataCount)
    fileprivate var viewThresholdData = [Float](repeating: 0, count: dataCount)
    fileprivate var onsetDetectedData = [Bool](repeating: false, count: dataCount)

    fileprivate var thresholdLayers = [CALayer()]

    override func setupLayers (_ count: Int) {

        let columnWidth = (self.frame.width - CGFloat(dataCount) * columnGap - marginWidth * 2) / CGFloat(dataCount)

        thresholdLayers.forEach({ $0.removeFromSuperlayer() })
        thresholdLayers = (0 ..< count).map { i -> NonAnimatingCALayer in
            let thresholdLayer = NonAnimatingCALayer()
            thresholdLayer.opacity = defaultThresholdOpacity
            thresholdLayer.shouldRasterize = true
            thresholdLayer.drawsAsynchronously = true
            thresholdLayer.frame.size.width = columnWidth
            thresholdLayer.frame.size.height = graphHeight
            thresholdLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
            thresholdLayer.frame.origin.x = marginWidth + CGFloat(i) * (columnWidth + columnGap)
            thresholdLayer.frame.origin.y = topBorder
            thresholdLayer.backgroundColor = thresholdColour.cgColor
            self.layer.addSublayer(thresholdLayer)
            return thresholdLayer
        }

        layers.enumerated().forEach { i, layer in
            layer.frame.size.width = columnWidth
            layer.frame.origin.x = marginWidth + CGFloat(i) * (columnWidth + columnGap)
            layer.backgroundColor = lineColour.cgColor
        }

        super.setupLayers(count)
    }

    override func onDisplayLink () {
        guard
            let onsetFeatureValue = datasource?.onsetFeatureValue,
            let onsetThreshold = datasource?.onsetThreshold,
            let onsetDetected = datasource?.onsetDetected
        else {
            return
        }

        // We have used the data once, don't use them again
        datasource?.clear()

        viewOnsetData.remove(at: 0)
        viewOnsetData.append(onsetFeatureValue)

        viewThresholdData.remove(at: 0)
        viewThresholdData.append(onsetThreshold)

        onsetDetectedData.remove(at: 0)
        onsetDetectedData.append(onsetDetected)

        if viewOnsetData.count != layers.count {
            setupLayers(dataCount)
        }


        for i in 0 ..< dataCount {
            // draw threshold values
            let thresholdBarScale = CGFloat(viewThresholdData[i] * onsetScale) / graphHeight
            thresholdLayers[i].setAffineTransform(
                CGAffineTransform(scaleX: 1, y: thresholdBarScale)
            )
            thresholdLayers[i].opacity = defaultThresholdOpacity

            // draw feature values
            let barScale = min(1, CGFloat(viewOnsetData[i] * onsetScale) / graphHeight)
            layers[i].setAffineTransform(
                CGAffineTransform(scaleX: 1, y: barScale)
            )

            if i != 0 && onsetDetectedData[i] {
                // If there was an onset detected, make the previous threshold layer black and full height
                let previousThresholdLayer = thresholdLayers[i - 1]
                let previousBarLayer = layers[i - 1]

                let maxYScale = max(previousThresholdLayer.transform.m22, previousBarLayer.transform.m22)
                previousThresholdLayer.setAffineTransform(CGAffineTransform(scaleX: 1, y: maxYScale))
                previousThresholdLayer.opacity = 1
            }
        }
    }
}
