//
//  DAUILabel.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DALabelView : DAView
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
            if(value.rawValue == 4)
            {
                label.textAlignment = NSTextAlignment.Left
            }else{
                label.textAlignment = value
            }
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
        
        if(label.text == nil || label.text == "\"\"" || label.text!.isEmpty)
        {
            return
        }
        
        let nstext = label.text! as NSString
        let size = nstext.sizeWithAttributes([NSFontAttributeName:label.font])

        let horizontal = size.width - resetSize.width
        let vertical = size.height - resetSize.height
        
        switch(textAlignment)
        {
            case .Left:
                frame = CGRect(x: frame.origin.x, y: frame.origin.y - vertical/2, width: frame.size.width + horizontal, height: frame.size.height+vertical)
            case .Right:
                frame = CGRect(x: frame.origin.x - horizontal, y: frame.origin.y - vertical/2, width: frame.size.width + horizontal, height: frame.size.height+vertical)
            case .Center:
                frame = CGRect(x: frame.origin.x - horizontal/2, y: frame.origin.y - vertical/2, width: frame.size.width + horizontal, height: frame.size.height+vertical)
            default:
                print("OOPS WE DONT SUPPORT \(textAlignment.rawValue)")
        }

        
    }
    
}
