//
//  DAButtonView.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit
class DAButtonViewBase : DAView
{
    static var TOUCH_EXPANSION = 10
    static var DEFAULT_TOUCH_COOLDOWN = 0.0
    
    static var DEFAULT_BUTTON_SOUND:String?
    
    var buttonSound:String?
    
    //SIGNALS
    let onButtonDown = Signal<DAButtonViewBase>()
    let onButtonUp = Signal<DAButtonViewBase>()
    let onButtonClick = Signal<DAButtonViewBase>()
    
    var isTouching:Bool = false
    var lastTouch = NSDate()
    
    var touchRect:CGRect?
    
    var lastPress = NSDate()
    var cooldown:Double = 0.0
    var minimumPressTime:Double = 0.25
    
    var enabled = true
    
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
            
            
            if(new_state == true)
            {
                //press down right away, delay on the up state
                updateDisplay()
                return
            }
            
            
            let time = NSDate()
            if(lastTouch.timeIntervalSince(time as Date) < minimumPressTime)
            {
                let delta = minimumPressTime - lastTouch.timeIntervalSince(time as Date)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delta, execute: updateDisplay)
            }else{
                updateDisplay()
            }
        }
    }
    
    override init()
    {
        super.init()
        
        isUserInteractionEnabled = true
        
        buttonSound = DAButtonViewBase.DEFAULT_BUTTON_SOUND
        cooldown = DAButtonViewBase.DEFAULT_TOUCH_COOLDOWN
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
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
            if(temp_parent!.isHidden)
            {
                //print("\(temp_parent!) \(temp_parent!.name) is hidden")
                return true
            }
            temp_parent = temp_parent!.superview
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        isTouching = false;
        
        if(recursiveHidden())
        {
            return
        }
        
        if(superview == nil)
        {
            return
        }
        
        lastTouch = NSDate()
        if(lastTouch.timeIntervalSince(lastPress as Date) < cooldown)
        {
            print("TOO SOON")
            return
        }
        
        if(enabled)
        {
            onButtonDown.fire(self);
        }else{
            //don't modify isButtonDown or touch state if we're disabled
            return
        }
        
        isTouching = true
        isButtonDown = true
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
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
            let location: CGPoint = touch.location(in: superview)
            
            let expanded_rect = frame.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
            //use touchRect instead of self b/c our size can change based on input
            if expanded_rect.contains(location)
            {
                isButtonDown = true
            }else{
                isButtonDown = false
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        if(!isTouching)
        {
            return
        }
        if(superview == nil)
        {
            return
        }
        
        isButtonDown = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
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
            let location: CGPoint = touch.location(in: superview)
            
            let expanded_rect = frame.insetBy(dx: -DAButtonBase.TOUCH_EXPANSION, dy: -DAButtonBase.TOUCH_EXPANSION)
            
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




