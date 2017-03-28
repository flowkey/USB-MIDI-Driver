//
//  GraphBackground.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.04.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import UIKit

// This view contains elements that don't change every frame (the "background" stuff)
// e.g. The graph reference lines, expected event, chroma etc.

@IBDesignable class GraphBackground: UIView {

    override func draw(_ rect: CGRect) {

        let viewWidth = rect.width
        let viewHeight = rect.height
        
        let marginWidth: CGFloat = 15.0
        var topBorder: CGFloat { return 20 + bounds.height * 0.01 }
        var bottomBorder: CGFloat { return bounds.height * 0.04 }

        let graphHeight = viewHeight - topBorder - bottomBorder
        
        
        //Draw horizontal graph lines behind everything
        let linePath = UIBezierPath()
        linePath.lineWidth = 1.0
        
        // Top line
        linePath.move(to: CGPoint(x:marginWidth, y: topBorder))
        linePath.addLine(to: CGPoint(x: viewWidth - marginWidth,
            y:topBorder))

        // Bottom line
        linePath.move(to: CGPoint(x:marginWidth,
            y:viewHeight - bottomBorder))
        linePath.addLine(to: CGPoint(x:viewWidth - marginWidth,
            y:viewHeight - bottomBorder))
        
        
        // Draw the graph lines
        UIColor(white: 0.85, alpha: 1.0).setStroke()
        linePath.stroke()
        linePath.removeAllPoints()


        // Similarity threshhold line (at similarity == 0.7)
        linePath.move(to: CGPoint(x:marginWidth,
            y: graphHeight * 0.3 + topBorder))
        linePath.addLine(to: CGPoint(x:viewWidth - marginWidth,
            y:graphHeight * 0.3 + topBorder))

        UIColor(white: 0.95, alpha: 1.0).setStroke()
        linePath.stroke()

    }

}
