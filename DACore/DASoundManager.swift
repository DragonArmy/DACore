//
//  DASoundManager.swift
//  ihg
//
//  Created by Will Hankinson on 9/28/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import AVFoundation


public class DASoundManager
{
    static var MUSIC_ENABLED = true
    static var SFX_ENABLED = true
    
    
    public static var musicPlayer:AVAudioPlayer?
    public static var soundPlayers = [String:AVAudioPlayer]()
    
    public static func playMusic(filename: String)
    {
        if(!MUSIC_ENABLED)
        {
            return
        }
        
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil)
        {
            println("[ERROR] No file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        musicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        if let player = musicPlayer
        {
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } else {
            println("Could not create music player: \(error!)")
        }
    }
    
    public static func pauseMusic()
    {
        if let player = musicPlayer
        {
            if player.playing
            {
                player.pause()
            }
        }
    }
    
    public static func resumeMusic()
    {
        if(!MUSIC_ENABLED)
        {
            return
        }
        
        if let player = musicPlayer
        {
            if !player.playing
            {
                player.play()
            }
        }
    }
    
    public static func playSound(filename: String)
    {
        if(!SFX_ENABLED)
        {
            return
        }
        
        println("PLAY SOUND \(filename)");
        
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil)
        {
            println("NO SFX FOUND: \(filename)")
            return
        }
        
        var error: NSError? = nil
        soundPlayers[filename] = AVAudioPlayer(contentsOfURL: url, error: &error)
        if let player = soundPlayers[filename]
        {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
        } else {
            println("Could not create sfx player: \(error!)")
        }
    }
}

