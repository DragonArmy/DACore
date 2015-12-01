//
//  DAResetNode.swift
//  tracecrossy
//
//  Created by Will Hankinson on 6/14/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit


class DAResetNode : SKNode
{
    var cachedMetadata = Dictionary<String, AnyObject>()
    
    var resetPosition : CGPoint?
    
    func reset(recursive:Bool=true)
    {
        if let reset = resetPosition
        {
//            print("RESET \(name) to \(reset)")
            position = reset
            
            setScale(1)
            zRotation = 0
            hidden = false
            alpha = 1
            
        }else{
            //IF WE DON'T HAVE A SPECIFIC RESET SET... DO NOTHING!
//            print("NO RESET FOUND FOR \(name)")
        }
        
        if(recursive)
        {
            resetChildren(recursive)
        }
    }
    
    func resetChildren(recursive:Bool=false)
    {
        for child in children
        {
            if let resettable = child as? DAResetNode
            {
                resettable.reset(recursive)
            }
        }
    }
}