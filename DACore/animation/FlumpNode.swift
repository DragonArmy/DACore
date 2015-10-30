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
    
    init?(fileRoot file_root:String, fromContainer container_name:String?, restPose rest_pose:String?, resolutionIndependent omit_device_tag:Bool, asynchSprites with_asynch:Bool)
    {
        super.init(file_root:file_root, fromContainer:container_name, resolutionIndependent:omit_device_tag, asynchSprites:with_asynch)
        
        if(rest_pose != nil)
        {
            if(Flump.LoadedMovies.keys.contains(rest_pose!))
            {
                restPose = Flump.LoadedMovies[rest_pose!]
            }else{
                print("UNABLE TO FIND REST POSE \(rest_pose!)")
                for key in Flump.LoadedMovies.keys
                {
                    print("         -> \(key)")
                }
            }
        }
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    func goto(movie_name:String) -> FlumpNode
    {
        isLooping = false
        stop()
        
        reset()
        
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
                if let child = containerWithName(layer.name)
                {
                    if child.hidden
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
    
    func playOnce(movie_name:String, withCallback callback: ()->() = {}) -> FlumpNode
    {
        playOnceCallback = callback
        doPlay(movie_name, withLoop:false)
        
        return self
    }
    
    func play(movie_name:String) -> FlumpNode
    {
        doPlay(movie_name, withLoop:true)
        
        return self
    }
    
    private func doPlay(movie_name:String, withLoop is_looping:Bool)
    {
        //will stop & reset & go to first frame
        goto(movie_name)
        
        isPlaying = true
        isLooping = is_looping
        
        if let movie = Flump.LoadedMovies[movie_name]
        {
            currentMovie = movie_name
            
            for layer in movie.layers
            {
                if let child = containerWithName(layer.name)
                {
                    if child.hidden
                    {
                        print("\(layer.name) is hidden, we're not going to animate it")
                        continue
                    }
                    
                    let animation = layer.getAction()
                    
                    if(isLooping)
                    {
                        let reset = layer.getReset(layer)
                        let loop = SKAction.sequence([animation,reset])
                        
                        child.runAction(SKAction.repeatActionForever(loop), withKey:"robot")
                    }else{
                        child.runAction(animation, completion: onSinglePlayComplete)
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
        
        //clear the callback after the first one!
        //if a movie has 10 layers onSinglePlayComplete will fire 10 times
        playOnceCallback()
        playOnceCallback = {}
    }
    
    func stop() -> FlumpNode
    {
        isPlaying = false
        if let movie = Flump.LoadedMovies[currentMovie]
        {
            for layer in movie.layers
            {
                if let child = containerWithName(layer.name)
                {
                    child.removeAllActions()
                }
            }
        }
        
        return self
    }
}