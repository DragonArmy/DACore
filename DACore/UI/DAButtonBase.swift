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

    var isTouching:Bool = false
    var lastTouch:TimeInterval = 0
    
    var touchRect:CGRect?
    var enabled = true
    
    var lastPress = Date()
    var cooldown:Double = 0.0
    
    //if touchMask != nil, do a raycast of our touch in the scene and only allow touches IFF the touchMask was also touched!
    var touchMask:SKNode?
    
    override init()
    {
        super.init()
        
        isUserInteractionEnabled = true
        
        buttonSound = DAButtonBase.DEFAULT_BUTTON_SOUND
        cooldown = DAButtonBase.DEFAULT_TOUCH_COOLDOWN
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    var _isButtonDown:Bool = false
    var isButtonDown:Bool
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
            if(temp_parent!.isHidden)
            {
                //print("\(temp_parent!) \(temp_parent!.name) is hidden")
                return true
            }
            temp_parent = temp_parent!.parent
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
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
                let touch_pos = touch.location(in: scene!)
                initialTouchPos = touch_pos

                let hit_nodes = scene!.nodes(at:touch_pos)
                scene!.touchesBegan(touches, with: event)
                for node in hit_nodes
                {
                    if(node == self)
                    {
                        continue
                    }
                    
                    if(node.isUserInteractionEnabled)
                    {
                        node.touchesBegan(touches, with: event)
                    }
                }
            }
        }
        /********** END TOUCH FORWARDING **********/
        
        /********** TOUCH MASKING **********/
        if let mask = touchMask
        {
            let touch = touches.first!
            let touch_pos = touch.location(in: scene!)
            let hit_nodes = scene!.nodes(at: touch_pos)
            
            var in_mask = false
            
            for node in hit_nodes
            {
                if(node == mask)
                {
                    in_mask = true
                    break
                }
            }
            if(!in_mask)
            {
                print("TOUCHED BUT NOT IN OUR TOUCH MASK")
                return
            }
            
        }
        /********** END TOUCH MASKING **********/
        
        let press_time = Date()
        if(press_time.timeIntervalSince(lastPress) < cooldown)
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
                print("PLAY BUTTON SOUND \(sfx)")
                DASoundManager.playSound(sfx)
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
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
                let touch_pos = touch.location(in: scene!)
                
                if((touch_pos - initialTouchPos).magnitude() > wanderAmount)
                {
                    isTouching = false
                    isButtonDown = false
                }
                
                let hit_nodes = scene!.nodes(at: touch_pos)
                scene!.touchesMoved(touches, with:event)
                for node in hit_nodes
                {
                    if(node == self)
                    {
                        continue
                    }
                    
                    if(node.isUserInteractionEnabled)
                    {
                        node.touchesMoved(touches, with: event)
                    }
                }
            }
        }
        /********** END TOUCH FORWARDING **********/
        
        
        /********** TOUCH MASKING **********/
        if let mask = touchMask
        {
            let touch = touches.first!
            let touch_pos = touch.location(in: scene!)
            let hit_nodes = scene!.nodes(at: touch_pos)
            
            var in_mask = false
            
            for node in hit_nodes
            {
                if(node == mask)
                {
                    in_mask = true
                    break
                }
            }
            if(!in_mask)
            {
                print("TOUCHED BUT NOT IN OUR TOUCH MASK")
                return
            }
            
        }
        /********** END TOUCH MASKING **********/
        if(!isTouching)
        {
            return
        }
        
        if let touch = touches.first
        {
            let location: CGPoint = touch.location(in: parent!)

            let expanded_rect = touchRect!.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if expanded_rect.contains(location)
            {
                isButtonDown = true
            }else{
                isButtonDown = false
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
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
                let touch_pos = touch.location(in: scene!)
                
                let hit_nodes = scene!.nodes(at: touch_pos)
                scene!.touchesEnded(touches, with: event)
                for node in hit_nodes
                {
                    if(node == self)
                    {
                        continue
                    }
                    
                    if(node.isUserInteractionEnabled)
                    {
                        node.touchesEnded(touches, with: event)
                    }
                }
            }
        }
        /********** END TOUCH FORWARDING **********/
        
        
        /********** TOUCH MASKING **********/
        if let mask = touchMask
        {
            let touch = touches.first!
            let touch_pos = touch.location(in: scene!)
            let hit_nodes = scene!.nodes(at: touch_pos)
            
            var in_mask = false
            
            for node in hit_nodes
            {
                if(node == mask)
                {
                    in_mask = true
                    break
                }
            }
            if(!in_mask)
            {
                print("TOUCHED BUT NOT IN OUR TOUCH MASK")
                return
            }
            
        }
        /********** END TOUCH MASKING **********/
        
        
        if(!isTouching)
        {
            return
        }
        
        
        if let touch = touches.first
        {
            let location: CGPoint = touch.location(in: parent!)
            
            let expanded_rect = touchRect!.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if expanded_rect.contains(location)
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
                lastPress = Date()
                onButtonUp.fire(self)
                onButtonClick.fire(self)
            }
            
            if let sfx = buttonSound
            {
                //on passthrough buttons, play the SFX on button release so we don't get false clicks
                if(!blocksTouches)
                {
                    print("PLAY BUTTON SOUND \(sfx)")
                    DASoundManager.playSound(sfx)
                }
            }
        }
    }

}
