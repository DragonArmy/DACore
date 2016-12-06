//
//  Extensions.swift
//
//  Extensions to base classes to make our code a little more portable to other languages such as AS3 or C#
//
//  Created by Will Hankinson on 1/28/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import UIKit
import SpriteKit


extension UIApplication
{
    public static func isSimulator() -> Bool
    {
        return TARGET_IPHONE_SIMULATOR == 1
    }
}


//hashable XY coordinate
struct XY : Hashable, Equatable, CustomStringConvertible
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
        let i = index(self.startIndex, offsetBy: n)
        return self[i] as? T
    }
}

//https://github.com/yeahdongcn/UIColor-Hex-Swift/blob/master/UIColorExtension.swift
public extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex     = rgba.substring(from:index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch (hex.characters.count) {
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
                print("Scan hex error: \(rgba)")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}


public extension Int
{
    public static func random (lower: Int , upper: Int) -> Int
    {
        let delta = upper - lower + 1;
        let random_value = Int(arc4random_uniform(UInt32(delta)))
        //        print(lower)
        //        print(random_value)
        return (lower + random_value)
    }
    
}
public extension Double
{
    /**
     Create a random num Double
     - parameter lower: number Double
     - parameter upper: number Double
     :return: random number Double
     By DaRkDOG
     */
    public static func random(lower: Double, upper: Double) -> Double
    {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}
public extension Float {
    /**
     Create a random num Float
     - parameter lower: number Float
     - parameter upper: number Float
     :return: random number Float
     By DaRkDOG
     */
    public static func random(lower: Float, upper: Float) -> Float
    {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

public extension CGFloat {
    
    public static func random(lower:CGFloat, upper:CGFloat) -> CGFloat
    {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

public func * (left: String, right: Int) -> String
{
    if(right <= 0)
    {
        fatalError("Cannot multiply a string by a number <= 0")
    }
    
    if(right == 1)
    {
        return left
    }
    
    var str = ""
    for _ in (0..<right)
    {
        str = str + left
    }
    return str
}

public func * (left: Int, right: String) -> String
{
    return right * left
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
    
    func split(_ split_string:String) -> [String]
    {
        return self.components(separatedBy: split_string)
    }
    
    func replace(_ target:String, withString replacement:String) -> String
    {
        return self.replacingOccurrences(of: target, with: replacement)
    }
    
    func toUIColor() -> UIColor
    {
        return UIColor(rgba:self)
    }
    
    subscript (i: Int) -> Character
    {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String
    {
        return String(self[i] as Character)
    }
    
//    subscript (r: Range<Int>) -> String {
//        let start = startIndex.advancedBy(r.lowerBound)
//        let end = start.advancedBy(r.upperBound - r.lowerBound)
//        return self[Range(start ..< end)]
//    }
    
    func indexOf(_ target: String) -> Int
    {
        let range = self.range(of:target)
        if let range = range
        {
            return self.distance(from: self.startIndex, to:range.lowerBound)
        } else {
            return -1
        }
    }
    
}

extension Array {
    func indexOf<T : Equatable>(object:T) -> Int?
    {
        for (index,obj) in self.enumerated()
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
    
    func last(how_many:Int) -> Array<Element>
    {
        
        let lower = count - how_many
        let upper = count - 1
        
        return Array(self[lower...upper])
    }
    
    func shuffle() -> Array<Element>
    {
        return self.sorted(by: { (a, b) -> Bool in
            return Float.random(lower:0, upper:1) > 0.5
        })
    }
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
        
        return CGPoint(x:x*scale_factor, y:y*scale_factor)
    }
}

public extension CGVector
{
    func magnitude() -> CGFloat
    {
        return hypot(dx, dy)
    }
    
    func clamp(target_magnitude:CGFloat) -> CGPoint
    {
        let current_magnitude = magnitude()
        let scale_factor = target_magnitude / current_magnitude
        
        return CGPoint(x:dx*scale_factor, y:dy*scale_factor)
    }
}

public extension CGRect
{
    var center:CGPoint
    {
        return CGPoint(x:self.midX, y:self.midY)
    }
}

// CGPoint addition, which I do all the frickin time
public func + (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func += (left: inout CGPoint, right: CGPoint)
{
    left = left + right
}

public func * (left:CGPoint, right:CGFloat) -> CGPoint
{
    return CGPoint(x:left.x*right, y:left.y*right)
}
public func * (left:CGFloat, right:CGPoint) -> CGPoint
{
    return right*left
}
public func *= (left: inout CGPoint, right: CGFloat)
{
    left = left*right
}


public func * (left:CGSize, right:CGFloat) -> CGSize
{
    return CGSize(width:left.width*right, height:left.height*right)
}
public func * (left:CGFloat, right:CGSize) -> CGSize
{
    return right*left
}
public func *= (left: inout CGSize, right: CGFloat)
{
    left = left*right
}



/************ SPRITEKIT **************/
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
        
        return parent!.children.index(of: self)
    }
    
    func transferInPlace(_ new_parent:SKNode)
    {
        if(parent == nil)
        {
            print("[ERROR] -- can't convert coordinate spaces if I'm not in the display tree!")
        }
        
        position = new_parent.convert(position, from: parent!)
        removeFromParent()
        new_parent.addChild(self)
    }
    
    func moveToBack()
    {
        if let actual_parent = parent
        {
            removeFromParent()
            actual_parent.insertChild(self, at: 0)
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
            position = CGPoint(x: value, y: position.y)
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
            position = CGPoint(x:position.x, y: value)
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
            
            while(current_parent != nil)
            {
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
            anchorPoint = CGPoint(x:value, y:anchorPoint.y)
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
            anchorPoint = CGPoint(x:anchorPoint.x, y:value)
        }
    }
}
