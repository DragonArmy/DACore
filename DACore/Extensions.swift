//
//  Extensions.swift
//  
//  Extensions to base classes to make our code a little more portable to other languages such as AS3 or C#
//
//  Created by Will Hankinson on 1/28/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

/**
Arc Random for Double and Float
*/
public func arc4random <T: IntegerLiteralConvertible> (type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, Int(sizeof(T)))
    return r
}

public extension CGPoint
{
    func magnitude() -> CGFloat
    {
        return hypot(x, y)
    }
    
    func clamp(target_magnitude:CGFloat) -> CGPoint
    {
        let current_magnitude = magnitude()
        let scale_factor = target_magnitude / current_magnitude
        
        return CGPointMake(x*scale_factor, y*scale_factor)
    }
}

public extension CGRect
{
    var center:CGPoint
    {
            return CGPointMake(CGRectGetMidX(self), CGRectGetMidY(self))
    }
}

// CGPoint addition, which I do all the frickin time
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

//hashable XY coordinate
struct XY : Hashable, Equatable, Printable
{
    var x:Int
    var y:Int
    
    var hashValue : Int
        {
        get
        {
            return "\(x)_\(y)".hashValue
        }
    }
    
    var description: String
        {
        get
        {
            return "(\(x),\(y))"
        }
    }
}

func ==(left:XY, right:XY) -> Bool
{
    return (left.x == right.x && left.y == right.y)
}

func !=(left:XY, right:XY) -> Bool
{
    return !(left == right)
}

extension Set
{
    func anyItem<T>() -> T?
    {
        if self.count == 0
        {
            return nil
        }
        
        let n = Int(arc4random_uniform(UInt32(self.count)))
        let i = advance(self.startIndex, n)
        return self[i] as? T
    }
}

// Nice helper function for dispatch_after
func dispatch_after_delay(delay:Double, block:dispatch_block_t) {
    let queue = dispatch_get_main_queue()
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, queue, block)
}

//https://github.com/yeahdongcn/UIColor-Hex-Swift/blob/master/UIColorExtension.swift
public extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error: \(rgba)")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}


public extension Int {
    /**
    Create a random num Int
    :param: lower number Int
    :param: upper number Int
    :return: random number Int
    By DaRkDOG
    */
    public static func random (lower: Int , upper: Int) -> Int {
        var delta = upper - lower + 1;
        var random_value = Int(arc4random_uniform(UInt32(delta)))
        return lower + random_value
    }
    
}
public extension Double {
    /**
    Create a random num Double
    :param: lower number Double
    :param: upper number Double
    :return: random number Double
    By DaRkDOG
    */
    public static func random(#lower: Double, upper: Double) -> Double {
        let r = Double(arc4random(UInt64)) / Double(UInt64.max)
        return (r * (upper - lower)) + lower
    }
}
public extension Float {
    /**
    Create a random num Float
    :param: lower number Float
    :param: upper number Float
    :return: random number Float
    By DaRkDOG
    */
    public static func random(#lower: Float, upper: Float) -> Float {
        let r = Float(arc4random(UInt32)) / Float(UInt32.max)
        return (r * (upper - lower)) + lower
    }
}

public extension CGFloat {
    
    public static func random(#lower:CGFloat, upper:CGFloat) -> CGFloat {
        return CGFloat(Float.random(lower: Float(lower), upper:Float(upper)))
    }
}

extension String {
    func toFloat() -> Float
    {
        return (self as NSString).floatValue
    }
    
    func toCGFloat() -> CGFloat
    {
        return CGFloat( (self as NSString).floatValue )
    }
    
    func split(split_string:String) -> [String]
    {
        return self.componentsSeparatedByString(split_string)
    }
    
    func replace(target:String, withString replacement:String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func toColor() -> SKColor
    {
        return SKColor(rgba: self)
    }
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
    
    func indexOf(target: String) -> Int
    {
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil) ? true : false
    }
}

extension Array {
    func indexOf<T : Equatable>(object:T) -> Int?
    {
        for (index,obj) in enumerate(self)
        {
            if let typed_obj = obj as? T
            {
                if typed_obj == object
                {
                    return index
                }
            }
        }
        return nil
    }
    
    func last(how_many:Int) -> Array<T>
    {
        
        let lower = count - how_many
        let upper = count - 1
        
        return Array(self[lower...upper])
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
            println("[ERROR] -- can't convert coordinate spaces if I'm not in the display tree!")
        }
        
        position = new_parent.convertPoint(position, fromNode: parent!)
        removeFromParent()
        new_parent.addChild(self)
    }
    
    func moveToBack()
    {
        if let actual_parent = parent
        {
            var index = find(actual_parent.children as! [SKNode], self)
            removeFromParent()
            actual_parent.insertChild(self, atIndex: 0)
            
            index = find(actual_parent.children as! [SKNode], self)
        }else{
            println("[ERROR] Cannot call moveToBack on a node with no parent!")
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
            println("[ERROR] Cannot call moveToFront on a node with no parent!")            
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
        
        println("STARTING WITH SCALE \(self.scale)    -   \(self.name)")
        
        while(current_parent != nil)
        {
            println("MULTIPLY BY \(current_parent!.scale)")
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