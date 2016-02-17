//
//  DAResetUIView.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DAUIView : UIView
{
    var name:String?
    
    var cachedMetadata = Dictionary<String, AnyObject>()

    //set from metadata, NOT the frame
    var resetPosition = CGPoint.zero
    var resetSize = CGSize.zero
    var pivot = CGPoint.zero
    
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
                if let da = view as? DAUIView
                {
                    continue
                }
                
                print("SETTING SUBVIEW \(view) TO FRAME \(value)")
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
        print("RESET \(name) to \(resetPosition), \(resetSize)")
        
        self.frame = CGRect(origin: resetPosition, size: resetSize)
        print("MY CENTER IS \(center)")
        
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
            if let resettable = view as? DAUIView
            {
                resettable.reset(recursive)
            }
        }
    }
}