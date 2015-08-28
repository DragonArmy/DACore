//
//  DAContainer.swift
//  testing
//
//  Created by Will Hankinson on 3/18/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

/* this started as just an alias so I could disambiguate between between something I was explicitly using as
 * a container (SKNode) vs things I explicitly add to containers but inherit from SKNode like images/labels/etc
 * 
 * BUT! After realizing SKNodes don't support anchors it's actually a bonus to have our own container class
 * where we can implement cool anchor stuff. We do this by being a double-container. Outer container gets
 * to own our position/rotation/scale. Inner container owns all the children and can only be translated by 
 * changing the anchor value.
 *
 * Since I also want this cool pivot behavior for container-based classes, we come full circle and make an
 * empty subclass to be our actual "just a container"
 *
 */

class DAContainer : DAContainerBase
{
    override init()
    {
        super.init();
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}

class DAContainerBase : DAResetNode
{
    //not strictly an anchor value but a fixed offset for all the contents
    var pivotX:CGFloat
    {
        get
        {
            return innerContainer.x;
        }
        set(value)
        {
            innerContainer.x = value;
        }
    }
    
    var pivotY:CGFloat
    {
        get
        {
            return innerContainer.y;
        }
        set(value)
        {
            innerContainer.y = value;
        }
    }
    
    var innerContainer = SKNode()
    var pivotDisplay = SKShapeNode(circleOfRadius:4)
    
    override init()
    {
        super.init();
        super.addChild(innerContainer)
        pivotDisplay.fillColor = SKColor.redColor()
        pivotDisplay.hidden = true
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func showPivots()
    {
        addChild(pivotDisplay)
        pivotDisplay.hidden = false
        for child in children
        {
            if let da_container = child as? DAContainerBase
            {
                da_container.showPivots()
            }
        }
    }
    
    override func addChild(node:SKNode)
    {
        innerContainer.addChild(node)
    }
    
    override func insertChild(node: SKNode!, atIndex index: Int)
    {
        innerContainer.insertChild(node, atIndex: index)
    }
    
    //removeFromParent works the same!
    
    override func removeAllChildren()
    {
        innerContainer.removeAllChildren()
    }
    
    override func removeChildrenInArray(nodes: [AnyObject]!) {
        innerContainer.removeChildrenInArray(nodes)
    }
    
    override var children : [AnyObject]
    {
        get
        {
            return innerContainer.children
        }
    }
    
    override func childNodeWithName(name: String) -> SKNode?
    {
        return innerContainer.childNodeWithName(name)
    }
    
    override func enumerateChildNodesWithName(name: String, usingBlock block: ((SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void)!)
    {
        innerContainer.enumerateChildNodesWithName(name, usingBlock: block)
    }
}