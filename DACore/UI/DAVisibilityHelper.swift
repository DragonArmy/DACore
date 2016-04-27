//
//  DAVisibilityHelper.swift
//  tracecrossy
//
//  Created by Will Hankinson on 4/27/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import SpriteKit


//sooooo in iOS 8 a hidden button/container still receives touch events!
//which means invisibe buttons can still block touches on things below
//this is FIXED in iOS9 but we may need support for iOS8... so handy helper/wrapper!

//without this helper, you'd have to maintain a reference to the original parent
//this solution won't fix all problems -- if a button needs to be not at the top of the
//display tree you may need to do more rigorous accounting

class DAVisibilityHelper
{
    var parent:SKNode
    var child:SKNode
    
    init(nodeWithParent:SKNode)
    {
        self.child = nodeWithParent
        self.parent = nodeWithParent.parent!
    }
    
    func show()
    {
        if(child.parent != nil)
        {
            child.removeFromParent()
        }
        parent.addChild(child)
    }
    
    func hide()
    {
        if(child.parent != nil)
        {
            child.removeFromParent()
        }
    }
}
