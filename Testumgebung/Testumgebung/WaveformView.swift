//
//  WaveformView.swift
//  Testumgebung
//
//  Created by flowing erik on 13.07.15.
//  Copyright (c) 2015 flowkey GmbH. All rights reserved.
//

import UIKit

@IBDesignable class WaveformView: GraphView {
    override var columnGap: CGFloat { return 0 }
    override var minimumThreshold: Float { return 0.3 } // make the graph look silent more often

    override func setupLayers(_ count: Int) {
        super.setupLayers(count)

        layers.forEach { layer in
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.frame.origin.y = topBorder
        }
    }
}
