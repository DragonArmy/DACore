//
//  FlumpNode.swift
//  trace
//
//  Created by Will Hankinson on 4/14/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit

class FlumpNode : DAMetaNode
{
    let onTouchesBegan = Signal<UITouch>()
    let onTouchesEnded = Signal<UITouch>()
    
    let onLoop = Signal<String>()
    
    var currentMovie = "NONE"
    var restPose:FlumpMovie? = nil
    var isLooping = true
    var isPlaying = false
    
    var playOnceCallback:()->() = {}
    
    override init()
    {
        super.init()
    }
    
    convenience init?(fileRoot file_root:String, fromContainer container_name:String?, restPose rest_pose:String?, resolutionIndependent omit_device_tag:Bool)
    {
        //default asynch
        self.init(fileRoot:file_root, fromContainer:container_name, restPose:rest_pose, resolutionIndependent:omit_device_tag, asynchSprites:true)
    }
    
    init?(fileRoot file_root:String, fromContainer container_name:String?, restPose rest_pose:String?, resolutionIndependent omit_device_tag:Bool, asynchSprites with_asynch:Bool, useTextureCache use_texture_cache:Bool=false)
    {
        super.init(file_root:file_root, fromContainer:container_name, resolutionIndependent:omit_device_tag, asynchSprites:with_asynch, useTextureCache:use_texture_cache)
        
        
        if let rest = rest_pose
        {
            if(Flump.LoadedMovies.keys.contains(rest))
            {
                restPose = Flump.LoadedMovies[rest]
            }else{
                print("UNABLE TO FIND REST POSE \(rest)")
                for key in Flump.LoadedMovies.keys
                {
                    print("         -> \(key)")
                }
            }
        }
        
        //isUserInteractionEnabled = true
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        
        if let touch:UITouch = touches.anyItem()
        {
            onTouchesBegan.fire(touch)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        
        if let touch:UITouch = touches.anyItem()
        {
            onTouchesEnded.fire(touch)
        }
    }
    
    @discardableResult func goto(_ movie_name:String) -> FlumpNode
    {
        isLooping = false
        stop()
        
        resetChildren(recursive: false)
        
        //if we don't have a restPose, our "reset()" state is our rest pose
        if(restPose == nil)
        {
            print("NO REST POSE, BAIL OUT")
            return self
        }
        
        if let movie = Flump.LoadedMovies[movie_name]
        {
            currentMovie = movie_name
            
            for layer in movie.layers
            {
                if let child = container(withName:layer.name)
                {
                    if child.isHidden
                    {
                        print("\(layer.name) is hidden, we're not going to muck with it")
                        continue
                    }
                    
                    //in the event that our rest pose is NOT our first frame of animation, we need to "get into position"
                    //if we don't have a rest pose, our frame 0 is our rest pose anyway
                    if(restPose != nil)
                    {
                        if let rest_layer = restPose!.layerWithName(layer.name)
                        {
                            let frame1 = rest_layer.frames[0]
                            let frame2 = layer.frames[0]
                            
                            child.x += frame2.position.x - frame1.position.x
                            child.y += frame2.position.y - frame1.position.y
                            
                            child.zRotation += frame2.rotation - frame1.rotation
                            
                            child.xScale = frame2.xScale
                            child.yScale = frame2.yScale
                            
                            child.alpha = frame2.alpha
                        }else{
                            print("[ERROR] CANNOT FIND LAYER \(layer.name) IN REST POSE \(restPose!.name)")
                        }
                    }
                }else{
                    print("LAYER NAMED \(layer.name) NOT FOUND!")
                }
            }
            
        }else{
            print("[ERROR] CANNOT FIND MOVIE " + movie_name)
        }
        
        return self
    }
    
    @discardableResult func playOnce(_ movie_name:String, withCallback callback: @escaping ()->() = {}) -> FlumpNode
    {
        playOnceCallback = callback
        doPlay(movie_name, withLoop:false)
        
        return self
    }
    
    @discardableResult func play(_ movie_name:String) -> FlumpNode
    {
        doPlay(movie_name, withLoop:true)
        
        return self
    }
    
    private static var animationCache = [String:SKAction]()
    private func doPlay(_ movie_name:String, withLoop is_looping:Bool)
    {
        //will stop & reset & go to first frame
        goto(movie_name)
        
        isPlaying = true
        isLooping = is_looping
        
        //only set a callback on the first layer
        var first = true
        
        if let movie = Flump.LoadedMovies[movie_name]
        {
            currentMovie = movie_name
            
            for layer in movie.layers
            {
                if let child = container(withName:layer.name)
                {
                    if child.isHidden
                    {
                        print("\(layer.name) is hidden, we're not going to animate it")
                        continue
                    }
                    
//                    let key = "\(movie.name)::\(layer.name)"
//                    if(!FlumpNode.animationCache.keys.contains(key))
//                    {
//                        FlumpNode.animationCache[key] = layer.getAction()
//                    }
//                    let animation = FlumpNode.animationCache[key]!
                    
                    let animation = layer.getAction()
                    
                    if(isLooping)
                    {
                        let reset = layer.getReset(restLayer: layer)
                        let loop = SKAction.sequence([animation,reset])
                        
                        child.run(loop, completion: {
                            self.onLoop.fire(movie_name)
                            self.doPlay(movie_name, withLoop:true)
                        })
                        
                        //not sure why, but using repeatAcitonForever creates a hitch in the animation
//                        child.run(SKAction.repeatActionForever(loop), withKey:"robot")
                    }else{
                        if(first)
                        {
                            child.run(animation, completion: onSinglePlayComplete)
                            first = false
                        }else{
                            child.run(animation)
                        }
                        
                    }

                }
            }
        }else{
            print("UNABLE TO PLAY MOVIE \(movie_name) -- MAYBE YOU FORGOT TO LOAD IT?")
        }
    }
    
    func onSinglePlayComplete()
    {
        isPlaying = false
        
        //clear our handler before calling it in case the callback starts a new animation
        let cached_callback = playOnceCallback
        playOnceCallback = {}
        cached_callback()
    }
    
    @discardableResult func stop() -> FlumpNode
    {
        isPlaying = false
        if let movie = Flump.LoadedMovies[currentMovie]
        {
            for layer in movie.layers
            {
                if let child = container(withName:layer.name)
                {
                    child.removeAllActions()
                }
            }
        }
        
        return self
    }
}
