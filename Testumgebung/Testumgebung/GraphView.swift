    //
//  GraphView.swift
//  Flo
//
//  Created by Caroline Begbie on 22/12/2014.
//  Edited by Eric Cerney on 13/1/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit
import Accelerate

protocol GraphViewDataSource {
    var similarity: Float {get}
    var graphPoints: [Float] {get}
    var onsetFeatureValue: Float? {get}
    var onsetThreshold: Float? {get}
    var onsetDetected: Bool? {get}
    func clear()
}

final class NonAnimatingCALayer: CALayer {
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

@IBDesignable class GraphView: UIView {
  
    // Default line and point colours: you can change these visually in interface builder.
    @IBInspectable var pointColour: UIColor = UIColor.red
    @IBInspectable var lineColour: UIColor = UIColor.green
    
    // Default values for storyboard
    fileprivate var defaultGraphPoints: [Float] {
        return [0.0, 0.0, 0.1, 0.2, 0.25, 0.3, 1.0, 0.14, 0.2, 0.1, 0.0, 0.0]
    }

    var minimumThreshold: Float { return 0.015 }

    // Values to draw the graph with
    
    let marginWidth: CGFloat = 15.0
    var topBorder: CGFloat { return 20 + bounds.height * 0.01 }
    var bottomBorder: CGFloat { return bounds.height * 0.04 }

    var graphBase: CGFloat {
        return bounds.height - bottomBorder
    }

    var graphHeight: CGFloat {
        return bounds.height - topBorder - bottomBorder
    }

    // Put a gap depending on how many columns there are (more columns = smaller gap)
    var columnGap: CGFloat {
        let graphPoints = datasource?.graphPoints ?? defaultGraphPoints
        return min(1, CGFloat(maxGraphPoints) / CGFloat(graphPoints.count * 2))
    }
    
    // Set up display
    @nonobjc var layers = [CALayer]()
    
    var datasource: GraphViewDataSource?
    var maxGraphPoints: Int {
        let graphWidth = bounds.width - (marginWidth * 2)
        return Int(graphWidth) * Int(layer.contentsScale)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers(layers.count)
    }

    func onDisplayLink () {
        // The "default" bits are just for the storyboard and shouldn't affect performance:
        let graphPoints = datasource?.graphPoints ?? defaultGraphPoints
        if graphPoints.count == 0 { return }
        datasource?.clear()

        let graphPointsToDraw = min(graphPoints.count, maxGraphPoints)
        let stride = graphPoints.count / graphPointsToDraw

        // But this shouldn't be graphPoints.count - it should take the stride into consideration
        if layers.count != graphPointsToDraw {
            setupLayers(graphPointsToDraw)
        }

        // Calculate the y values for each graph data point
        var absoluteMax: Float = 0
        vDSP_maxmgv(graphPoints, 1, &absoluteMax, vDSP_Length(graphPoints.count))

        // Normalise heights based on the maxValue:
        let maxValue = CGFloat(max(minimumThreshold, absoluteMax))
        let proportionalHeight = { (i: Int) -> CGFloat in
            let curValue = CGFloat(graphPoints[i * stride])
            return curValue / maxValue
        }

        // Add points for each item in the graphPoints array at the correct (x, y)
        for i in 0 ..< graphPointsToDraw {
            layers[i].setAffineTransform(CGAffineTransform(scaleX: 1, y: proportionalHeight(i)))
        }
    }
    
    func setupLayers (_ count: Int) {
        let columnWidth = (frame.width - CGFloat(count) * columnGap - marginWidth * 2) / CGFloat(count)
        let columnXPoint = { (column: Int) -> CGFloat in
            return self.marginWidth + CGFloat(column) * (columnWidth + self.columnGap)
        }

        layers.forEach { $0.removeFromSuperlayer() }
        layers = (0 ..< count).map { i -> NonAnimatingCALayer in
            let column = NonAnimatingCALayer()
            column.shouldRasterize = true
            column.drawsAsynchronously = true
            column.backgroundColor = lineColour.cgColor
            column.frame.size.height = graphHeight
            column.frame.size.width = columnWidth
            column.anchorPoint = CGPoint(x: 0.5, y: 1) // translate from bottom
            column.frame.origin.y = topBorder
            column.frame.origin.x = columnXPoint(i)
            layer.addSublayer(column)
            return column
        }
    }
}
