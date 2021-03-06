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
    var assetFolder:String = ""

    //set from metadata, NOT the frame
    var resetPosition = CGPoint.zero
    var resetSize = CGSize.zero
    var pivot = CGPoint(x: 0.0, y: 0.0)
    
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
            
            //if we're explicitly a container view (or a child), do NOT resize our children
            if let _ = self as? DAContainerView
            {
                return
            }
            
            //otherwise we're likely a wrapper around a UIView and need it to match our view
            for view in subviews
            {
                if let _ = view as? DAView
                {
                    continue
                }
                
                view.frame = CGRect(origin: CGPoint.zero, size: value.size)
            }
        }
    }
    
    override var description: String
    {
        get
        {
            let legacy = super.description
            
            let new_stuff = "\(self.name!)      resetPosition:\(resetPosition)             resetSize:\(resetSize)       pivot:\(pivot)"
            
            return "\(legacy) \n \(new_stuff)"
        }
    }
    
    
    init()
    {
        super.init(frame:CGRect.zero)
        
        //actually super handy to turn these all bright pink to debug hitboxes & placeholders
        //self.backgroundColor = "#f800af".toUIColor()
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
        let pivotPosition = resetPosition + pivot
        let x:CGFloat = pivotPosition.x
        let y:CGFloat = pivotPosition.y
        
        self.frame = CGRect(origin: CGPoint(x:x, y:y), size: resetSize)
        
        if(recursive)
        {
            resetChildren(recursive: true)
        }
    }
    
    func skCoordinateReset(recursive:Bool=true)
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
        
        
        if(recursive)
        {
            resetChildren(recursive: true)
        }
    }
    
    func resetChildren(recursive:Bool=false)
    {
        for view in subviews
        {
            if let resettable = view as? DAView
            {
                //percolate this down to children so if we clone a view we know where to load stuff from
                resettable.assetFolder = assetFolder
                
                resettable.rootWidth = rootWidth
                resettable.rootHeight = rootHeight
                resettable.reset(recursive: recursive)
            }
        }
    }
}
