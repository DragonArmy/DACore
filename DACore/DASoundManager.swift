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
            print("[ERROR] No file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: url!)
        } catch let error1 as NSError {
            error = error1
            musicPlayer = nil
        }
        
        if let player = musicPlayer
        {
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create music player: \(error!)")
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
        
        print("PLAY SOUND \(filename)");
        
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil)
        {
            print("NO SFX FOUND: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundPlayers[filename] = try AVAudioPlayer(contentsOfURL: url!)
        } catch let error1 as NSError {
            error = error1
            soundPlayers[filename] = nil
        }
        if let player = soundPlayers[filename]
        {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create sfx player: \(error!)")
        }
    }
}

