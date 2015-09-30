//
//  FlumpNode.swift
//  trace
//
//  Created by Will Hankinson on 4/14/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
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
    
    init?(file_root:String, fromContainer container_name:String?, restPose rest_pose:String?, resolutionIndependent omit_device_tag:Bool)
    {
        super.init(file_root:file_root, fromContainer:container_name, resolutionIndependent:omit_device_tag, asynchSprites:true)
        
        if(rest_pose != nil)
        {
            restPose = Flump.LoadedMovies[rest_pose!]
        }
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    func goto(movie_name:String) -> FlumpNode
    {
        print("GOTO \(movie_name)")
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
                    if let rest_layer = restPose!.layerWithName(layer.name)
                    {
                        child.runAction(layer.getGoto(rest_layer))
                    }else{
                        print("[ERROR] CANNOT FIND LAYER \(layer.name) IN REST POSE \(restPose!.name)")
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
        isLooping = false
        playOnceCallback = callback
        doPlay(movie_name)
        
        return self
    }
    
    func play(movie_name:String) -> FlumpNode
    {
        isLooping = true
        doPlay(movie_name)
        
        return self
    }
    
    private func doPlay(movie_name:String)
    {
        stop()
        
        isPlaying = true
        
        reset()
        
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
                    
                    var animation:SKAction
                    var loop:SKAction
                    if(restPose == nil)
                    {
                        animation = layer.getAction()
                        loop = animation
                    }else{
                        if let rest_layer = restPose!.layerWithName(layer.name)
                        {
                            animation = layer.getAction(rest_layer)

                            let reset = layer.getReset(rest_layer)
                            loop = SKAction.sequence([animation, reset])
                        }else{
                            print("[ERROR] CANNOT FIND LAYER \(layer.name) IN REST POSE \(restPose!.name)")
                            animation = SKAction()
                            loop = SKAction()
                        }
                    }
                    
                    
                    if(isLooping)
                    {
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