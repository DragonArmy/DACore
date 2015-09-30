//
//  DAProgressBar.swift
//  testing
//
//  Created by Will Hankinson on 3/19/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

class DAProgressBar : DAContainerBase
{
    var progressSprite:SKSpriteNode? = nil
    
    
    private var _progress:Float = 1.0
    var progress:Float
    {
        get
        {
            return _progress
        }
        set(value)
        {
            if(value == _progress)
            {
                return
            }
            
            if(progressSprite == nil)
            {
                setupProgressSprite()
            }
            
            _progress = value
            progressSprite?.xScale = CGFloat(value)
        }
    }
    
    override init()
    {
        super.init();
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setupProgressSprite()
    {
        if let short_name = self.name?.replace("progress_", withString:"")
        {
            if let fill = self.childNodeWithName("//" + short_name + "_fill")
            {
                print("FILL SPRITE FOUND: \(fill)")
                if let fill_sprite = fill as? SKSpriteNode
                {
                    fill_sprite.anchorPoint = CGPoint(x:0.0, y:0.5)
                    fill_sprite.x -= fill_sprite.width/2
                    progressSprite = fill_sprite
                }else{
                    print("BUT IT WASN'T A SPRITE")
                }
            }else{
                print("[ERROR] PROGRESS BAR " + self.name! + " IS MISSING " + short_name + "_fill")
            }
        }
    }
}