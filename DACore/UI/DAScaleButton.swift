//
//  DAScaleButton.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit


class DAScaleButton : DAButtonBase
{
    static var DOWN_SCALE:CGFloat = 0.85
    
    override func updateDisplay()
    {
        if(_isButtonDown)
        {
            setScale(DAScaleButton.DOWN_SCALE)
        }else{
            setScale(1.0)
        }
    }
    
}