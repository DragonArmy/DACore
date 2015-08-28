//
//  SkinnedCharacter.swift
//  testing
//
//  adapted from Obj-C AAPLSkinnedCharacter in Apple banana demo
//

import Foundation
import SceneKit

class SkinnedCharacter : SCNNode
{
    var mainSkeleton:SCNNode?
    
    var animationsDict = Dictionary<String,CAAnimation>()
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(name:String?, fromSceneNamed file_path:String)
    {
        super.init()
        
        let node = SkinnedCharacter.NodeWithName(name, fromSceneNamed:file_path, shouldPlay:false)!
        processRootNode(node)
    }
    
    class func NodeWithName(name:String?, fromSceneNamed file_path:String, shouldPlay and_play_anims:Bool) -> SCNNode?
    {
        var scene:SCNScene?
        
        if(and_play_anims)
        {
            scene = SCNScene(named: file_path)
        }else{
            scene = SCNScene(named:file_path, inDirectory:nil, options: [SCNSceneSourceAnimationImportPolicyKey:SCNSceneSourceAnimationImportPolicyDoNotPlay])
        }
        
//        if let
        if(scene != nil)
        {
            var node = scene!.rootNode
            
            if(name != nil)
            {
                node = node.childNodeWithName(name!, recursively: true)!
            }else{
                node = node.childNodes[0] as! SCNNode
            }
            
            return node
        }
        
        return nil
    }
    
    init(character_root_node:SCNNode)
    {
        super.init()
        
        processRootNode(character_root_node)
    }
    
    func processRootNode(character_root_node:SCNNode)
    {
        character_root_node.position = SCNVector3Make(0, 0, 0)
        
        addChildNode(character_root_node)
        
        enumerateChildNodesUsingBlock(
        { child,stop in
            println("SkinnedCharacter -- \(child.name) -- \(child.skinner) -- \(child)")
            if(child.skinner != nil)
            {
                println("FOUND A MAIN SKELETON")
                println("SKELETON: \(child.skinner!) -- \(child.skinner!.skeleton)")
                self.mainSkeleton = child.skinner!.skeleton
                stop.initialize(true)
            }
        })
        
        if(mainSkeleton == nil)
        {
            println("UNABLE TO FIND SKELETON")
        }
    }
    
    
    func findAndSetSkeleton()
    {
        enumerateChildNodesUsingBlock(
            { child,stop in
                if(child.skinner != nil)
                {
                    self.mainSkeleton = child.skinner!.skeleton
                    stop.initialize(true)
                }
        })
    }
    
    func cachedAnimationForKey(key:String) -> CAAnimation?
    {
        return animationsDict[key]
    }
    
    /********** LOAD ALL ANIMATIONS FROM A FILE AND CACHE IT AS A CAAnimationGroup **********************/
    func loadAndCacheAllAnimations(dae_file:String, forKey key:String) -> CAAnimation?
    {
        if let anim = SkinnedCharacter.loadAllAnimationFromScene(dae_file)
        {
            animationsDict[key] = anim
            anim.delegate = self
            
            return anim
        }
        
        return nil
    }
    
    
    class func loadAllAnimationFromScene(dae_file:String) -> CAAnimation?
    {
        if let url = NSBundle.mainBundle().URLForResource(dae_file, withExtension: "dae")
        {
            if let scene_source = SCNSceneSource(URL: url, options:nil)
            {
                if let identifiers = scene_source.identifiersOfEntriesWithClass(CAAnimation.self) as? [NSString]
                {
                    var anims = [CAAnimation]()
                    
                    var max_duration = CFTimeInterval(0)
                    var earliest_key = CFTimeInterval(999999.9)
                    
                    for id in identifiers
                    {
                        if let anim = scene_source.entryWithIdentifier(id as! String, withClass: CAAnimation.self) as? CAAnimation
                        {
                            if let bottom = extractAnimation(anim)
                            {
                                max_duration = max(max_duration, bottom.duration)
                                anims.append(bottom)
                                
                                if let keyframe = bottom as? CAKeyframeAnimation
                                {
                                    if let earliest = keyframe.keyTimes.first! as? CFTimeInterval
                                    {
                                        earliest_key = min(earliest_key, earliest)
                                    }
                                }
                            }
                        }
                    }
                    

                    println("RETURNING A GROUP OF \(anims.count) ANIMATIONS   w/EARLIEST KEYFRAME = \(earliest_key)")
                    let delta = earliest_key - CFTimeInterval(1.0/30.0)
                    if(abs(earliest_key - 33333333) > 0.1)
                    {
                        for anim in anims
                        {
                            if let keyframe = anim as? CAKeyframeAnimation
                            {
                                keyframe.duration -= delta
                                keyframe.keyTimes = keyframe.keyTimes.map({ key_time in (key_time as! CFTimeInterval - delta) })
                            }
                        }
                    }

                    
                    let ret_animations = CAAnimationGroup()
                    
                    ret_animations.animations = anims
                    ret_animations.duration = max_duration - delta
                    ret_animations.fadeInDuration = 0.0
                    ret_animations.fadeOutDuration = 0.0
                    ret_animations.delegate = self
                    
                    return ret_animations
                }
            }
        }
        
        return nil
    }
    
    //the animations in the Maya Collada files folow the path of group -> group -> SCN_CAKeyframeAnimation
    //this code assumes a singular animation lies at the bottom of the chain! (b/c that's how FBX->Collada rolls
    class func extractAnimation(anim:CAAnimation) -> CAAnimation?
    {
        if let anim_group = anim as? CAAnimationGroup
        {
            var hold:CAAnimation?
            
            for sub_anim in anim_group.animations
            {
                if(hold == nil)
                {
                    hold = sub_anim as? CAAnimation
                }else{
                    println("[WARNING] SkinnedCharacter.extractAnimation assumes one keyframe animation per group!")
                }
            }
            
            return extractAnimation(hold!)
            
        }else{
            return anim
        }
    }
    
    
    /********** LOAD AND CACHE ANIMATION ASSUMING SINGLE ANIMATIONS... MAYA DOESNT PLAY NICE ***********/
    func loadAndCacheAnimation(dae_file:String, withName animation_name:String, forKey key:String) -> CAAnimation?
    {
        if let anim = SkinnedCharacter.loadAnimationNamed(animation_name, fromSceneNamed: dae_file)
        {
            animationsDict[key] = anim
            anim.delegate = self
            
            return anim
        }
        
        return nil
    }
    
    func loadAndCacheAnimation(dae_file:String, forKey key:String) -> CAAnimation?
    {
        return loadAndCacheAnimation(dae_file, withName: key, forKey: key)
    }
    
    class func loadAnimationNamed(animation_name:String, fromSceneNamed scene_name:String) -> CAAnimation?
    {
        if let url = NSBundle.mainBundle().URLForResource(scene_name, withExtension: "dae")
        {
            if let scene_source = SCNSceneSource(URL: url, options:nil)
            {
                let animation = scene_source.entryWithIdentifier(animation_name, withClass: CAAnimation.self) as! CAAnimation
                
                animation.fadeInDuration = 0.0
                animation.fadeOutDuration = 0.0
                
                return animation
            }
        }
        
        return nil
    }
    
    func chainAnimation(first_key:String, toAnimation second_key:String)
    {
        chainAnimation(first_key, toAnimation: second_key, fadeTime: 0.85)
    }
    
    func chainAnimation(first_key:String, toAnimation second_key:String, fadeTime fade_time:CGFloat)
    {
        if let first_anim = cachedAnimationForKey(first_key)
        {
            if let second_anim = cachedAnimationForKey(second_key)
            {
                let chain_event_block:SCNAnimationEventBlock = {anim, obj, backward in
                    self.mainSkeleton!.addAnimation(second_anim, forKey: second_key)
                }
                
                if(first_anim.animationEvents == nil || first_anim.animationEvents.count == 0)
                {
                    first_anim.animationEvents = [SCNAnimationEvent(keyTime: fade_time, block: chain_event_block)]
                }else{
                    var past_events = Array(first_anim.animationEvents)
                    past_events.append(SCNAnimationEvent(keyTime: fade_time, block: chain_event_block))
                    first_anim.animationEvents = past_events
                }
                
            }
        }
    }
    
    func update(delta_time:NSTimeInterval)
    {
        //TODO: SUBCLASS AND IMPLEMENT ME
    }
}