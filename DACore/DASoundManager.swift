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
    
    static var MUSIC_VOLUME:Float = 1.0
    
    
    public static var musicPlayer:AVAudioPlayer?
    public static var crossfadePlayer:AVAudioPlayer?
    
    public static var soundPlayers = [String:AVAudioPlayer]()
    
    public static func playMusic(filename: String)
    {
        musicPlayer = createMusicPlayer(filename)
    }
    
    public static func crossFadeToMusic(filename:String)
    {
        if(!MUSIC_ENABLED)
        {
            return
        }
    
        if(musicPlayer == nil)
        {
            playMusic(filename)
            return
        }
        
        if(!musicPlayer!.playing)
        {
            playMusic(filename)
            return
        }
        
        //if we didn't bail out for playMusic, start the crossfade
        //we actually set the NEW track as our main track so that if we pause/stop that one gets resumed

        crossfadePlayer = musicPlayer
        musicPlayer = createMusicPlayer(filename)
        
        musicPlayer!.volume = 0.025
        crossfadePlayer!.volume = 0.975
        dispatch_after_delay(0.02, block: justKeepFading)
    }
    
    private static func justKeepFading()
    {
        if(crossfadePlayer == nil)
        {
            musicPlayer!.volume = 1
            return
        }
        
        musicPlayer!.volume += 0.025
        crossfadePlayer!.volume -= 0.025
    
        if(musicPlayer!.volume < 1.0)
        {
            print("CROSSFADE AT \(musicPlayer!.volume)")
            dispatch_after_delay(0.02, block: justKeepFading)
        }else{
            crossfadePlayer = nil
        }
    }
    
    private static func createMusicPlayer(filename:String) -> AVAudioPlayer?
    {
        var music_player:AVAudioPlayer?
        
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil)
        {
            print("[ERROR] No file: \(filename)")
            return nil
        }
        
        var error: NSError? = nil
        do {
            music_player = try AVAudioPlayer(contentsOfURL: url!)
        } catch let error1 as NSError {
            error = error1
            music_player = nil
        }
        
        if let player = music_player
        {
            player.volume = DASoundManager.MUSIC_VOLUME
            player.numberOfLoops = -1
            player.prepareToPlay()
            
            if(MUSIC_ENABLED)
            {
//                print("MUSIC ENABLED -- PLAY")
                player.play()
            }
            
        } else {
            print("Could not create music player: \(error!)")
        }
        
        return music_player
    }
    
    public static func stopMusic()
    {
        if let player = musicPlayer
        {
            if player.playing
            {
                player.pause()
                player.currentTime = 0
            }
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
    
    public static func playSound(filename:String, withDelay delay:Double)
    {
        dispatch_after_delay(delay, block: {
            playSound(filename)
        })
    }
    
    public static func playSound(filename: String)
    {
        if(!SFX_ENABLED)
        {
            return
        }
        
//        print("PLAY SOUND \(filename)");
        
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

