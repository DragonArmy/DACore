//
//  GameScene.swift
//  testing
//
//  Created by Will Hankinson on 1/27/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit
import SceneKit
import GLKit

class GameScene: SKScene
{
    var spriteKitRoot = SKNode()
    var metaNode = DAMetaNode(file_root: "")!
    
    private var _metaNodeFileRoot:String = ""
    private var _metaNodeContainerRoot:String? = nil
    
    init(size:CGSize, fromFile file_root:String, fromContainer container_root:String?)
    {
        super.init(size:size)
        
        addChild(spriteKitRoot)
        spriteKitRoot.name = "spriteKitRoot"
        
        _metaNodeFileRoot = file_root
        _metaNodeContainerRoot = container_root
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = SKSceneScaleMode.AspectFit
        
        loadMetadata()
    }
    
    convenience init(size:CGSize, fromFile file_root:String)
    {
        self.init(size:size, fromFile:file_root, fromContainer:nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(size:CGSize) {
        super.init(size:size)
        
        addChild(spriteKitRoot)
        spriteKitRoot.name = "spriteKitRoot"
        
        _metaNodeFileRoot = ""
        _metaNodeContainerRoot = ""
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = SKSceneScaleMode.AspectFit
        
    }
    
    func printAnimationGroup(group:CAAnimationGroup, withDepth depth:Int)
    {
        for sub_anim in group.animations!
        {
            if let sub_group = sub_anim as? CAAnimationGroup
            {
                printAnimationGroup(sub_group, withDepth: (depth+1))
            }else{
                if let keyframe = sub_anim as? CAKeyframeAnimation
                {
                    //print("DEPTH \(depth): \(keyframe)      \(keyframe.keyPath)")
                    print("          keyTimes:\(keyframe.keyTimes)    (\(keyframe.keyTimes!.count))")
                }else{
                    //print("DEPTH \(depth): \(sub_anim)")
                }
            }
            
        }
    }
    
    func loadMetadata()
    {
        metaNode = DAMetaNode(file_root: _metaNodeFileRoot, fromContainer: _metaNodeContainerRoot)!
        spriteKitRoot.addChild(metaNode);
    }
    
    //helpers that just forward on to metaNode to make Controller logic cleaner
    func containerWithName(container_name:String) -> DAContainer?
    {
        return metaNode.containerWithName(container_name)
    }
    
    func progressWithName(progress_name:String) -> DAProgressBar?
    {
        return metaNode.progressWithName(progress_name)
    }
    
    func tabWithName(tab_name:String) -> DATabButton?
    {
        return metaNode.tabWithName(tab_name)
    }
    
    //simplest of the getters, doesn't prefix anything
    func imageWithName(image_name:String) -> SKSpriteNode?
    {
        return metaNode.imageWithName(image_name)
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func buttonWithName(button_name:String) -> DAButtonBase?
    {
        return metaNode.buttonWithName(button_name)
    }
    
    func placeholderWithName(placeholder_name:String) -> CGRect?
    {
        return metaNode.placeholderWithName(placeholder_name)
    }
    
    func labelWithName(label_name:String) -> SKLabelNode?
    {
        return metaNode.labelWithName(label_name)
    }
    
}
