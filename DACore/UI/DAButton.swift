//
//  DAButton.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

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
                        node_child.isHidden = !_isButtonDown
                    }else if(tag == "up"){
                        node_child.isHidden = _isButtonDown
                    }else{
                        //do nothing! keep your state
                    }
                }
            }
        }
    }

    
}
