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
    var resetSize = CGPoint.zero
    
    //not strictly an anchor value but a fixed offset for all the contents
    private var _pivotX:CGFloat = 0;
    var pivotX:CGFloat
    {
        get
        {
            return _pivotX
        }
        set(value)
        {
            _pivotX = value
            print("TODO: PIVOTS")
        }
    }
    private var _pivotY:CGFloat = 0
    var pivotY:CGFloat
    {
        get
        {
            return _pivotY
        }
        set(value)
        {
            _pivotY = value
            print("TODO: PIVOTS")
        }
    }
    
    
    func reset(recursive:Bool=true)
    {
        print("RESET \(name) to \(reset)")
        
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