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
    
    public static func playMusic(_ filename: String)
    {
        musicPlayer = createMusicPlayer(filename)
    }
    
    public static func crossFadeToMusic(_ filename:String)
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
        
        if(!musicPlayer!.isPlaying)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: justKeepFading)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: justKeepFading)
        }else{
            crossfadePlayer = nil
        }
    }
    
    public static func createMusicPlayer(_ filename:String) -> AVAudioPlayer?
    {
        var music_player:AVAudioPlayer?
        
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil)
        {
            print("[ERROR] No file: \(filename)")
            return nil
        }
        
        var error: NSError? = nil
        do {
            music_player = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            music_player = nil
        }
        
        if let player = music_player
        {
            player.volume = DASoundManager.MUSIC_VOLUME
            player.numberOfLoops = -1
            player.prepareToPlay()
            
            do
            {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            }catch{
                print("OOPS: AVAudioSession Hates You")
            }
            
            if(MUSIC_ENABLED)
            {
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
            if player.isPlaying
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
            if player.isPlaying
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
            do
            {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            }catch{
                print("OOPS: AVAudioSession Hates You")
            }
            
            
            if !player.isPlaying
            {
                player.play()
            }
        }
    }
    
    public static func playSound(_ filename:String, withDelay delay:Double)
    {
        if(delay > 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                playSound(filename)
            }
        }else{
            playSound(filename)
        }
    }
    
    public static func cacheSound(_ filename:String)
    {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil)
        {
            print("NO SFX FOUND: \(filename)")
            return
        }
        
        if(soundPlayers[filename] == nil)
        {
            var error: NSError? = nil
            do {
                soundPlayers[filename] = try AVAudioPlayer(contentsOf: url!)
            } catch let error1 as NSError {
                error = error1
                soundPlayers[filename] = nil
                print("Could not create sfx player: \(error!)")
            }
        }
    }
    
    public static func playSound(_ filename: String)
    {
        if(!SFX_ENABLED)
        {
            return
        }
        
//        print("PLAY SOUND \(filename)");
        
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil)
        {
            print("NO SFX FOUND: \(filename)")
            return
        }
        
        if(soundPlayers[filename] == nil)
        {
            var error: NSError? = nil
            do {
                soundPlayers[filename] = try AVAudioPlayer(contentsOf: url!)
            } catch let error1 as NSError {
                error = error1
                soundPlayers[filename] = nil
                print("Could not create sfx player: \(error!)")
            }
        }
        
        if let player = soundPlayers[filename]
        {
            if(player.isPlaying)
            {
                player.currentTime = 0
            }else{
                player.numberOfLoops = 0
                player.prepareToPlay()
                player.play()
            }
        } else {
            print("UNABLE TO PLAY SOUND \(filename)")
        }
    }
}

