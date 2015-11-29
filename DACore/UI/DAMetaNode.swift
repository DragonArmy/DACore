//
//  DAMetaNode.swift
//  testing
//
//  Created by Will Hankinson on 2/23/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import SpriteKit


class AsynchSprite
{
    weak var metaNode:DAMetaNode?
    weak var placeholder:SKNode?
    var useTextureCache:Bool = false
    
    var node:Dictionary<String, AnyObject>
    
    init(metaNode meta_node:DAMetaNode, node:Dictionary<String, AnyObject>, withPlaceholder placeholder:SKNode, useTextureCache use_texture_cache:Bool=false)
    {
        self.metaNode = meta_node
        self.node = node
        self.useTextureCache = use_texture_cache
        self.placeholder = placeholder
    }
}

class DATextureCache
{
    private static var cache = [String:SKTexture]()
    
    static func get(texture_name:String) -> SKTexture
    {
        if(!cache.keys.contains(texture_name))
        {
            cache[texture_name] = SKTexture(imageNamed:texture_name)
        }
    
        return cache[texture_name]!
    }
}

class DAMetaNode : DAContainer
{
    private static var LoadedMetadata = [String : Dictionary<String,AnyObject>]()
    
    private static let SPRITES_PER_FRAME = 25
    static var ASYNCH_SPRITES = [AsynchSprite]()
    
    static var deviceTag:String = "_iphone6"
    
    private var fileRoot:String
    private var rootContainer:String?
    
    var rootWidth = 0
    var rootHeight = 0
    
    var placeholders    = [String:CGRect]()
    var buttons         = [String:DAButtonBase]()
    var labels          = [String:SKLabelNode]()
    var paragraphs      = [String:DAParagraphNode]()
    

    
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
                print(meta_url)
                
                let metadata = try! String(contentsOfURL: meta_url, encoding: NSUTF8StringEncoding)
                
                let data = metadata.dataUsingEncoding(NSUTF8StringEncoding)!
                
                let json = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? Dictionary<String, AnyObject>
                
                DAMetaNode.LoadedMetadata[file_root] = json
            }else{
                print("ERROR ERROR ERROR -- \(file_root)\(device_tag) NOT FOUND")
            }
        }
    }
    
    // tuple of (String,bool) is for file_root and whether it's resolutionIndependent or not
    static func preloadMetadataAsynch(file_root_list:[(String, Bool)])
    {
        for (file_root, omit_device_tag) in file_root_list
        {
            //print("QUEUING METADATA: \(file_root)")
            
           let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            let closure_file = file_root
            let closure_omit = omit_device_tag
            
            dispatch_async(backgroundQueue) {
                DAMetaNode.loadMetadata([(closure_file, closure_omit)])
                //print("FINISHED LOADING \(closure_file)")
            }
            
        }
    }
    
    override init()
    {
        fileRoot = ""
        rootContainer = ""
        super.init()
    }
    
    init(from_node:DAResetNode, asynchSprites asynch_sprites:Bool, useTextureCache use_texture_cache:Bool=false)
    {
        print("CREATING DAMetaNode from existing node!")
        fileRoot = ""
        rootContainer = from_node.name!
        
        super.init()
        
        let container = processContainerNode(from_node.cachedMetadata, withAsynch: asynch_sprites) as! DAResetNode
        container.resetPosition = nil
        
        var offset_x:CGFloat = 0
        var offset_y:CGFloat = 0
        
        if let dacon = container as? DAContainer
        {
            //print("\(node_child.name!) X/Y = \(dacon.x),\(dacon.y)     PIVOT = \(dacon.pivotX),\(dacon.pivotY)")
            offset_x = dacon.pivotX
            offset_y = dacon.pivotY
        }
        
        for node in container.children
        {
            node.removeFromParent()
            addChild(node)
            
            //offset us to our container's location since we're discarding the shell
            node.x += offset_x
            node.y += offset_y
            
            if let resettable = node as? DAResetNode
            {
                resettable.resetPosition = node.position
            }
        }
    }
    
    init(file_root:String, fromContainer container_name:String?, resolutionIndependent omit_device_tag:Bool, asynchSprites asynch_sprites:Bool, useTextureCache use_texture_cache:Bool=false)
    {
        fileRoot = file_root
        rootContainer = container_name
        
        super.init()
        
        name = file_root
        
        if(file_root == "")
        {
            return
        }
        
        if(DAMetaNode.LoadedMetadata.indexForKey(file_root) != nil)
        {
            processMetadata(DAMetaNode.LoadedMetadata[file_root]!, withAsynchSprites: asynch_sprites, useTextureCache: use_texture_cache)
        }else{
            print("LOADING \(file_root) -------------------")
            
            //synchronously load metadata if we initialize a MetaNode
            //print("SYNCHRONOUS LOAD: \(file_root)")

            DAMetaNode.loadMetadata([(file_root, omit_device_tag)])
            
            if let json = DAMetaNode.LoadedMetadata[file_root]
            {
                processMetadata(json, withAsynchSprites:asynch_sprites, useTextureCache:use_texture_cache)
            }else{
                print("UNABLE TO LOAD \(file_root)")
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
    func containerWithName(container_name:String) -> DAContainer?
    {
        if(container_name.split("_").first! == "container")
        {
            print("[ERROR] containerWithName provides the container_, you may omit it from your call!")
        }
        
        return childNodeWithName(".//container_" + container_name) as? DAContainer
    }
    
    func paragraphWithName(paragraph_name:String) -> DAParagraphNode?
    {
        if(paragraph_name.split("_").first! == "paragraph")
        {
            print("[ERROR] paragraphWithName provides the paragraph_, you may omit it from your call!")
        }
        
        return paragraphs[paragraph_name]
    }
    
    func progressWithName(progress_name:String) -> DAProgressBar?
    {
        if(progress_name.split("_").first! == "progress")
        {
            print("[ERROR] progressWithName provides the progress_, you may omit it from your call!")
        }
        
        return childNodeWithName(".//progress_" + progress_name) as? DAProgressBar
    }
    
    func tabWithName(tab_name:String) -> DATabButton?
    {
        if(tab_name.split("_").first! == "tab")
        {
            print("[ERROR] tabWithName provides the progress_, you may omit it from your call!")
        }
        
        return childNodeWithName(".//tab_" + tab_name) as? DATabButton
    }
    
    //simplest of the getters, doesn't prefix anything
    func imageWithName(image_name:String) -> SKSpriteNode?
    {
        let maybe_image = childNodeWithName(".//" + image_name)
        
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
        print("[ERROR] Found \(maybe_image) while looking for a SKSpriteNode named \(image_name)")
        return nil
    }
    
    func labelWithName(label_name:String) -> SKLabelNode?
    {
        if(label_name.split("_").first! == "txt")
        {
            print("[ERROR] labelWithName provides the txt_, you may omit it from your call!")
        }
        
        return labels[label_name]
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func buttonWithName(button_name:String) -> DAButtonBase?
    {
        if(button_name.split("_").first! == "btn")
        {
            print("[ERROR] buttonWithName provides the btn_, you may omit it from your call!")
        }
        
        return buttons[button_name]
    }
    
    func placeholderWithName(placeholder_name:String) -> CGRect?
    {
        if(placeholder_name.split("_").first! == "placeholder")
        {
            print("[ERROR] placeholderWithName provides the placeholder_, you may omit it from your call!")
        }
        
        return placeholders[placeholder_name]
    }
    
    let DEBUG = false
    func processMetadata(json:Dictionary<String,AnyObject>, withAsynchSprites asynch:Bool, useTextureCache use_texture_cache:Bool=false)
    {
        //print("PROCESS METADATA    asynch=\(asynch)")
        if let root_width = json["root_width"] as? NSNumber as? Int
        {
            rootWidth = root_width
            if(DEBUG)
            {
                print("ROOT WIDTH: \(rootWidth)")
            }
        }
        
        if let root_height = json["root_height"] as? NSNumber as? Int
        {
            rootHeight = root_height
            if(DEBUG)
            {
                print("ROOT WIDTH: \(rootHeight)")
            }
        }
        
        if let children = json["children"] as? NSArray as? [AnyObject]
        {
            if(rootContainer == nil)
            {
                let node_children = processChildren(children, withAsynch:asynch, useTextureCache:use_texture_cache);
                
                for node_child in node_children
                {
                    addChild(node_child);
                }
            }else{

                var got_one = false
                
                for raw_node in children
                {
                    let node = raw_node as! Dictionary<String,AnyObject>
                    let node_type = node["type"] as! NSString as String
                    let node_name = node["name"] as! NSString as String
                    
                    if(node_type == "container" && node_name == "container_\(rootContainer!)")
                    {
                        got_one = true
                        
                        let node_child = processContainerNode(node, withAsynch: asynch)
                        (node_child as! DAResetNode).resetPosition = nil

                        var offset_x:CGFloat = 0
                        var offset_y:CGFloat = 0

                        if let dacon = node_child as? DAContainer
                        {
                            //print("\(node_child.name!) X/Y = \(dacon.x),\(dacon.y)     PIVOT = \(dacon.pivotX),\(dacon.pivotY)")
                            offset_x = dacon.pivotX
                            offset_y = dacon.pivotY
                        }
                        if(DEBUG)
                        {
                            print("OFFSET FOR \(node_child.name!) = \(offset_x),\(offset_y)")
                        }

                        for node in node_child.children
                        {
                            node.removeFromParent()
                            addChild(node)
                            
                            if(DEBUG)
                            {
                                 print("OFFSET \(node.name!) from \(node.x),\(node.y)")
                            }
                            
                            //offset us to our container's location since we're discarding the shell
                            node.x += offset_x
                            node.y += offset_y
                            

                            if let resettable = node as? DAResetNode
                            {
                                resettable.resetPosition = node.position
                            }
                        }
                        break
                    }
                }
                
                if(got_one == false)
                {
                    print("ERROR -- UNABLE TO LOAD CHILD CONTAINER container_\(rootContainer!)")
                }
            }
        }
    }
    
    func asynchImageAdded(image:SKNode)
    {
        //override me if you have any custom post processing stuff to do!
    }

    static let FRAME_BUDGET = Double(1)/Double(60)
    static func processAsynchImages(frame_start:NSDate)
    {
        if(ASYNCH_SPRITES.count == 0)
        {
            return
        }
        
        var elapsed = NSDate().timeIntervalSinceDate(frame_start)
        var count = 0
        while(ASYNCH_SPRITES.count > 0 && elapsed < FRAME_BUDGET)
        {
            count += 1
            let asynch_sprite = ASYNCH_SPRITES.removeAtIndex(0)
            if let meta_node = asynch_sprite.metaNode
            {
                meta_node.asynchProcessImage(asynch_sprite)
            }
            
            elapsed = NSDate().timeIntervalSinceDate(frame_start)
        }
        
        print("LOADED \(count) ASYNCH IMAGE(S) (\(ASYNCH_SPRITES.count) remaining)")
        
//        for(var i = 0; i < min(ASYNCH_SPRITES.count, SPRITES_PER_FRAME); i++)
//        {
//            let asynch_sprite = ASYNCH_SPRITES.removeAtIndex(0)
//            if let meta_node = asynch_sprite.metaNode
//            {
//                meta_node.asynchProcessImage(asynch_sprite)
//            }
//            
//        }
    }
    
    func finalizeImages()
    {
        var final_count = 0
        for(var i = 0; i < DAMetaNode.ASYNCH_SPRITES.count; i++)
        {
            let asynch_sprite = DAMetaNode.ASYNCH_SPRITES[i]
            if let meta_node = asynch_sprite.metaNode
            {
                if meta_node == self
                {
                    final_count += 1
                    DAMetaNode.ASYNCH_SPRITES.removeAtIndex(i)
                    i -= 1
                    
                    asynchProcessImage(asynch_sprite)
                }
            }
        }
        
        if(final_count > 0)
        {
            print("\(name) FINALIZED \(final_count) IMAGES")
        }
    }
    
    func asynchProcessImage(asynch_sprite:AsynchSprite)
    {
//        print("PROCESSING \(asynch_sprite.metaNode!)")
        
        if let placeholder = asynch_sprite.placeholder
        {
            let real_node = self.processImageNodeSynchronously(asynch_sprite.node, useTextureCache: asynch_sprite.useTextureCache)
            placeholder.addChild(real_node)
            asynchImageAdded(real_node)
        }else{
            print("[WARNING] ONE OF YOUR ASYNCH PLACEHOLDERS HAS GONE ROGUE")
        }

    }
    
    //processChildren works a little differently in that it returns the children...
    //you don't have to actually do anything with them, but for compound objects such
    //as buttons and progress bars this is required
    func processChildren(children:[AnyObject], withAsynch asynch:Bool, useTextureCache use_texture_cache:Bool=false) -> [SKNode]
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
                        child_nodes.append( processContainerNode(node, withAsynch:asynch, useTextureCache: use_texture_cache) )
                    case "text":
                        child_nodes.append( processTextNode(node) )
                    case "image":
                        child_nodes.append( processImageNode(node, withAsynch:asynch, useTextureCache:use_texture_cache) )
                    case "placeholder":
                        if let modal = processPlaceholderNode(node)
                        {
                            child_nodes.append(modal)
                        }
                    default:
                        print("UH OH -- INVALID NODE FOUND: \(node_type)")
                        
                    }
                }
            }
        }
        
        return child_nodes
    }
    
    func processContainerNode(node:Dictionary<String, AnyObject>, withAsynch asynch:Bool, useTextureCache use_texture_cache:Bool=false) -> SKNode
    {
        var container:DAResetNode?
        
        var ignore_children = false
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
                    //SHHH, NOT ACTUALLY A CONTAINER
                    return processScale9Node(node, useTextureCache: use_texture_cache)
                case "paragraph":
                    let children = node["children"] as! NSArray as [AnyObject]
                    let paragraph_name = container_name.replace("paragraph_",withString:"")
                
                    container = processParagraphNode(paragraph_name, withChildren: children)
                    ignore_children = true
                default:
                    print("ERROR: UNRECOGNIZED CONTAINER TYPE: \(container_type)")
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
            if(ignore_children)
            {
                //I HAVE ABANDONED MY CHILD
            }else{
                
                let node_children = processChildren(children, withAsynch:asynch)
                for node_child in node_children
                {
                        container?.addChild(node_child)
                }
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
        
        container!.resetPosition = container!.position
        
        container!.cachedMetadata = node
        
        return container!
    }
    
    func processScale9Node(node:Dictionary<String, AnyObject>, useTextureCache use_texture_cache:Bool=false) -> SKSpriteNode
    {
        var center:CGRect?
        var sprite:SKSpriteNode?
        var size:CGRect?
        
        let children = node["children"] as! NSArray as [AnyObject]

        for raw_node in children
        {
            if let node = raw_node as? Dictionary<String,AnyObject>
            {
                if let node_type = node["type"] as? NSString as? String
                {
                    switch node_type
                    {
                    case "image":
                        sprite = processImageNodeSynchronously(node, useTextureCache:use_texture_cache) as? SKSpriteNode
                    case "placeholder":
                        processPlaceholderNode(node)
                        
                        if let name = node["name"] as? NSString as? String
                        {
                            if(name == "size")
                            {
                                size = placeholderWithName(name)!
                            }else if(name == "center"){
                                center = placeholderWithName(name)!
                            }else{
                                print("EXTRA SCALE9 PLACEHOLDER: \(name)")
                            }
                            
                        }
                    default:
                        fatalError("PARAGRAPH containers can only contain a single image and two placeholders")
                    }
                }
            }
        }
        
        if sprite != nil
        {
            sprite!.centerRect = DAMetaNode.getCenterRect(outerRect:sprite!.frame, innerRect:center!)
            sprite!.width = size!.width
            sprite!.height = size!.height
            
            if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                sprite!.position = CGPoint(x:position[0], y:position[1])
            }
            
            return sprite!
        }
        
        
        return SKSpriteNode()
    }
    
    static func getCenterRect(outerRect outer:CGRect, innerRect inner:CGRect) -> CGRect
    {
        let full_width = outer.width
        let full_height = outer.height
        
        let left = inner.minX - outer.minX
        let bottom = inner.minY - outer.minY
        
        let x = left / full_width
        let y = bottom / full_height
        let w = inner.width / full_width
        let h = inner.height / full_height
        
        return CGRect(x:x, y:y, width:w, height:h)
    }
    
    func processParagraphNode(name:String, withChildren children:[AnyObject]) -> DAParagraphNode
    {
        let node = DAParagraphNode()
        node.name = name
        
        var placeholder:CGRect?
        var label:SKLabelNode?
        
        for raw_node in children
        {
            if let node = raw_node as? Dictionary<String,AnyObject>
            {
                if let node_type = node["type"] as? NSString as? String
                {
                    switch node_type
                    {
                        case "text":
                            label = processTextNode(node)
                        case "placeholder":
                            processPlaceholderNode(node)
                            if let name = node["name"] as? NSString as? String
                            {
                                placeholder = placeholders[name]!
                            }
                        default:
                            fatalError("PARAGRAPH containers can only contain a single text field and a single placeholder")
                    }
                }
            }
        }
        
        if(placeholder == nil || label == nil)
        {
            fatalError("PARAGRAPH must contain a text field and a placeholder")
        }
        
        let paragraph = node.paragraph
        paragraph.fontColor = label!.fontColor!
        paragraph.horizontalAlignmentMode = label!.horizontalAlignmentMode
        paragraph.fontSize = label!.fontSize
        paragraph.fontName = label!.fontName!
        paragraph.text = label!.text!
        
        paragraph.paragraphWidth = placeholder!.width

        if(label!.horizontalAlignmentMode == .Left)
        {
            paragraph.explicitAnchorPoint = CGPointMake(0, 1)
            node.x = placeholder!.minX
        }else if(label!.horizontalAlignmentMode == .Right){
            paragraph.explicitAnchorPoint = CGPointMake(1, 1)
            node.x = placeholder!.maxX
        }else if(label!.horizontalAlignmentMode == .Center){
            paragraph.explicitAnchorPoint = CGPointMake(0.5, 1)
            node.x = placeholder!.center.x
        }else{
            fatalError("UH OH! WE CURRENTLY ONLY SUPPORT Left/Right/Center Justifications")
        }
        
        node.y = placeholder!.maxY
        paragraphs[name] = node
        return node
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
                    print("[MetaNode] -- INVALID LABEL ORIENTATION ON LABEL \(label.name)")
                }
            }
            
            labels[label.name!] = label
            
            return label
        }
        
        return SKLabelNode()
    }
    
    func processImageNode(node:Dictionary<String, AnyObject>, withAsynch asynch:Bool, useTextureCache use_texture_cache:Bool=false) -> SKNode
    {
        if(asynch)
        {
            let placeholder = SKNode()
            if let image_name = node["name"] as? NSString as? String
            {
                placeholder.name = "placeholder_\(image_name)"
                DAMetaNode.ASYNCH_SPRITES.append(AsynchSprite(metaNode:self, node: node, withPlaceholder: placeholder, useTextureCache: use_texture_cache))
            }
            
            return placeholder
        }else{
            return processImageNodeSynchronously(node, useTextureCache:use_texture_cache)
        }
    }
    
    func processImageNodeSynchronously(node:Dictionary<String, AnyObject>, useTextureCache use_texture_cache:Bool) -> SKNode
    {
        if let image_name = node["name"] as? NSString as? String
        {
            var image:SKSpriteNode
            
            if(use_texture_cache)
            {
                image = SKSpriteNode(texture:DATextureCache.get(image_name))
            }else{
                image = SKSpriteNode(imageNamed:image_name)
            }
            
            image.name = node["name"] as? NSString as? String
            
            if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                image.position = CGPoint(x:position[0], y:position[1])
            }
            
            let image_type = image_name.split("_")[0]
            if(image_type == "flipX")
            {
                image.xScale = -1
            }

            //simple scale button!
            if(image_type == "scalebtn")
            {
                let container = DAScaleButton()
                container.position = image.position
                image.position = CGPoint(x:0,y:0)
                container.addChild(image)
                container.updateDisplay()
                
                if let btn_name = (node["name"] as? NSString as? String)?.replace("scalebtn_",withString:"")
                {
                    buttons[btn_name] = container as DAButtonBase
                    container.name = btn_name
                }
                
                return container
            }
            
            return image
        }
        
        return SKSpriteNode()
    }
    
    //no return type here
    func processPlaceholderNode(node:Dictionary<String, AnyObject>) -> SKNode?
    {
        if let position = node["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            if let size = node["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                if let name = node["name"] as? NSString as? String
                {
                    placeholders[name] = CGRect(x: position[0] - size[0]/2.0, y: position[1] - size[1]/2.0, width: size[0], height: size[1])
                    
                    if(name.rangeOfString("modal", options: [], range: nil, locale: nil) != nil)
                    {
                        let modal = SKSpriteNode(color: "#230211".toColor(), size: placeholders[name]!.size)
                        modal.alpha = 0.5
                        modal.name = "modal"
                        modal.position = placeholders[name]!.center
                        return modal
                    }
                    
                }
            }
        }
        
        return nil
    }
    
    func printDisplayTree()
    {
        print("------------------------ DISPLAY TREE ------------------------")
        printDisplayTree(self, currentDepth:0)
    }
    
    func printDisplayTree(node:SKNode, currentDepth depth:Int)
    {
        let tab = Array<String>(count: depth, repeatedValue: "  ").joinWithSeparator("") + "->"
        let node_name = (node.name == nil ? node.description : node.name!)
        print("\(tab) \(node_name)     \(node.position)")
        
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
