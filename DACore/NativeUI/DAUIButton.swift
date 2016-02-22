//
//  DAUIButton.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit
class DAUIButton : DAUIView
{
    var button:DAButtonBase!
    
    
}

class DAButtonControl : DAButtonControlBase
{
    override func updateDisplay()
    {
        if(highlighted)
        {
            transform = CGAffineTransformMakeScale(DAScaleButton.DOWN_SCALE,DAScaleButton.DOWN_SCALE)
        }else{
            transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
}

class DAScaleButtonControl :DAButtonControlBase
{
    static var DOWN_SCALE:CGFloat = 0.85
    
    
}

class DAButtonControlBase : UIControl
{
    static var TOUCH_EXPANSION = 10
    static var DEFAULT_TOUCH_COOLDOWN = 0.0
    
    static var DEFAULT_BUTTON_SOUND:String?
    
    var buttonSound:String?
    
    //SIGNALS
    let onButtonDown = Signal<DAButtonControlBase>()
    let onButtonUp = Signal<DAButtonControlBase>()
    let onButtonClick = Signal<DAButtonControlBase>()
    
    var isTouching:Bool = false
    var lastTouch:NSTimeInterval = 0
    
    var touchRect:CGRect?
    
    var lastPress = NSDate()
    var cooldown:Double = 0.0
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        
        buttonSound = DAButtonControlBase.DEFAULT_BUTTON_SOUND
        cooldown = DAButtonControlBase.DEFAULT_TOUCH_COOLDOWN
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var highlighted:Bool
    {
        get
        {
            return super.highlighted
        }
        set(new_state)
        {
            if(new_state == highlighted)
            {
                return
            }
            
            super.highlighted = new_state
            updateDisplay()
        }
    }
    

    func updateDisplay()
    {
        //VIRTUAL -- OVERRIDE ME
    }
    
    //invisible buttons should fire NO EVENTS -- this could be a little
    //slow but the alternative is pretty gross
    func recursiveHidden() -> Bool
    {
        var temp_parent:UIView?
        
        temp_parent = superview
        while(temp_parent != nil)
        {
            if(temp_parent!.hidden)
            {
                //print("\(temp_parent!) \(temp_parent!.name) is hidden")
                return true
            }
            temp_parent = temp_parent!.superview
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
        

        if(superview == nil)
        {
            return
        }
        
        
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
        
        isTouching = true
        highlighted = true

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(!isTouching)
        {
            return
        }
        
        if(superview == nil)
        {
            return
        }
        
        if let touch = touches.first
        {
            let location: CGPoint = touch.locationInView(superview)
            
            let expanded_rect = frame.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if CGRectContainsPoint(expanded_rect, location)
            {
                highlighted = true
            }else{
                highlighted = false
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(!isTouching)
        {
            return
        }
        
        if(superview == nil)
        {
            return
        }
        
        
        if let touch = touches.first
        {
            let location: CGPoint = touch.locationInView(superview)
            
            let expanded_rect = frame.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if CGRectContainsPoint(expanded_rect, location)
            {
                highlighted = true
            }else{
                highlighted = false
            }
        }
        
        if(highlighted)
        {
            highlighted = false
            
            if(enabled)
            {
                lastPress = NSDate()
                onButtonUp.fire(self)
                onButtonClick.fire(self)
            }
            
            if let sfx = buttonSound
            {
                print("PLAY BUTTON SOUND \(sfx)")
                DASoundManager.playSound(sfx)
            }
        }
    }
    
}

