//
//  DAMultilineLabelNode.swift
//
//  Created by Will Hankinson on 9/10/15.
//
//  Ported from https://github.com/downrightsimple/DSMultilineLabelNode
//  an Obj-C version of the same thing

import Foundation
import SpriteKit

class DAMultilineLabelNode : SKSpriteNode
{
    private var _text = ""
    private var _fontColor = SKColor.whiteColor()
    private var _fontName = "Helvetica"
    private var _fontSize = CGFloat(32)
    private var _horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
    private var _verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
    
    private var _paragraphWidth = CGFloat(0)
    
    init()
    {
        super.init(texture: nil, color: UIColor.greenColor(), size: CGSize(width: 0, height: 0))
        
        retexture()
    }
    
    convenience init(fontName:String)
    {
        self.init()
        
        self.fontName = fontName
    }
    
    static func labelNodeWithFontNamed(fontName:String) -> DAMultilineLabelNode
    {
        return DAMultilineLabelNode(fontName: fontName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func retexture()
    {
        if let new_text_image = imageFromText(_text)
        {
            var new_texture = SKTexture(image: new_text_image)
            
            texture = new_texture
            anchorPoint = CGPointMake(0.5, 0.5)
        }
    }
    
    func imageFromText(text:String) -> UIImage?
    {
        var paragraph_style = NSMutableParagraphStyle()
        paragraph_style.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph_style.alignment = horizontalNSTextAlignment
        paragraph_style.lineSpacing = 1
        
        var font = UIFont(name: _fontName, size: _fontSize)
        if (font == nil)
        {
            font = UIFont(name: "Helvetica", size: _fontSize)
            println("The font you specified was unavailable. Defaulted to Helvetica.");
        }
        
        var text_attributes = NSMutableDictionary()
        text_attributes.setObject(font!, forKey: NSFontAttributeName)
        text_attributes.setObject(paragraph_style, forKey: NSParagraphStyleAttributeName)
        text_attributes.setObject(_fontColor, forKey: NSForegroundColorAttributeName)
        
        if(scene == nil)
        {
            return nil
        }
        
        if(_paragraphWidth == 0)
        {
            _paragraphWidth = scene!.size.width
        }
        
        let texture_size = CGSize(width: _paragraphWidth, height: 2048)//scene!.size.height)
        var texture_rect = (text as NSString).boundingRectWithSize(texture_size,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: text_attributes as [NSObject:AnyObject],
            context: nil
        )
        
        //iOS7 uses fractional size values.  So we needed to ceil it to make sure we have enough room for display.
        texture_rect.size = CGSize(width: ceil(texture_rect.size.width), height: ceil(texture_rect.size.height))
        
        if(texture_rect.size.width == 0 || texture_rect.size.height == 0)
        {
            return nil
        }
        
        size = texture_rect.size
        
        UIGraphicsBeginImageContextWithOptions(texture_rect.size, false, 0)
        (text as NSString).drawInRect(texture_rect, withAttributes: text_attributes as [NSObject : AnyObject])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private var horizontalNSTextAlignment:NSTextAlignment
    {
        switch(_horizontalAlignmentMode)
        {
            case .Center:
                return NSTextAlignment.Center
            case .Left:
                return NSTextAlignment.Left
            case .Right:
                return NSTextAlignment.Right
        }
    }
    
    var fontColor:SKColor
    {
        get
        {
            return _fontColor
        }
        set(value)
        {
            _fontColor = value
            retexture()
        }
    }
    
    var fontName:String
    {
        get
        {
            return _fontName
        }
        set(value)
        {
            _fontName = value
            retexture()
        }
    }
    
    var fontSize:CGFloat
    {
        get
        {
            return _fontSize
        }
        set(value)
        {
            _fontSize = value
            retexture()
        }
    }
    
    var paragraphWidth:CGFloat
    {
        get
        {
            return _paragraphWidth
        }
        set(value)
        {
            _paragraphWidth = value
            retexture()
        }
    }
    
    var horizontalAlignmentMode:SKLabelHorizontalAlignmentMode
    {
        get
        {
            return _horizontalAlignmentMode
        }
        set(value)
        {
            _horizontalAlignmentMode = value
            retexture()
        }
    }
    
    var verticalAlignmentMode:SKLabelVerticalAlignmentMode
    {
        get
        {
            return _verticalAlignmentMode
        }
        set(value)
        {
            _verticalAlignmentMode = value
            retexture()
        }
    }
    
    var text:String
    {
        get
        {
            return _text
        }
        set(value)
        {
            _text = value
            retexture()
        }
    }
    
    
    
}