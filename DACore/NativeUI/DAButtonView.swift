//
//  DAButtonView.swift
//  catchsports
//
//  Created by Will Hankinson on 2/22/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DAButtonView : DAButtonViewBase
{
    
    override init()
    {
        super.init()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateDisplay()
    {
        for child:AnyObject in subviews
        {
            if let node_child = child as? DAView
            {
                if let node_name = node_child.name
                {
                    let tag = node_name.split("_").last!
                    
                    if(tag == "down")
                    {
                        node_child.hidden = !_isButtonDown
                    }else if(tag == "up"){
                        node_child.hidden = _isButtonDown
                    }else{
                        //do nothing! keep your state
                    }
                }
            }
        }
    }
    
}

