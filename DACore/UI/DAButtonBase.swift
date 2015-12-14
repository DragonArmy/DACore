//
//  DAButtonBase.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit

class DAButtonBase : DAContainerBase
{
    static var TOUCH_EXPANSION:CGFloat = 10
    static var DEFAULT_TOUCH_COOLDOWN:Double = 0.0
    
    //THIS SHOULD BE SET IN YOUR GAMECONTROLLER BEFORE ANY BUTTONS ARE CREATED
    static var DEFAULT_BUTTON_SOUND:String?
    
    var buttonSound:String?
    
    var blocksTouches = true
    //how far is your touch allowed to wander before we assume you're touching something behind?
    var wanderAmount:CGFloat = 40.0
    var initialTouchPos = CGPoint.zero
    
    //SIGNALS
    let onButtonDown = Signal<DAButtonBase>()
    let onButtonUp = Signal<DAButtonBase>()
    let onButtonClick = Signal<DAButtonBase>()

    var isButtonDown:Bool = false
    var isTouching:Bool = false
    var lastTouch:NSTimeInterval = 0
    
    var touchRect:CGRect?
    var enabled = true
    
    var lastPress = NSDate()
    var cooldown:Double = 0.0
    
    override init()
    {
        super.init()
        
        userInteractionEnabled = true
        
        buttonSound = DAButtonBase.DEFAULT_BUTTON_SOUND
        cooldown = DAButtonBase.DEFAULT_TOUCH_COOLDOWN
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
        
        
        /********** TOUCH FORWARDING **********/
        if(!blocksTouches)
        {
            let touch = touches.first!
            if(touch.timestamp > lastTouch)
            {
                lastTouch = touch.timestamp
                let touch_pos = touch.locationInNode(scene!)
                initialTouchPos = touch_pos

                let hit_nodes = scene!.nodesAtPoint(touch_pos)
                for node in hit_nodes
                {
                    if(node == self)
                    {
                        continue
                    }
                    
                    if(node.userInteractionEnabled)
                    {
                        node.touchesBegan(touches, withEvent: event)
                    }
                }
            }
        }
        /********** END TOUCH FORWARDING **********/
        
        
        
        let press_time = NSDate()
        if(press_time.timeIntervalSinceDate(lastPress) < cooldown)
        {
            print("TOO SOON")
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
            //on passthrough buttons, play the SFX on button release so we don't get false clicks
            if(blocksTouches)
            {
                DASoundManager.playSound(sfx);
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(scene == nil)
        {
            return
        }
        
        /********** TOUCH FORWARDING **********/
        if(!blocksTouches)
        {
            let touch = touches.first!
            if(touch.timestamp > lastTouch)
            {
                lastTouch = touch.timestamp
                let touch_pos = touch.locationInNode(scene!)
                
                if((touch_pos - initialTouchPos).magnitude() > wanderAmount)
                {
                    isTouching = false
                    isButtonDown = false
                }
                
                let hit_nodes = scene!.nodesAtPoint(touch_pos)
                for node in hit_nodes
                {
                    if(node == self)
                    {
                        continue
                    }
                    
                    if(node.userInteractionEnabled)
                    {
                        node.touchesMoved(touches, withEvent: event)
                    }
                }
            }
        }
        /********** END TOUCH FORWARDING **********/
        
        if(!isTouching)
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
        if(scene == nil)
        {
            return
        }
        
        /********** TOUCH FORWARDING **********/
        if(!blocksTouches)
        {
            let touch = touches.first!
            if(touch.timestamp > lastTouch)
            {
                lastTouch = touch.timestamp
                let touch_pos = touch.locationInNode(scene!)
                let touch_view = touch.locationInView(scene!.view)
                print("POSITION IN SCENE: \(touch_pos)        VIEW: \(touch_view)")
                let hit_nodes = scene!.nodesAtPoint(touch_pos)
                for node in hit_nodes
                {
                    if(node == self)
                    {
                        continue
                    }
                    
                    if(node.userInteractionEnabled)
                    {
                        node.touchesEnded(touches, withEvent: event)
                    }
                }
            }
        }
        /********** END TOUCH FORWARDING **********/
        
        if(!isTouching)
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
                lastPress = NSDate()
                onButtonUp.fire(self)
                onButtonClick.fire(self)
            }
            
            if let sfx = buttonSound
            {
                //on passthrough buttons, play the SFX on button release so we don't get false clicks
                if(!blocksTouches)
                {
                    DASoundManager.playSound(sfx);
                }
            }
        }
    }

}