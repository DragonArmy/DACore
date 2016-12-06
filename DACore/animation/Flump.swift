//
//  FumpParser.swift
//  trace
//
//  Created by Will Hankinson on 4/9/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit

struct FlumpMovie
{
    var name:String
    var frameRate:Float
    var layers:[FlumpLayer]
    
    var duration:TimeInterval
    {
        get
        {
            var max_frame:Float = 0
            for layer in layers
            {
                max_frame = max(max_frame, layer.maxFrame)
            }
            
            return TimeInterval(max_frame / frameRate)
        }
    }
    
    func layerWithName(_ search:String) -> FlumpLayer?
    {
        for layer in layers
        {
            if(layer.name == search)
            {
                return layer
            }
        }
        return nil
    }
}

struct FlumpLayer : Equatable
{
    var name:String
    var frames:[FlumpKeyframe]
    
    //TODO: this is currently hard-wired to just go to frame 0
    //at some point we'll probably want goto(FrameLabel) or goto(Int)
    //but that requires doing interpolation if it's an intermediary frame
    func getGoto() -> SKAction
    {
        return getGoto(restLayer:self)
    }
    
    func getGoto(restLayer rest_layer:FlumpLayer) -> SKAction
    {
        return FlumpLayer.constructGoToFrame(restFrame:rest_layer.frames[0], targetFrame:frames[0])
    }
    
    //flatten all the keyframes on this layer such that they can be applied to a layer
    func getAction() -> SKAction
    {
        return getAction(restLayer:self)
    }
    
    func getReset(restLayer rest_layer:FlumpLayer) -> SKAction
    {
        let reset_frame = rest_layer.frames[0]
        let last_frame  = frames.last!
        
        return FlumpLayer.constructGoToFrame(restFrame: last_frame, targetFrame: reset_frame)
    }
    
    func getAction(restLayer rest_layer:FlumpLayer) -> SKAction
    {
        var actions = [SKAction]()
        
        var lastFrame:FlumpKeyframe = rest_layer.frames[0]
        
        for i in 0..<frames.count
        {
            if(frames[i] != lastFrame)
            {
                actions.append(FlumpLayer.constructGoToFrame(restFrame:lastFrame, targetFrame: frames[i]))
            }
            
            if(i < frames.count-1 && frames[i].tweened)
            {
                actions.append(FlumpLayer.constructTween(frame1: frames[i], frame2: frames[i+1]))
                lastFrame = frames[i+1] //we'll already be at frame+1, don't jump
            }else{
                actions.append(SKAction.wait(forDuration: frames[i].duration))
                lastFrame = frames[i]
            }
        }
        
        return SKAction.sequence(actions)
    }
    
    private static func constructGoToFrame(restFrame frame1:FlumpKeyframe, targetFrame frame2:FlumpKeyframe) -> SKAction
    {
        var actions = [SKAction]()
        
        //this one assumes that we've reset the metacontainer to it's reset position before calling this!
        //we can't use moveTo because it'll move it absolutely
        let pos_delta = CGVector(dx: frame2.position.x - frame1.position.x, dy: frame2.position.y - frame1.position.y)
        actions.append(SKAction.move(by: pos_delta, duration: 0))
        
        let rot_delta = frame2.rotation - frame1.rotation
        actions.append(SKAction.rotate(toAngle: rot_delta, duration: 0))
        
        //CONVENTION -- Rest Pose most have all its pieces scaled to 1
        actions.append(SKAction.scaleX(to: frame2.xScale, duration: 0))
        actions.append(SKAction.scaleY(to: frame2.yScale, duration: 0))
        
        actions.append(SKAction.fadeAlpha(to: frame2.alpha, duration: 0))
        
        return SKAction.group(actions)
    }
    
    private static func constructTween(frame1:FlumpKeyframe, frame2:FlumpKeyframe) -> SKAction
    {
        var actions = [SKAction]()
        
        if(frame1.pivot != frame2.pivot)
        {
            print("[ERROR] WE DONT SUPPORT ANIMATING PIVOTS \(frame2.symbolName) FRAME \(frame2.startFrame)")
        }
        
        if(frame1.position != frame2.position)
        {
            let delta = CGVector(dx: frame2.position.x - frame1.position.x, dy: frame2.position.y - frame1.position.y)
            actions.append(SKAction.move(by: delta, duration: frame1.duration))
        }
        
        if(frame1.rotation != frame2.rotation)
        {
            let delta = frame2.rotation - frame1.rotation
            actions.append(SKAction.rotate(byAngle: delta, duration:frame1.duration))
        }
        
        if(frame1.xScale != frame2.xScale)
        {
            actions.append(SKAction.scaleX(to: frame2.xScale, duration:frame1.duration))
        }
        if(frame1.yScale != frame2.yScale)
        {
            actions.append(SKAction.scaleY(to: frame2.yScale, duration:frame1.duration))
        }
        
        if(frame1.alpha != frame2.alpha)
        {
            actions.append(SKAction.fadeAlpha(to: frame2.alpha, duration:frame1.duration))
        }
        
        if(actions.count == 0)
        {
            return SKAction.wait(forDuration: frame1.duration)
        }
        
        return SKAction.group(actions)
    }
    
    var maxFrame:Float
    {
        get
        {
            var max_frame:Float = 0
            for frame in frames
            {
                max_frame = max(max_frame, frame.endFrame)
            }
            
            return max_frame
        }
    }
}

struct FlumpKeyframe
{
    var symbolName:String?          //can be null if it's a frameLabel or empty frame
    var startFrame:Float            //keyframe
    var endFrame:Float
    var duration:TimeInterval     //in seconds
    var tweened:Bool
    var pivot:CGPoint
    var position:CGPoint
    var rotation:CGFloat
    var xScale:CGFloat
    var yScale:CGFloat
    var alpha:CGFloat
    var label:String? = nil
}

func ==(lhs:FlumpLayer, rhs:FlumpLayer) -> Bool
{
    if(lhs.name != rhs.name)
    {
        return false
    }
    
    if(lhs.frames.count != rhs.frames.count)
    {
        return false
    }
    
    for i in (0..<lhs.frames.count)
    {
        if(lhs.frames[i] != rhs.frames[i])
        {
            return false
        }
    }
    
    return true
}
func !=(lhs:FlumpLayer, rhs:FlumpLayer) -> Bool
{
    return !(lhs == rhs)
}

func ==(lhs:FlumpKeyframe, rhs:FlumpKeyframe) -> Bool
{
    if(lhs.symbolName == rhs.symbolName
        && lhs.startFrame == rhs.startFrame
        && lhs.duration == rhs.duration
        && lhs.tweened == rhs.tweened
        && lhs.pivot == rhs.pivot
        && lhs.position == rhs.position
        && lhs.rotation == rhs.rotation
        && lhs.xScale == rhs.xScale
        && lhs.yScale == rhs.yScale
        && lhs.alpha == rhs.alpha
        && lhs.label == rhs.label )
    {
        return true
    }
    
    return false
}
func !=(lhs:FlumpKeyframe, rhs:FlumpKeyframe) -> Bool
{
    return !(lhs == rhs)
}


class Flump
{
    static var LoadedAnimations = [String:String]()
    static var LoadedMovies = Dictionary<String, FlumpMovie>()
    
    static func loadAnimationsAsynch(fileRootList file_root_list:[String])
    {
        for file_root in file_root_list
        {
            //print("QUEUING ANIMATION: \(file_root)")
            let qos = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos:qos)
            
            let closure_file = file_root
            backgroundQueue.async {
                Flump.loadAnimation(closure_file)
                //print("FINISHED LOADING \(closure_file)")
            }

        }
    }
    
    static func isLoaded(_ file_root:String) -> Bool
    {
        if(LoadedAnimations[file_root] != nil)
        {
            return true
        }
        return false
    }
    
    static func loadAnimation(_ file_root:String)
    {
        let bundle = Bundle.main
        
        if(Flump.LoadedAnimations[file_root] != nil)
        {
            //print("ALREADY LOADED \(file_root) ANIMATIONS")
            return
        }
        
        let animation_url = bundle.url(forResource: "\(file_root)", withExtension: "json")
        
        // edie added this because I have no idea why this error is being thrown
        if(animation_url == nil)
        {
            print("ANIMATION URL IS NIL")
            //return
        }
        
        do
        {
            let data = try String(contentsOf: animation_url!, encoding: String.Encoding.utf8)
            Flump.LoadedAnimations[file_root] = data
            parseFlumpJSON(data)
        }catch{
            print("ERROR READING FILE \(file_root)")
        }
    }
    
    
    static func parseFlumpJSON(_ animation_data:String)
    {
        //print("PARSING FLUMP JSON")
        
        if(animation_data.isEmpty)
        {
            print("[FLUMP ERROR] You must provide metadata!")
        }
        
        let data:Data = animation_data.data(using: String.Encoding.utf8)!
        
        if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject>
        {
            
            var frame_rate:Float = 24
            
            if let json_frame_rate:Float = json["frameRate"] as? NSNumber as? Float
            {
                frame_rate = json_frame_rate
            }
            
            if let json_movies = json["movies"] as? [Dictionary<String, AnyObject>]
            {
                for json_movie in json_movies
                {
                    var movie_name:String = ""
                    var movie_layers:[FlumpLayer] = [FlumpLayer]()
                    
                    if let json_movie_name:String = json_movie["id"] as? NSString as? String
                    {
                        movie_name = json_movie_name
                    }else{
                        print("[ERROR] MovieClip found without name!")
                    }
                    
                    if let json_layers = json_movie["layers"] as? [Dictionary<String, AnyObject>]
                    {
                        for json_layer in json_layers
                        {
                            var layer_name:String = ""
                            var layer_keyframes:[FlumpKeyframe] = [FlumpKeyframe]()
                            
                            if let json_layer_name:String = json_layer["name"] as? NSString as? String
                            {
                                layer_name = json_layer_name
                            }else{
                                print("[ERROR] MovieClip found with name-less layer")
                            }
                            
                            if let keyframes = json_layer["keyframes"] as? [Dictionary<String, AnyObject>]
                            {
                                for keyframe in keyframes
                                {
                                    let duration:TimeInterval = TimeInterval((keyframe["duration"] as! NSNumber as Float) / frame_rate)
                                    let symbol:String? = keyframe["ref"] as? NSString as? String
                                    let start_frame:Float = keyframe["index"] as! NSNumber as Float
                                    let end_frame:Float = start_frame + (keyframe["duration"] as! NSNumber as Float)
                                    
                                    var tweened:Bool = true
                                    if let json_tweened:Bool = keyframe["tweened"] as? Bool
                                    {
                                        tweened = json_tweened
                                    }
                                    
                                    var pivot:CGPoint? = nil
                                    var position:CGPoint? = nil
                                    var rotation:CGFloat? = nil
                                    var x_scale:CGFloat? = nil
                                    var y_scale:CGFloat? = nil
                                    var alpha:CGFloat? = nil
                                    var label:String? = nil
                                    
                                    if let kf_pivot:[NSNumber] = keyframe["pivot"] as? [NSNumber]
                                    {
                                        pivot = CGPoint(x: kf_pivot[0] as CGFloat, y: kf_pivot[1] as CGFloat)
                                    }else{
                                        pivot = CGPoint(x:0,y:0)
                                    }
                                    
                                    //POSITION DEFAULTS TO (0,0)
                                    //MUTLIPLY Y by -1 TO CORRECT FOR Y-POS
                                    if let kf_position:[NSNumber] = keyframe["loc"] as? [NSNumber]
                                    {
                                        position = CGPoint(x: CGFloat(kf_position[0].floatValue), y: -1*CGFloat(kf_position[1].floatValue))
                                    }else{
                                        position = CGPoint(x: 0, y: 0)
                                    }
                                    
                                    //SCALE DEFAULTS TO 1
                                    if let kf_scale:[NSNumber] = keyframe["scale"] as? [NSNumber]
                                    {
                                        x_scale = CGFloat(kf_scale[0].floatValue)
                                        y_scale = CGFloat(kf_scale[1].floatValue)
                                    }else{
                                        x_scale = 1
                                        y_scale = 1
                                    }
                                    
                                    //ROTATION DEFAULTS TO 0
                                    //MUTLIPLY R by -1 TO CORRECT FOR Y-POS
                                    if let kf_skew:[NSNumber] = keyframe["skew"] as? [NSNumber]
                                    {
                                        rotation = -1*CGFloat(kf_skew[0].floatValue)
                                        
                                        //JANKY SKEW SUPPORT
                                        //basically, if our skew is (0,PI) that's a flipX
                                        if(rotation == 0 && kf_skew[1].floatValue != 0)
                                        {
                                            if(abs(kf_skew[1].floatValue - 3.1416) < 0.1)
                                            {
                                                x_scale = x_scale! * -1
                                            }
                                        }
                                        
                                    }else{
                                        rotation = 0
                                    }
                                    
                                    //ALPHA DEFAULTS TO 1
                                    if let kf_alpha:NSNumber = keyframe["alpha"] as? NSNumber
                                    {
                                        alpha = CGFloat(kf_alpha.floatValue)
                                    }else{
                                        alpha = 1
                                    }
                                    
                                    if let kf_label:String = keyframe["label"] as? NSString as? String
                                    {
                                        label = kf_label
                                    }
                                    
                                    layer_keyframes.append(FlumpKeyframe(symbolName: symbol,
                                            startFrame: start_frame,
                                            endFrame: end_frame,
                                            duration: duration,
                                            tweened: tweened,
                                            pivot: pivot!,
                                            position: position!,
                                            rotation: rotation!,
                                            xScale: x_scale!,
                                            yScale: y_scale!,
                                            alpha: alpha!,
                                            label: label
                                        )
                                    )
                                }
                            }
                            
                            movie_layers.append(FlumpLayer(name: layer_name, frames: layer_keyframes))
                            
                        }
                    }
                    
                    Flump.LoadedMovies[movie_name] = FlumpMovie(name: movie_name, frameRate: frame_rate, layers: movie_layers)
                }

            }
        }
    }
}
