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
    
    override var name:String?
    {
        get
        {
            return super.name
        }
        set(value)
        {
            super.name = value
            innerContainer.name = "inner_\(name!)"
        }
        
    }
    
    var innerContainer = SKNode()
    
    override init()
    {
        super.init();
        
        super.addChild(innerContainer)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func addChild(_ node:SKNode)
    {
        if(node == innerContainer)
        {
            super.addChild(node)
        }else{
            innerContainer.addChild(node)
        }
    }
    
    override func insertChild(_ node: SKNode, at index: Int)
    {
        if(node == innerContainer)
        {
            super.insertChild(node, at: index)
        }else{
            innerContainer.insertChild(node, at: index)
        }
    }
    
    //removeFromParent works the same!
    
    override func removeAllChildren()
    {
        innerContainer.removeAllChildren()
    }
    
    override func removeChildren(in nodes: [SKNode]) {
        innerContainer.removeChildren(in:nodes)
    }
    
    override var children : [SKNode]
    {
        get
        {
            return innerContainer.children
        }
    }
    
    override func childNode(withName name: String) -> SKNode?
    {
        return innerContainer.childNode(withName:name)
    }
    
    override func enumerateChildNodes(withName name: String, using block: @escaping (SKNode, UnsafeMutablePointer<ObjCBool>) -> Void)
    {
        innerContainer.enumerateChildNodes(withName:name, using: block)
    }
    
    func judder(amount:CGFloat)
    {
        reset()
        for child in children
        {
            if let rnode = child as? DAResetNode
            {
                rnode.position = CGPoint(x: rnode.position.x + CGFloat.random(lower: -amount, upper:amount), y: rnode.position.y + CGFloat.random(lower: -amount, upper:amount))
                rnode.resetPosition = rnode.position
            }
            
        }
        
        self.position = CGPoint(x: self.position.x + CGFloat.random(lower: -amount, upper: amount), y: self.position.y + CGFloat.random(lower:amount, upper:amount))
        self.resetPosition = self.position
    }
    
    func convertToMask(_ mask:SKNode)
    {
        let old_inner = innerContainer
        
        let crop = SKCropNode()
        
        innerContainer = crop
        innerContainer.position = old_inner.position
        addChild(innerContainer)
        
        for child in old_inner.children
        {
            child.transferInPlace(innerContainer)
        }

        crop.maskNode = mask
        mask.removeFromParent()
        old_inner.removeFromParent()
    }    

}
