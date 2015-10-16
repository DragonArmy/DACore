//
//  DAScroller.swift
//
//  Created by Will Hankinson on 8/13/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//
// ported to Swift from RXScroller https://gist.github.com/MattRix/9885857
//

import SpriteKit

func ==(left:DAScroller, right:DAScroller) -> Bool
{
    let tests = [
        left.position == right.position,
        left.boundsMax == right.boundsMax,
        left.boundsMin == right.boundsMin,
        left.speed == right.speed
    ]
    
    for bool in tests
    {
        if(!bool)
        {
            return false
        }
    }
    
    return true
}

func ==(left:DAScroller?, right:DAScroller) -> Bool
{
    if let test = left
    {
        return (test == right)
    }else{
        return false
    }
}

func ==(left:DAScroller, right:DAScroller?) -> Bool
{
    if let test = right
    {
        return (test == left)
    }else{
        return false
    }
}


class DAScroller
{
    //note: these are variables in case you want to set them on a per-scroller basis
    var MAX_DRAG_SPEED:CGFloat = 80.0       //maximum drag speed in pixels-per-update
    var EDGE_SQUISH:CGFloat = 160.0         //how far to go past the end in pixels
    var EDGE_SQUISH_RATIO:CGFloat = 0.55    //keep below 1, it's the ratio of edge squish (0.55 is Apple's default)
    var EDGE_BOUNCE:CGFloat = 0.19          //how much force to use to bounce back
    var STRONG_FRICTION:CGFloat = 0.75      //used to bring it to a stop quicker
    var WEAK_FRICTION:CGFloat = 0.99        //used when throwing it at high speed
    var SLOW_SPEED:CGFloat = 3.0            //below this speed it will be brought to a stop quickly
    
    private var _isDragging = false
    private var _position:CGFloat = 0
    private var _speed:CGFloat = 0
    
    private var _basePosition:CGFloat = 0
    private var _baseTouchPosition:CGFloat = 0
    
    private var _previousPos:CGFloat = 0
    
    private var _boundsMin:CGFloat = 0
    private var _boundsMax:CGFloat = 0
    private var _dragSpeed:CGFloat = 0
    
    private var _shouldDetermineSpeed = false
    
    convenience init()
    {
        self.init(position: 0, boundsMin:0, boundsMax:0)
    }
    
    init(position:CGFloat, boundsMin bounds_min:CGFloat, boundsMax bounds_max:CGFloat)
    {
        _position = position
        _boundsMin = bounds_min
        _boundsMax = bounds_max
    }
    
    func beginDrag(touch_position:CGFloat)
    {
        if(_isDragging)
        {
            return
        }
        
        _isDragging = true
        _baseTouchPosition = touch_position
        
        _basePosition = _position
        _dragSpeed = 0
    }
    
    
    func endDrag(touch_position:CGFloat)
    {
        if(!_isDragging)
        {
            return
        }
        
        _isDragging = false
        
        updateDrag(touch_position)
        _shouldDetermineSpeed = true
    }
    
    func cancelDrag()
    {
        if(!_isDragging)
        {
            return
        }
        
        _isDragging = false
        
        _speed = 0
        _dragSpeed = 0
    }
    
    func update() -> Bool
    {
        _dragSpeed += (_position - _previousPos - _dragSpeed) * 0.5
        
        if(_shouldDetermineSpeed)
        {
            _shouldDetermineSpeed = false
            _speed = _dragSpeed
        }
        
        _previousPos = _position
        
        if(_isDragging)
        {
            return true
        }
        
        var diff:CGFloat = 0
        if(_position < _boundsMin)
        {
            diff = _boundsMin - _position
        }else if(_position > _boundsMax){
            diff = _boundsMax - _position
        }
        
        if(abs(_speed) > 0.01 || abs(diff) > 1.0)
        {
            if(abs(_speed) < SLOW_SPEED || abs(diff) > 0.0) //slow it down a lot if it's close to stopping or past the edge
            {
                _speed = _speed * STRONG_FRICTION
            }else{
                _speed = _speed * WEAK_FRICTION
            }
            
            _position += _speed + diff*EDGE_BOUNCE
            
            return true //still moving
        }else{
            _speed = 0
            
            //put it at the exact edge
            if(_position < _boundsMin)
            {
                _position = _boundsMin
            }else if(_position > _boundsMax){
                _position = _boundsMax
            }
            
            return false //not moving any more
        }
    }
    
    func updateDrag(touch_position:CGFloat)
    {
        let absolute_position = _basePosition - (touch_position - _baseTouchPosition)
        var diff:CGFloat = 0 //amount of movement needed to bring absolutePos back in bounds
        
        if(absolute_position < _boundsMin)
        {
            
            diff = _boundsMin - absolute_position
            
            let result = (1.0 - (1.0 / ((diff * EDGE_SQUISH_RATIO / EDGE_SQUISH) + 1.0))) * EDGE_SQUISH

            _position = _boundsMin - result
        }else if(absolute_position > _boundsMax){

            diff = absolute_position - _boundsMax
            print("DIFF: \(diff)")
            
            let result = (1.0 - (1.0 / ((diff * EDGE_SQUISH_RATIO / EDGE_SQUISH) + 1.0))) * EDGE_SQUISH
            
            _position = _boundsMax + result
        }else{
            _position = absolute_position
        }
    }
    
    func setPosition(position:CGFloat, andSpeed:CGFloat)
    {
        _position = position
        _speed = speed
    }
    
    var position:CGFloat
    {
        get
        {
            return _position
        }
        set(value)
        {
            _position = value
        }
    }
    
    var speed:CGFloat
    {
        get
        {
            return _speed
        }
        set(value)
        {
            _speed = value
        }
    }
    
    func setBounds(min min:CGFloat, max:CGFloat)
    {
        _boundsMin = min
        _boundsMax = max
    }
    
    func getDragDelta() -> CGFloat
    {
        return _position - _basePosition
    }
    
    func getDragDistance() -> CGFloat
    {
        return abs(_position - _basePosition)
    }
    
    var isDragging:Bool
    {
        return _isDragging
    }
    
    var boundsMin:CGFloat
    {
        return _boundsMin
    }
    
    var boundsMax:CGFloat
    {
        return _boundsMax
    }

}