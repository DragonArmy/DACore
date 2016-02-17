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
            label.font = font
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
    
    
    
    
}
