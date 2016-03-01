//
//  DAResetUIView.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DAView : UIView
{
    var name:String?
    
    var cachedMetadata = Dictionary<String, AnyObject>()

    //set from metadata, NOT the frame
    var resetPosition = CGPoint.zero
    var resetSize = CGSize.zero
    var pivot = CGPoint(x: 0.5, y: 0.5)
    
    var rootWidth:CGFloat = 0
    var rootHeight:CGFloat = 0
    
    //we want the wrapped content to have the same frame as we have...
    override var frame:CGRect
    {
        get
        {
            return super.frame
        }
        set(value)
        {
            super.frame = value
            for view in subviews
            {
                if let da = view as? DAView
                {
                    continue
                }
                
                view.frame = CGRect(origin: CGPoint.zero, size: value.size)
            }
        }
    }
    
    init()
    {
        super.init(frame:CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset(recursive:Bool=true)
    {
        let centerPosition = resetPosition + pivot
        
        var x:CGFloat = centerPosition.x
        var y:CGFloat = centerPosition.y

        if(superview == nil)
        {
            x = rootWidth/2 + x
            y = rootHeight/2 - y
        }else{
            x = superview!.frame.size.width/2 + x
            y = superview!.frame.size.height/2 - y
        }
        
        //offset to the top left
        x -= resetSize.width/2
        y -= resetSize.height/2
        
        //pivot is actually the inverse offset from center
        //it's important to set pivot before frame, as adjusting the pivot will move the position
        //while frame is pivot-agnostic
        if(pivot != CGPoint.zero && resetSize != CGSize.zero)
        {
            self.layer.anchorPoint = CGPoint(x: 0.5 + pivot.x/resetSize.width, y: 0.5 + pivot.y/resetSize.height)
        }
        
        self.frame = CGRect(origin: CGPoint(x:x, y:y), size: resetSize)
        
        
//        self.layer.anchorPoint = pivot
        
//        position = reset
//        
//        setScale(1)
//        zRotation = 0
//        hidden = false
//        alpha = 1
        
        
        if(recursive)
        {
            resetChildren(recursive)
        }
    }
    
    func resetChildren(recursive:Bool=false)
    {
        for view in subviews
        {
            if let resettable = view as? DAView
            {
                resettable.rootWidth = rootWidth
                resettable.rootHeight = rootHeight
                resettable.reset(recursive)
            }
        }
    }
}