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
        
        label.lineBreakMode = NSLineBreakMode.ByClipping
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
            reset()
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
        if(label.text == nil || label.text == "\"\"" || label.text!.isEmpty)
        {
            return
        }
        
        let nstext = label.text! as NSString
        let size = nstext.sizeWithAttributes([NSFontAttributeName:label.font])

        let horizontal = (size.width - frame.size.width)
        let vertical = size.height - frame.size.height
        
        var new_frame:CGRect = frame
        switch(textAlignment)
        {
            case .Left:
                new_frame = CGRect(x: frame.origin.x, y: frame.origin.y - vertical/2, width: frame.size.width + horizontal, height: frame.size.height+vertical)
            case .Right:
                new_frame = CGRect(x: frame.origin.x - horizontal, y: frame.origin.y - vertical/2, width: frame.size.width + horizontal, height: frame.size.height+vertical)
            case .Center:
                new_frame = CGRect(x: frame.origin.x - horizontal/2, y: frame.origin.y - vertical/2, width: frame.size.width + horizontal, height: frame.size.height+vertical)
            default:
                print("OOPS WE DONT SUPPORT \(textAlignment.rawValue)")
        }
        
        self.frame = new_frame
    }
    
}
