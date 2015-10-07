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
    static var TOUCH_EXPANSION:CGFloat = 10
    
    //THIS SHOULD BE SET IN YOUR GAMECONTROLLER BEFORE ANY BUTTONS ARE CREATED
    static var DEFAULT_BUTTON_SOUND:String?
    
    var buttonSound:String?
    
    //SIGNALS
    let onButtonDown = Signal<DAButtonBase>()
    let onButtonUp = Signal<DAButtonBase>()
    let onButtonClick = Signal<DAButtonBase>()

    var isButtonDown:Bool = false
    var isTouching:Bool = false
    
    var touchRect:CGRect?
    var enabled = true
    
    override init()
    {
        super.init()
        
        userInteractionEnabled = true
        
        buttonSound = DAButtonBase.DEFAULT_BUTTON_SOUND
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
                //print("\(temp_parent!) \(temp_parent!.name) is hidden")
                return true
            }
            temp_parent = temp_parent!.parent
        }
        
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        isTouching = false;
        
        if(recursiveHidden())
        {
            print("PARENT IS HIDDEN, NO TOUCH FOR YOU")
            return
        }
        
        if(scene == nil)
        {
            return
        }
        
        if(enabled)
        {
            onButtonDown.fire(self);
        }
        
        touchRect = calculateAccumulatedFrame()
        
        isTouching = true
        isButtonDown = true
        
        if let sfx = buttonSound
        {
//            print("PLAYING SOUND \(sfx)")
            DASoundManager.playSound(sfx);
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(!isTouching)
        {
            return
        }
        
        if(scene == nil)
        {
            return
        }
        
        
        if let touch = touches.first
        {
            let location: CGPoint = touch.locationInNode(parent!)

            let expanded_rect = touchRect!.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if CGRectContainsPoint(expanded_rect, location)
            {
                isButtonDown = true
            }else{
                isButtonDown = false
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(!isTouching)
        {
            return
        }
        
        if(scene == nil)
        {
            return
        }
        
        
        if let touch = touches.first
        {
            let location: CGPoint = touch.locationInNode(parent!)
            
            let expanded_rect = touchRect!.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if CGRectContainsPoint(expanded_rect, location)
            {
                isButtonDown = true
            }else{
                isButtonDown = false
            }
        }
        
        if(isButtonDown)
        {
            isButtonDown = false
            
            if(enabled)
            {
                onButtonUp.fire(self)
                onButtonClick.fire(self)
            }
        }
    }

}