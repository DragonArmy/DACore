//
//  DAScaleButton.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit


class DAScaleButton : DAButtonBase
{
    override init()
    {
        super.init()
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    
    var _isButtonDown:Bool = false
    override var isButtonDown:Bool
    {
        get
        {
            return _isButtonDown
        }
    
        set(new_state)
        {
            if(new_state == _isButtonDown)
            {
                return
            }
            
            _isButtonDown = new_state
            
            updateDisplay()
        }
    }
    
    override func updateDisplay()
    {
        if(_isButtonDown)
        {
            setScale(0.85)
        }else{
            setScale(1.0)
        }
    }
    
}