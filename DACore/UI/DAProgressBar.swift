//
//  DAProgressBar.swift
//  testing
//
//  Created by Will Hankinson on 3/19/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit

enum DAProgressBarType : Int
{
    case SCALE
    case SLIDE
}


class DAProgressBar : DAContainerBase
{
    private var progressSprite:SKSpriteNode? = nil
    
    var progressBarType:DAProgressBarType = .SCALE
    
    private var _progress:Float = 1.0
    private var _progressX:CGFloat = 0
    
    var progress:Float
    {
        get
        {
            return _progress
        }
        set(value)
        {
//            print("[PROGRESS] VALUE=\(value)")
            if(value == _progress)
            {
                return
            }
            
            if(progressSprite == nil)
            {
                setupProgressSprite()
            }
            
            _progress = max(0,min(1,value))
            
            if(progressBarType == .SCALE)
            {
                progressSprite!.xScale = CGFloat(value)
            }else{
                //it seems like masked sprites maybe don't respect their anchors?
                progressSprite!.x = _progressX - CGFloat((1-value))*progressSprite!.width
            }
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
                if let fill_sprite = fill as? SKSpriteNode
                {
                    fill_sprite.anchorPoint = CGPoint(x:0.0, y:0.5)
                    fill_sprite.x -= fill_sprite.width/2
                    _progressX = fill_sprite.x
                    progressSprite = fill_sprite
                }else{
                    print("BUT IT WASN'T A SPRITE")
                }
            }else{
                print("[ERROR] PROGRESS BAR \(self.name!) IS MISSING \(short_name) _fill")
            }
        }
    }
}