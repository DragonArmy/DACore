//
//  DAScale9.swift
//  testing
//
//  Created by Will Hankinson on 3/19/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

//mostly an alias for DAContainer, but also throwing the logic for making one into a static method here
class DAScale9 : DAContainerBase
{
    var baseWidth = CGFloat(0)
    var baseHeight = CGFloat(0)
    
    var _xScale:CGFloat = 1.0
    var _yScale:CGFloat = 1.0
    override var xScale:CGFloat
    {
        get
        {
            return _xScale
        }
        set(value)
        {
            _xScale = value
            update()
        }
    }
    
    override var yScale:CGFloat
    {
        get
        {
            return _yScale
        }
        
        set(value)
        {
            _yScale = value
            update()
        }
    }
    
    
    override init()
    {
        super.init()
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    func update()
    {
        //TODO: SCALE9 LOGIC
        println("SCALE ME GOOD BOSS: \(_xScale) x \(yScale)")
        
        
        let new_width = baseWidth * _xScale;
        let new_height = baseHeight * _yScale;
        
        let half_width = new_width * 0.5
        let half_height = new_height * 0.5
        
        var top_left_width = CGFloat(1.0)
        var top_left_height = CGFloat(1.0)
        var bot_right_width = CGFloat(1.0)
        var bot_right_height = CGFloat(1.0)
        
        let short_name = name!.replace("scale9_", withString: "")
        if let top_left = childNodeWithName(short_name + "_1")
        {
            top_left_width = top_left.width
            top_left_height = top_left.height
        }else{
            println("[ERROR] missing " + short_name + "_1 in scale9_" + short_name)
            return;
        }
        if let bot_right = childNodeWithName(short_name + "_9")
        {
            bot_right_width = bot_right.width
            bot_right_height = bot_right.height
        }else{
            println("[ERROR] missing " + short_name + "_9 in scale9_" + short_name)
            return;
        }
        
        
        for child in children
        {
            if let node = child as? SKSpriteNode
            {
                if let section = node.name?.split("_").last
                {
                    switch(section)
                    {
                        case "1":
                            node.anchorPoint = CGPoint(x:0.0, y:1.0)
                            node.x = -half_width
                            node.y = half_height
                            node.setScale(1.0)
                        case "2":
                            node.anchorPoint = CGPoint(x:0.5, y:1.0)
                            node.x = 0
                            node.y = half_height
                            node.width = new_width - bot_right_width - top_left_width
                            node.yScale = 1.0
                        case "3":
                            node.anchorPoint = CGPoint(x:1.0, y:1.0)
                            node.x = half_width
                            node.y = half_height
                            node.setScale(1.0)
                        case "4":
                            node.anchorPoint = CGPoint(x:0.0, y:0.5)
                            node.x = -half_width
                            node.y = 0
                            node.width = top_left_height
                            node.height = new_height - bot_right_height - top_left_height
                        case "5":
                            node.anchorPoint = CGPoint(x:0.5, y:0.5)
                            node.x = 0
                            node.y = 0
                            node.width = new_width - bot_right_width - top_left_width
                            node.height = new_height - bot_right_height - top_left_height
                        case "6":
                            node.anchorPoint = CGPoint(x:1.0, y:0.5)
                            node.x = half_width
                            node.y = 0
                            node.width = bot_right_width
                            node.height = new_height - bot_right_height - top_left_height
                        case "7":
                            node.anchorPoint = CGPoint(x:0.0, y:0.0)
                            node.x = -half_width
                            node.y = -half_height
                            node.setScale(1.0)
                        case "8":
                            node.anchorPoint = CGPoint(x:0.5, y:0.0)
                            node.x = 0
                            node.y = -half_height
                            node.width = new_width - bot_right_width - top_left_width
                            node.yScale = 1.0
                        case "9":
                            node.anchorPoint = CGPoint(x:1.0, y:0.0)
                            node.x = half_width
                            node.y = -half_height
                            node.setScale(1.0)
                        
                        default:
                            println("UNRECOGNIZED SCALE9 PIECE: \(node.name!)")
                    }
                }
            }
        }
        
    }
}




