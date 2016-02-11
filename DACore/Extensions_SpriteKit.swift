//
//  Extensions_SpriteKit.swift
//  catchsports
//
//  Created by Will Hankinson on 2/4/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import SpriteKit


extension String
{
    func toColor() -> SKColor
    {
        return SKColor(rgba: self)
    }
}

extension SKNode
{
    func indexInParent() -> Int?
    {
        if(parent == nil)
        {
            return nil
        }
        
        return parent!.children.indexOf(self)
    }
    
    func transferInPlace(new_parent:SKNode)
    {
        if(parent == nil)
        {
            print("[ERROR] -- can't convert coordinate spaces if I'm not in the display tree!")
        }
        
        position = new_parent.convertPoint(position, fromNode: parent!)
        removeFromParent()
        new_parent.addChild(self)
    }
    
    func moveToBack()
    {
        if let actual_parent = parent
        {
            removeFromParent()
            actual_parent.insertChild(self, atIndex: 0)
        }else{
            print("[ERROR] Cannot call moveToBack on a node with no parent!")
            fatalError("Cannot call moveToBack on a node with no parent!")
        }
    }
    
    func moveToFront()
    {
        if let actual_parent = parent
        {
            removeFromParent()
            actual_parent.addChild(self)
        }else{
            print("[ERROR] Cannot call moveToFront on a node with no parent!")
            fatalError("Cannot call moveToFront on a node with no parent!")
        }
    }
    
    var x : CGFloat
        {
        get
        {
            return position.x
        }
        
        set(value)
        {
            position = CGPointMake(value, position.y)
        }
    }
    
    var y : CGFloat
        {
        get
        {
            return position.y
        }
        
        set(value)
        {
            position = CGPointMake(position.x, value)
        }
    }
    
    var width : CGFloat
        {
        get
        {
            return calculateAccumulatedFrame().width
        }
        
        set(value)
        {
            let base_width = calculateAccumulatedFrame().width / xScale
            xScale = value / base_width
        }
    }
    
    var height : CGFloat
        {
        get
        {
            return calculateAccumulatedFrame().height
        }
        
        set(value)
        {
            let base_height = calculateAccumulatedFrame().height / yScale
            yScale = value / base_height
        }
    }
    
    var scale : CGFloat
        {
        get
        {
            return xScale
        }
    }
    
    var globalScale : CGFloat
        {
            var working_scale = self.scale
            var current_parent = self.parent
            
            print("STARTING WITH SCALE \(self.scale)    -   \(self.name)")
            
            while(current_parent != nil)
            {
                print("MULTIPLY BY \(current_parent!.scale)")
                working_scale = working_scale * current_parent!.scale
                current_parent = current_parent!.parent
            }
            return working_scale
    }
    
}

extension SKSpriteNode
{
    var anchorX : CGFloat
        {
        get
        {
            return anchorPoint.x
        }
        
        set(value)
        {
            anchorPoint = CGPointMake(value, anchorPoint.y)
        }
    }
    
    var anchorY : CGFloat
        {
        get
        {
            return anchorPoint.y
        }
        
        set(value)
        {
            anchorPoint = CGPointMake(anchorPoint.x, value)
        }
    }
}