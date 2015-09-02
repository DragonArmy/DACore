//
//  DAMetaNode.swift
//  testing
//
//  Created by Will Hankinson on 2/23/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

class DAMetaNode : DAContainer
{
    private static var LoadedMetadata = [String : Dictionary<String,AnyObject>]()
    
    private static var deviceTag:String = "_iphone6"
    
    private var fileRoot:String
    private var rootContainer:String?
    
    var rootWidth = 0
    var rootHeight = 0
    
    var placeholders    = [String:CGRect]()
    var buttons         = [String:DAButtonBase]()
    var labels          = [String:SKLabelNode]()
    
    var positions       = [SKNode:CGPoint]()
    
    private let SPRITES_PER_FRAME = 10
    private var asynchSpriteQueue = [(SKNode, Dictionary<String, AnyObject>)]()
    
    static func setup(device_tag:String)
    {
        DAMetaNode.deviceTag = device_tag
    }
    
    // tuple of (String,bool) is for file_root and whether it's resolutionIndependent or not
    static func loadMetadata(file_root_list:[(String, Bool)])
    {
        let bundle = NSBundle.mainBundle()
        
        for (file_root, omit_device_tag) in file_root_list
        {
            var device_tag = DAMetaNode.deviceTag
            if(omit_device_tag)
            {
                device_tag = ""
            }
            
            
            if let meta_url = bundle.URLForResource("\(file_root)\(device_tag)", withExtension: "txt")
            {
                println(meta_url)
                
                var error:NSError?
                if let metadata = String(contentsOfURL: meta_url, encoding: NSUTF8StringEncoding, error: &error)
                {
                    var error2:NSError?
                    var data = metadata.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                    if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error2) as? Dictionary<String, AnyObject>
                    {
                        DAMetaNode.LoadedMetadata[file_root] = json
                    }
                }
            }else{
                println("ERROR ERROR ERROR -- \(file_root)\(device_tag) NOT FOUND")
            }
        }
    }
    
    // tuple of (String,bool) is for file_root and whether it's resolutionIndependent or not
    static func preloadMetadataAsynch(file_root_list:[(String, Bool)])
    {
        for (file_root, omit_device_tag) in file_root_list
        {
            //println("QUEUING METADATA: \(file_root)")
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            let closure_file = file_root
            let closure_omit = omit_device_tag
            
            dispatch_async(backgroundQueue) {
                DAMetaNode.loadMetadata([(closure_file, closure_omit)])
                //println("FINISHED LOADING \(closure_file)")
            }
        }
    }
    
    override init()
    {
        fileRoot = ""
        rootContainer = ""
        super.init()
    }
    
    init(from_node:DAResetNode, asynchSprites asynch_sprites:Bool)
    {
        println("CREATING DAMetaNode from existing node!")
        fileRoot = ""
        rootContainer = from_node.name!
        
        super.init()
        
        let container = processContainerNode(from_node.cachedMetadata, withAsynch: asynch_sprites)
        container.resetPosition = nil
        
        var offset_x:CGFloat = 0
        var offset_y:CGFloat = 0
        
        if let dacon = container as? DAContainer
        {
            //println("\(node_child.name!) X/Y = \(dacon.x),\(dacon.y)     PIVOT = \(dacon.pivotX),\(dacon.pivotY)")
            offset_x = dacon.pivotX
            offset_y = dacon.pivotY
        }
        
        for root_child in container.children
        {
            if let node = root_child as? SKNode
            {
                
                node.removeFromParent()
                addChild(node)
                
                //offset us to our container's location since we're discarding the shell
                node.x += offset_x
                node.y += offset_y
                
                
                //update our positions so we can reset properly
                positions[node] = node.position
                
                if let resettable = node as? DAResetNode
                {
                    resettable.resetPosition = node.position
                }
            }
        }
    }
    
    init(file_root:String, fromContainer container_name:String?, resolutionIndependent omit_device_tag:Bool, asynchSprites asynch_sprites:Bool)
    {
        fileRoot = file_root
        rootContainer = container_name
        
        super.init()
        
        if(file_root == "")
        {
            return
        }
        
        if(DAMetaNode.LoadedMetadata.indexForKey(file_root) != nil)
        {
            processMetadata(DAMetaNode.LoadedMetadata[file_root]!, withAsynchSprites:asynch_sprites)
        }else{
            //synchronously load metadata if we initialize a MetaNode
            //println("SYNCHRONOUS LOAD: \(file_root)")

            DAMetaNode.loadMetadata([(file_root, omit_device_tag)])
            
            if let json = DAMetaNode.LoadedMetadata[file_root]
            {
                processMetadata(json, withAsynchSprites:asynch_sprites)
            }else{
                println("UNABLE TO LOAD \(file_root)")
                return
            }

        }
        
        name = file_root
        if(container_name != nil)
        {
            name = container_name!
        }
    }
    
    convenience init?(file_root:String, resolutionIndependent omit_device_tag:Bool)
    {
        self.init(file_root:file_root, fromContainer:nil, resolutionIndependent:omit_device_tag, asynchSprites:false)
    }
    
    convenience init?(file_root:String, fromContainer container_name:String?)
    {
        self.init(file_root:file_root, fromContainer:container_name, resolutionIndependent:false, asynchSprites:false)
    }
    
    convenience init?(file_root:String)
    {
        self.init(file_root:file_root, fromContainer:nil, resolutionIndependent:false, asynchSprites:false)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    //SUPER DUPER HELPFUL TYPED GETTERS
    //why use untyped more-verbose code like
    //    node.childNodeWithName("//scale9_frame") as? DAScale9
    //when you could instead do
    //    node.scale9WithName("frame")
    
    func containerWithName(container_name:String) -> DAContainer?
    {
        if(container_name.split("_").first! == "container")
        {
            println("[ERROR] containerWithName provides the container_, you may omit it from your call!")
        }
        
        return childNodeWithName("//container_" + container_name) as? DAContainer
    }
    
    func scale9WithName(scale9_name:String) -> DAScale9?
    {
        if(scale9_name.split("_").first! == "scale9")
        {
            println("[ERROR] scale9WithName provides the scale9_, you may omit it from your call!")
        }
        
        return childNodeWithName("//scale9_" + scale9_name) as? DAScale9
    }
    
    func progressWithName(progress_name:String) -> DAProgressBar?
    {
        if(progress_name.split("_").first! == "progress")
        {
            println("[ERROR] progressWithName provides the progress_, you may omit it from your call!")
        }
        
        return childNodeWithName("//progress_" + progress_name) as? DAProgressBar
    }
    
    func tabWithName(tab_name:String) -> DATabButton?
    {
        if(tab_name.split("_").first! == "tab")
        {
            println("[ERROR] tabWithName provides the progress_, you may omit it from your call!")
        }
        
        return childNodeWithName("//tab_" + tab_name) as? DATabButton
    }
    
    //simplest of the getters, doesn't prefix anything
    func imageWithName(image_name:String) -> SKSpriteNode?
    {
        let maybe_image = childNodeWithName("//" + image_name)
        
        if maybe_image == nil
        {
            return nil
        }
        
        if let image = maybe_image as? SKSpriteNode
        {
            return image
        }
        
        //helps in cases where we have something like btn_foo that has an image named foo
        //both end up with name "foo", so the childNodeWithName gets the first it finds
        println("[ERROR] Found \(maybe_image) while looking for a SKSpriteNode named \(image_name)")
        return nil
    }
    
    func labelWithName(label_name:String) -> SKLabelNode?
    {
        if(label_name.split("_").first! == "txt")
        {
            println("[ERROR] labelWithName provides the txt_, you may omit it from your call!")
        }
        
        return labels[label_name]
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func buttonWithName(button_name:String) -> DAButtonBase?
    {
        if(button_name.split("_").first! == "btn")
        {
            println("[ERROR] buttonWithName provides the btn_, you may omit it from your call!")
        }
        
        return buttons[button_name]
    }
    
    func placeholderWithName(placeholder_name:String) -> CGRect?
    {
        if(placeholder_name.split("_").first! == "placeholder")
        {
            println("[ERROR] placeholderWithName provides the placeholder_, you may omit it from your call!")
        }
        
        return placeholders[placeholder_name]
    }
    
    let DEBUG = false
    func processMetadata(json:Dictionary<String,AnyObject>, withAsynchSprites asynch:Bool)
    {
        //println("PROCESS METADATA    asynch=\(asynch)")
        if let root_width = json["root_width"] as? NSNumber as? Int
        {
            rootWidth = root_width
            if(DEBUG)
            {
                println("ROOT WIDTH: \(rootWidth)")
            }
        }
        
        if let root_height = json["root_height"] as? NSNumber as? Int
        {
            rootHeight = root_height
            if(DEBUG)
            {
                println("ROOT WIDTH: \(rootHeight)")
            }
        }
        
        if let children = json["children"] as? NSArray as? [AnyObject]
        {
            if(rootContainer == nil)
            {
                let node_children = processChildren(children, withAsynch:asynch);
                
                for node_child in node_children
                {
                    addChild(node_child);
                }
            }else{

                var got_one = false
                
                for raw_node in children
                {
                    let node = raw_node as! Dictionary<String,AnyObject>
                    let node_type = node["type"] as! NSString as! String
                    let node_name = node["name"] as! NSString as! String
                    
                    if(node_type == "container" && node_name == "container_\(rootContainer!)")
                    {
                        got_one = true
                        
                        let node_child = processContainerNode(node, withAsynch: asynch)
                        node_child.resetPosition = nil

                        var offset_x:CGFloat = 0
                        var offset_y:CGFloat = 0

                        if let dacon = node_child as? DAContainer
                        {
                            //println("\(node_child.name!) X/Y = \(dacon.x),\(dacon.y)     PIVOT = \(dacon.pivotX),\(dacon.pivotY)")
                            offset_x = dacon.pivotX
                            offset_y = dacon.pivotY
                        }
                        if(DEBUG)
                        {
                            println("OFFSET FOR \(node_child.name!) = \(offset_x),\(offset_y)")
                        }

                        for root_child in node_child.children
                        {
                            if let node = root_child as? SKNode
                            {

                                node.removeFromParent()
                                addChild(node)
                                
                                if(DEBUG)
                                {
                                     println("OFFSET \(node.name!) from \(node.x),\(node.y)")
                                }
                                
                                //offset us to our container's location since we're discarding the shell
                                node.x += offset_x
                                node.y += offset_y
                                
                                
                                //update our positions so we can reset properly
                                positions[node] = node.position

                                if let resettable = node as? DAResetNode
                                {
                                    resettable.resetPosition = node.position
                                }
                            }
                        }
                        break
                    }
                }
                
                if(got_one == false)
                {
                    println("ERROR -- UNABLE TO LOAD CHILD CONTAINER container_\(rootContainer!)")
                }
            }
        }
        
        
        
        if(asynch && asynchSpriteQueue.count > 0)
        {
            dispatch_after_delay(0.01, asynchProcessImage)
        }
    }
    
    func asynchImageAdded(image:SKNode)
    {
        //override me if you have any custom post processing stuff to do!
    }
    
    func asynchProcessImage()
    {
        var tries = SPRITES_PER_FRAME
        
        while(tries > 0)
        {
            tries -= 1
         
            let (placeholder, node) = asynchSpriteQueue.removeAtIndex(0)
            
            //println("**************************************************")
            //println(node)
            //println(placeholder)
            let real_node = self.processImageNodeSynchronously(node)
            //println(real_node)
            placeholder.addChild(real_node)
            
            
            asynchImageAdded(real_node)
            
//            println("ASYNCH SPRITE LOADED: \(real_node.name)")
            
            if(asynchSpriteQueue.count <= 0)
            {
                tries = 0
            }
        }
        
        if(asynchSpriteQueue.count > 0)
        {
            dispatch_after_delay(0.01, asynchProcessImage)
        }
    }
    
    //processChildren works a little differently in that it returns the children...
    //you don't have to actually do anything with them, but for compound objects such
    //as buttons and progress bars this is required
    func processChildren(children:[AnyObject], withAsynch asynch:Bool) -> [SKNode]
    {
        var child_nodes:[SKNode] = []
        
        for raw_node in children
        {
            if let node = raw_node as? Dictionary<String,AnyObject>
            {
                if let node_type = node["type"] as? NSString as? String
                {
                    switch node_type
                    {
                    case "container":
                        child_nodes.append( processContainerNode(node, withAsynch:asynch) )
                    case "text":
                        child_nodes.append( processTextNode(node) )
                    case "image":
                        child_nodes.append( processImageNode(node, withAsynch:asynch) )
                    case "placeholder":
                        if let modal = processPlaceholderNode(node)
                        {
                            child_nodes.append(modal)
                        }
                    default:
                        println("UH OH -- INVALID NODE FOUND: \(node_type)")
                        
                    }
                }
            }
        }
        
        return child_nodes
    }
    
    func processContainerNode(node:Dictionary<String, AnyObject>, withAsynch asynch:Bool) -> DAResetNode
    {
        var container:DAResetNode?
        
        if let container_name = node["name"] as? NSString as? String
        {

            let container_type = container_name.split("_")[0]
            
            switch(container_type)
            {
                case "container":
                    container = DAContainer()
                case "btn":
                    container = DAButton()
                    let btn_name = container_name.replace("btn_",withString:"")
                    buttons[btn_name] = container as? DAButtonBase
                    container!.name = btn_name
                case "scalebtn":
                    container = DAScaleButton()
                    let btn_name = container_name.replace("scalebtn_",withString:"")
                    buttons[btn_name] = container as? DAButtonBase
                    container!.name = btn_name
                case "progress":
                    container = DAProgressBar()
                case "tab":
                    container = DATabButton()
                case "scale9":
                    container = DAScale9()
                default:
                    println("ERROR: UNRECOGNIZED CONTAINER TYPE: \(container_type)")
                    container = DAContainer()
            }
        }
        
        //assign default container name if we didn't already assign a name
        if(container != nil && container!.name == nil)
        {
            container?.name = node["name"] as? NSString as? String
        }
        
        if let children = node["children"] as? NSArray as? [AnyObject]
        {
            let node_children = processChildren(children, withAsynch:asynch)
            for node_child in node_children
            {
                container?.addChild(node_child)
            }
        }
        
        //if we're a button, finalize our display state!
        if let button = container as? DAButtonBase
        {
            button.updateDisplay()
        }
        
        if let tab = container as? DATabButton
        {
            tab.createStates()
        }
        
        if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.position = CGPoint(x:position[0], y:position[1])
        }
        
        if let pivot = node["pivot"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            if let da_con = container as? DAContainerBase
            {
                da_con.pivotX = pivot[0]
                da_con.pivotY = pivot[1]
            }
        }
        
        //process scale9 after pivot just in case we need it
        if let scale9 = container as? DAScale9
        {
            if let size = node["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                scale9.baseWidth = size[0]
                scale9.baseHeight = size[1]
            }
        }
        
        positions[container!] = container!.position
        container!.resetPosition = container!.position
        
        container!.cachedMetadata = node
        
        return container!
    }
    
    func processTextNode(node:Dictionary<String, AnyObject>) -> SKLabelNode
    {
        //{"name":"header","type":"text","position":[-1,627.5],"size":[272,31],"color":"ff686f","font":"Arial","justification":"center","fontSize":40,"text":"TESTING PSD"}
        
        if let font = node["font"] as? NSString as? String
        {
            let label = SKLabelNode(fontNamed: font)
            
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            
            if let name = node["name"] as? NSString as? String
            {
                label.name = name
            }
            
            if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                label.position = CGPoint(x:position[0], y:position[1])
            }
            
            if let font_size = node["fontSize"] as? NSNumber as? CGFloat
            {
                label.fontSize = font_size
            }
            
            if let font_color_hex = node["color"] as? NSString as? String
            {
                label.fontColor = UIColor(rgba:"#\(font_color_hex)FF")
            }
            
            if let text = node["text"] as? NSString as? String
            {
                label.text = text
            }
            
            if let align = node["justification"] as? NSString as? String
            {
                if(align == "center")
                {
                    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
                }else if(align == "left"){
                    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
                }else if(align == "right"){
                    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
                }else{
                    println("[MetaNode] -- INVALID LABEL ORIENTATION ON LABEL \(label.name)")
                }
            }
            
            labels[label.name!] = label
            
            positions[label] = label.position
            return label
        }
        
        return SKLabelNode()
    }
    
    func processImageNode(node:Dictionary<String, AnyObject>, withAsynch asynch:Bool) -> SKNode
    {
        if(asynch)
        {
            var placeholder = SKNode()
            if let image_name = node["name"] as? NSString as? String
            {
                placeholder.name = "placeholder_\(image_name)"
                asynchSpriteQueue.append( (placeholder, node) )
            }
            
            return placeholder
        }else{
            return processImageNodeSynchronously(node)
        }
    }
    
    func processImageNodeSynchronously(node:Dictionary<String, AnyObject>) -> SKNode
    {
        if let image_name = node["name"] as? NSString as? String
        {
            let image_type = image_name.split("_")[0]
            
            let sprite = SKSpriteNode(imageNamed:image_name)
            
            sprite.name = node["name"] as? NSString as? String
            
            if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                sprite.position = CGPoint(x:position[0], y:position[1])
            }
            
            if(image_type == "flipX")
            {
                sprite.xScale = -1
            }
            
            //simple scale button!
            if(image_type == "scalebtn")
            {
                let container = DAScaleButton()
                container.position = sprite.position
                sprite.position = CGPoint(x:0,y:0)
                container.addChild(sprite)
                container.updateDisplay()
                
                if let btn_name = (node["name"] as? NSString as? String)?.replace("scalebtn_",withString:"")
                {
                    buttons[btn_name] = container as DAButtonBase
                    container.name = btn_name
                }
                
                positions[container] = container.position
                return container
            }
            
            positions[sprite] = sprite.position
            return sprite
        }
        
        return SKSpriteNode()
    }
    
    //no return type here
    func processPlaceholderNode(node:Dictionary<String, AnyObject>) -> SKShapeNode?
    {
        if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            if let size = node["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                if let name = node["name"] as? NSString as? String
                {
                    //println("ADD PLACEHOLDER \(name)")
                    placeholders[name] = CGRect(x: position[0] - size[0]/2.0, y: position[1] - size[1]/2.0, width: size[0], height: size[1])
                    
                    if(name.rangeOfString("modal", options: nil, range: nil, locale: nil) != nil)
                    {
                        println("ADD A MODAL")
                        let modal = SKShapeNode(rect: placeholders[name]!)
                        modal.name = "modal"
                        modal.fillColor = "#230211".toColor()
                        modal.alpha = 0.5
                        println("MADE A MODAL WITH RECT \(placeholders[name]!)")
                        return modal
                    }
                    
                }
            }
        }
        
        return nil
    }
    
    func printDisplayTree()
    {
        printDisplayTree(self, currentDepth:0)
    }
    
    func printDisplayTree(node:SKNode, currentDepth depth:Int)
    {
        let tab = join("", Array<String>(count: depth, repeatedValue: "  ")) + "->"
        let node_name = (node.name == nil ? node.description : node.name!)
        println("\(tab) \(node_name)     \(node.position)")
        
        if let container = node as? DAContainer
        {
            for child:AnyObject in container.children
            {
                if let node_child = child as? SKNode
                {
                    printDisplayTree(node_child, currentDepth: depth + 1)
                }
                
            }
        }
    }
    
}
