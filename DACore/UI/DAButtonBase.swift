//
//  DAButtonBase.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

class DAButtonBase : DAContainerBase
{
    //SIGNALS
    let onButtonDown = Signal<DAButtonBase>()
    let onButtonUp = Signal<DAButtonBase>()
    let onButtonClick = Signal<DAButtonBase>()

    var isButtonDown:Bool = false
    var isTouching:Bool = false
    
    var touchRect:CGRect?
    
    override init()
    {
        super.init()
        
        userInteractionEnabled = true
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    func updateDisplay()
    {
        //TODO: OVERRIDE ME
    }
    
    //invisible buttons should fire NO EVENTS -- this could be a little
    //slow but the alternative is pretty gross
    func recursiveHidden() -> Bool
    {
        var temp_parent:SKNode?
        
        temp_parent = parent
        while(temp_parent != nil)
        {
            if(temp_parent!.hidden)
            {
                //println("\(temp_parent!) \(temp_parent!.name) is hidden")
                return true
            }
            temp_parent = temp_parent!.parent
        }
        
        return false
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if(recursiveHidden())
        {
            println("PARENT IS HIDDEN, NO TOUCH FOR YOU")
            return
        }
        
        onButtonDown.fire(self);
        
        touchRect = calculateAccumulatedFrame()
        
        isTouching = true
        isButtonDown = true
    }
    
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if(!isTouching)
        {
            return
        }
        
        if let touch = touches.first as? UITouch
        {
            var location: CGPoint = touch.locationInNode(parent)

            //use touchRect instead of self b/c our size can change based on input
            if CGRectContainsPoint(touchRect!, location)
            {
                isButtonDown = true
            }else{
                isButtonDown = false
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if(!isTouching)
        {
            return
        }
        
        if let touch = touches.first as? UITouch
        {
            var location: CGPoint = touch.locationInNode(parent)
            
            //use touchRect instead of self b/c our size can change based on input
            if CGRectContainsPoint(touchRect!, location)
            {
                isButtonDown = true
            }else{
                isButtonDown = false
            }
        }
        
        if(isButtonDown)
        {
            isButtonDown = false
            
            onButtonUp.fire(self)
            onButtonClick.fire(self)
        }
    }

}