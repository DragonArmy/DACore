//
//  DAButton.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit


class DAButton : DAButtonBase
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
        for child:AnyObject in children
        {
            if let node_child = child as? SKNode
            {
                if let node_name = node_child.name
                {
                    let tag = node_name.split("_").last!
                    
                    if(tag == "down")
                    {
                        node_child.hidden = !_isButtonDown
                    }else if(tag == "up"){
                        node_child.hidden = _isButtonDown
                    }else{
                        //do nothing! keep your state
                    }
                }
            }
        }
    }

    
}