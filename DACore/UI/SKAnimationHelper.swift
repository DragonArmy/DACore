//
//  SKAnimationHelper.swift
//  tracecrossy
//
//  Created by Will Hankinson on 8/20/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

class SKAnimationHelper
{
    
    static func pulseWithDuration(node:SKNode, sizeMultiplier size:CGFloat, duration:TimeInterval)
    {
        let scale = node.scale
        
        let grow = SKAction.scale(to: scale*size, duration: duration/2)
        let shrink = SKAction.scale(to: scale, duration: duration/2)
        
        grow.timingMode = SKActionTimingMode.easeOut
        shrink.timingMode = SKActionTimingMode.easeIn
        
        let pulse = SKAction.sequence([grow,shrink])
        node.run(pulse)
    }
    
    
    
}
