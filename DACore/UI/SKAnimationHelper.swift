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
    
    static func pulseWithDuration(node:SKNode, sizeMultiplier size:CGFloat, duration:NSTimeInterval)
    {
        let scale = node.scale
        
        let grow = SKAction.scaleTo(scale*size, duration: duration/2)
        let shrink = SKAction.scaleTo(scale, duration: duration/2)
        
        grow.timingMode = SKActionTimingMode.EaseOut
        shrink.timingMode = SKActionTimingMode.EaseIn
        
        let pulse = SKAction.sequence([grow,shrink])
        node.runAction(pulse)
    }
    
    
    
}