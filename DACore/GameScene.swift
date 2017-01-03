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
    let onFinishUpdate = Signal<Date>()
    
    
    var spriteKitRoot = SKNode()
    var metaNode:DAMetaNode
    
    private var _metaNodeFileRoot:String = ""
    private var _metaNodeContainerRoot:String? = nil
    
    init(size:CGSize, fromFile file_root:String, fromContainer container_root:String?)
    {
        _metaNodeFileRoot = file_root
        _metaNodeContainerRoot = container_root
        
        metaNode = DAMetaNode(file_root: _metaNodeFileRoot, fromContainer: _metaNodeContainerRoot)!
        
        super.init(size:size)
        
        addChild(spriteKitRoot)
        spriteKitRoot.name = "spriteKitRoot"
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = SKSceneScaleMode.aspectFit
        
        spriteKitRoot.addChild(metaNode);
    }
    
    convenience init(size:CGSize, fromFile file_root:String)
    {
        self.init(size:size, fromFile:file_root, fromContainer:nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(size:CGSize) {
        metaNode = DAMetaNode()
        
        super.init(size:size)
        
        addChild(spriteKitRoot)
        spriteKitRoot.name = "spriteKitRoot"
        
        _metaNodeFileRoot = ""
        _metaNodeContainerRoot = ""
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = SKSceneScaleMode.aspectFit
        
        
        onFinishUpdate.subscribe(on:self, callback:DAMetaNode.processAsynchImages)
    }
    
    override func willMove(from view: SKView)
    {
    }
    
    var gameSceneLastUpdate = Date()
    override func update(_ currentTime: TimeInterval)
    {
        gameSceneLastUpdate = Date()
        super.update(currentTime)
    }
    
    override func didFinishUpdate()
    {
        onFinishUpdate.fire(gameSceneLastUpdate as Date)
    }
    
    func printAnimationGroup(group:CAAnimationGroup, withDepth depth:Int)
    {
        for sub_anim in group.animations!
        {
            if let sub_group:CAAnimationGroup = sub_anim as? CAAnimationGroup
            {
                printAnimationGroup(group: sub_group, withDepth: (depth+1))
            }else{
                if let keyframe:CAKeyframeAnimation = sub_anim as? CAKeyframeAnimation
                {
                    //print("DEPTH \(depth): \(keyframe)      \(keyframe.keyPath)")
                    print("          keyTimes:\(keyframe.keyTimes)    (\(keyframe.keyTimes!.count))")
                }else{
                    //print("DEPTH \(depth): \(sub_anim)")
                }
            }
            
        }
    }
    
    //helpers that just forward on to metaNode to make Controller logic cleaner
    func container(withName container_name:String) -> DAContainer?
    {
        return metaNode.container(withName:container_name)
    }
    
    func progress(withName progress_name:String) -> DAProgressBar?
    {
        return metaNode.progress(withName:progress_name)
    }
    
    func tab(withName tab_name:String) -> DATabButton?
    {
        return metaNode.tab(withName:tab_name)
    }
    
    //simplest of the getters, doesn't prefix anything
    func image(withName image_name:String) -> SKSpriteNode?
    {
        return metaNode.image(withName:image_name)
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func button(withName button_name:String) -> DAButtonBase?
    {
        return metaNode.button(withName:button_name)
    }
    
    func placeholder(withName placeholder_name:String) -> CGRect?
    {
        return metaNode.placeholder(withName:placeholder_name)
    }
    
    func label(withName label_name:String) -> SKLabelNode?
    {
        return metaNode.label(withName:label_name)
    }
    
}
