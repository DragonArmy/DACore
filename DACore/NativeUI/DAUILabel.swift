//
//  DAUILabel.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DAUILabel : DAUIView
{
    var label = UILabel()
    
    
    override init()
    {
        super.init()
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var font:UIFont
    {
        get
        {
            return label.font
        }
        set(value)
        {
            label.font = value
        }
    }
    
    var textColor:UIColor
    {
        get
        {
            return label.textColor
        }
        set(value)
        {
            label.textColor = value
        }
    }
    
    var text:String?
    {
        get
        {
            return label.text
        }
        set(value)
        {
            label.text = value
            sizeToFit()
        }
    }
    
    var textAlignment:NSTextAlignment
    {
        get
        {
            return label.textAlignment
        }
        set(value)
        {
            label.textAlignment = value
        }
    }
    
    
    override func reset(recursive:Bool=true)
    {
        super.reset(recursive)
        sizeToFit()
    }
    
    
    override func sizeToFit()
    {
        super.sizeToFit()
        
        let nstext = label.text! as NSString
        let size = nstext.sizeWithAttributes([NSFontAttributeName:label.font])
        let expansion = size.width - resetSize.width
        
        if(expansion > 0)
        {
            switch(textAlignment)
            {
                case .Left:
                    frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width + expansion, height: frame.size.height)
                case .Right:
                    frame = CGRect(x: frame.origin.x - expansion, y: frame.origin.y, width: frame.size.width + expansion, height: frame.size.height)
                case .Center:
                    frame = CGRect(x: frame.origin.x - expansion/2, y: frame.origin.y, width: frame.size.width + expansion, height: frame.size.height)
                default:
                    print("OOPS WE DONT SUPPORT \(textAlignment)")
            }
        }
        
    }
    
}
