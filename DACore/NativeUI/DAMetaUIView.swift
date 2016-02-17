//
//  DAMetaUIView.swift
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import UIKit


class DAMetaUIView : DAUIContainer
{
    private static var LoadedMetadata = [String : Dictionary<String,AnyObject>]()
    
    private static var _deviceTag:String = "NOT SET"
    private static let NOT_SET = "NOT SET"
    static var deviceTag:String
    {
        get
        {
            if(_deviceTag == NOT_SET)
            {
                print("[WARNING] CALLS TO deviceTag WHILE VALUE IS NOT SET")
            }
            return _deviceTag
        }
        set(value)
        {
            _deviceTag = value
        }
    }
    static var scaleFactor:CGFloat = 1.0
    
    
    private var fileRoot:String
    private var rootContainer:String?
    
    var rootWidth:CGFloat = 0
    var rootHeight:CGFloat = 0
    
    var placeholders    = [String:CGRect]()
    var containers      = [String:DAUIContainer]()
    var tabs            = [String:DAUITabView]()
    var buttons         = [String:DAUIButton]()
    var images          = [String:DAUIImageView]()
    var labels          = [String:DAUILabel]()
     
    static func setup(device_tag:String, scale_factor:CGFloat)
    {
        DAMetaUIView.deviceTag = device_tag
        DAMetaUIView.scaleFactor = scale_factor
        
        
        let available_fonts = UIFont.familyNames()
        for(var i:Int = 0; i < available_fonts.count; i++)
        {
            let font_family = available_fonts[i]
            let font_names = UIFont.fontNamesForFamilyName(font_family)
            
            print("\(font_family): \(font_names)")
        }
    }
    
    // tuple of (String,bool) is for file_root and whether it's resolutionIndependent or not
    static func loadMetadata(file_root_list:[(String, Bool)])
    {
        let bundle = NSBundle.mainBundle()
        
        for (file_root, omit_device_tag) in file_root_list
        {
            var device_tag = DAMetaUIView.deviceTag
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
                
                DAMetaUIView.LoadedMetadata[file_root] = json
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
            let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            let closure_file = file_root
            let closure_omit = omit_device_tag
            
            dispatch_async(backgroundQueue) {
                DAMetaUIView.loadMetadata([(closure_file, closure_omit)])
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
    
    init(file_root:String, fromContainer container_name:String?, resolutionIndependent omit_device_tag:Bool)
    {
        print("INIT \(file_root):\(container_name):\(omit_device_tag)")
        fileRoot = file_root
        rootContainer = container_name
        
        super.init(frame:CGRect.zero)
        
        name = file_root
        
        if(file_root == "")
        {
            return
        }
        
        if(DAMetaUIView.LoadedMetadata.indexForKey(file_root) != nil)
        {
            processMetadata(DAMetaUIView.LoadedMetadata[file_root]!)
        }else{
            print("LOADING \(file_root) -------------------")
            
            //synchronously load metadata if we initialize a MetaView
            //print("SYNCHRONOUS LOAD: \(file_root)")
            
            DAMetaUIView.loadMetadata([(file_root, omit_device_tag)])
            
            if let json = DAMetaUIView.LoadedMetadata[file_root]
            {
                processMetadata(json)
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
        
        //set up all our frames on all our children
        reset(true)
    }
    
    
    convenience init?(file_root:String, resolutionIndependent omit_device_tag:Bool)
    {
        self.init(file_root:file_root, fromContainer:nil, resolutionIndependent:omit_device_tag)
    }
    
    convenience init?(file_root:String, fromContainer container_name:String?)
    {
        self.init(file_root:file_root, fromContainer:container_name, resolutionIndependent:false)
    }
    
    convenience init?(file_root:String)
    {
        self.init(file_root:file_root, fromContainer:nil, resolutionIndependent:false)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    //SUPER DUPER HELPFUL TYPED GETTERS
    func containerWithName(container_name:String) -> DAUIContainer?
    {
        if(container_name.split("_").first! == "container")
        {
            print("[ERROR] containerWithName provides the container_, you may omit it from your call!")
        }
        
        
        return containerWithName("container_\(container_name)")
    }
    
    func tabWithName(tab_name:String) -> DAUITabView
    {
        if(tab_name.split("_").first! == "tab")
        {
            print("[ERROR] tabWithName provides the tab_, you may omit it from your call!")
        }
        
        return tabs["tab_\(tab_name)"]!
    }
    
    //simplest of the getters, doesn't prefix anything
    func imageWithName(image_name:String) -> DAUIImageView?
    {
        return images[image_name]
    }
    
    func labelWithName(label_name:String) -> DAUILabel?
    {
        if(label_name.split("_").first! == "txt")
        {
            print("[ERROR] labelWithName omits the txt_, you may omit it from your call!")
        }
        
        return labels[label_name]
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func buttonWithName(button_name:String) -> DAUIButton?
    {
        if(button_name.split("_").first! == "btn")
        {
            print("[ERROR] buttonWithName omits the btn_, you may omit it from your call!")
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
    
    let DEBUG = true
    func processMetadata(json:Dictionary<String,AnyObject>)
    {
//        print("PROCESS METADATA")
        if let root_width = json["root_width"] as? NSNumber as? Int
        {
            rootWidth = CGFloat(root_width)*DAMetaUIView.scaleFactor
            if(DEBUG)
            {
                print("ROOT WIDTH: \(rootWidth)")
            }
        }
        
        if let root_height = json["root_height"] as? NSNumber as? Int
        {
            rootHeight = CGFloat(root_height)*DAMetaUIView.scaleFactor
            if(DEBUG)
            {
                print("ROOT WIDTH: \(rootHeight)")
            }
        }
        
        resetSize = CGSize(width: rootWidth, height: rootHeight)
        print("RESET SIZE: \(resetSize)")
        
        if let children = json["children"] as? NSArray as? [AnyObject]
        {
            if(rootContainer == nil)
            {
                let view_children = processChildren(children)
                
                print("ROOT HAS \(view_children.count) CHILDREN")
                for view_child in view_children
                {
                    print("ADDING CHILD \(view_child.name) -- \(view_child)")
                    addSubview(view_child)
                }
            }else{
                
                var got_one = false
                
                for raw_view in children
                {
                    let view = raw_view as! Dictionary<String,AnyObject>
                    let view_type = view["type"] as! NSString as String
                    let view_name = view["name"] as! NSString as String
                    
                    if(view_type == "container" && view_name == "container_\(rootContainer!)")
                    {
                        got_one = true
                        
                        let view_child = processContainerView(view)
                        view_child.resetPosition = CGPoint.zero
                        
                        rootHeight = view_child.resetSize.height
                        rootWidth = view_child.resetSize.width
                        resetSize = view_child.resetSize
                        
                        var offset_x:CGFloat = 0
                        var offset_y:CGFloat = 0
                        
                        offset_x = view_child.pivot.x
                        offset_y = view_child.pivot.y

                        if(DEBUG)
                        {
                            print("OFFSET FOR \(view_child.name!) = \(offset_x),\(offset_y)")
                        }
                        
                        for view in view_child.subviews
                        {
                            view.removeFromSuperview()
                            addSubview(view)
                            
                            if let da_view = view as? DAUIView
                            {
                                if(DEBUG)
                                {
                                    print("OFFSET \(da_view.name!) from \(da_view.center.x),\(da_view.center.y)")
                                }
                                
                                //offset us to our container's location since we're discarding the shell
                                da_view.resetPosition = da_view.resetPosition + CGPoint(x: offset_x, y: offset_y)
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
    
    //processChildren works a little differently in that it returns the children...
    //you don't have to actually do anything with them, but for compound objects such
    //as buttons and progress bars this is required
    func processChildren(children:[AnyObject]) -> [DAUIView]
    {
        var child_views:[DAUIView] = []
        
        for raw_view in children
        {
            if let view = raw_view as? Dictionary<String,AnyObject>
            {
                if let view_type = view["type"] as? NSString as? String
                {
                    switch view_type
                    {
                    case "container":
                        child_views.append( processContainerView(view) )
                    case "text":
                        child_views.append( processTextView(view) )
                    case "image":
                        child_views.append( processImageView(view) )
                    case "placeholder":
                        if let modal = processPlaceholder(view)
                        {
                            child_views.append(modal)
                        }
                    default:
                        print("UH OH -- INVALID NODE FOUND: \(view_type)")
                        
                    }
                }
            }
        }
        
        print("RETURNING \(child_views.count) CHILD VIEWS")
        return child_views
    }
    
    
    func processPosition(coords:[CGFloat], size:CGSize) -> CGPoint
    {
        //need to convert from y-positive, center-origin to y-negative, top-left origin
        
        print("PROCESS POSITION: \(coords)   SIZE: \(size)     ROOT:\(rootWidth),\(rootHeight)")
        
        var x = coords[0]
        var y = coords[1]

        //apply the scale factor
        x = x * DAMetaUIView.scaleFactor
        y = y * DAMetaUIView.scaleFactor
        print("          \(x),\(y)       scaled by \(DAMetaUIView.scaleFactor)")
        
        
        //invert the y axis and convert to origin-at-top-left
        x = rootWidth/2 + x
        y = rootHeight/2 - y
        print("          \(x),\(y)")
        
        
        //subtract w/2,h/2 because we're doing topleft and not center
        x -= size.width/2
        y -= size.height/2
        print("          \(x),\(y)")
        
        
        return CGPoint(x:x, y:y)
    }
    
    func processContainerView(view:Dictionary<String, AnyObject>) -> DAUIView
    {
        var container:DAUIView?
        
        if let container_name = view["name"] as? NSString as? String
        {
            
            let container_type = container_name.split("_")[0]
            
            switch(container_type)
            {
            case "container":
                container = DAUIContainer()
            case "btn":
                print("TODO: BUTTONS")
                container = DAUIContainer()
//                container = DAButton()
//                let btn_name = container_name.replace("btn_",withString:"")
//                buttons[btn_name] = container as? DAButtonBase
//                container!.name = btn_name
            case "scalebtn":
                print("TODO: SCALE BUTTONS")
                container = DAUIContainer()
//                container = DAScaleButton()
//                let btn_name = container_name.replace("scalebtn_",withString:"")
//                buttons[btn_name] = container as? DAButtonBase
//                container!.name = btn_name
            case "progress":
                print("ERROR: PROGRESS BARS NOT SUPPORTED YET")
                container = DAUIContainer()
            case "tab":
                container = DAUITabView()
            case "scale9":
                //SHHH, NOT ACTUALLY A CONTAINER
                return processScale9View(view)
            case "paragraph":
                print("ERROR: PARAGRAPH NOT SUPPORTED YET")
                container = DAUIContainer()
            default:
                print("ERROR: UNRECOGNIZED CONTAINER TYPE: \(container_type)")
                container = DAUIContainer()
            }
        }
        
        //assign default container name if we didn't already assign a name
        if(container != nil && container!.name == nil)
        {
            container!.name = view["name"] as? NSString as? String
        }
        
        if let children = view["children"] as? NSArray as? [AnyObject]
        {
            let view_children = processChildren(children)
            for view_child in view_children
            {
                container!.addSubview(view_child)
            }
        }
        
        if let tab = container as? DAUITabView
        {
            print("TODO: POST PROCESS TABS")
            //tab.createStates()
        }
        
        if let size = view["size"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.resetSize = CGSize(width:size[0]*DAMetaUIView.scaleFactor, height:size[1]*DAMetaUIView.scaleFactor)
        }
        
        if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.resetPosition = processPosition(position, size:container!.resetSize)
        }
        
        
        if let pivot = view["pivot"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.pivot = CGPoint(x: pivot[0]*DAMetaUIView.scaleFactor, y: pivot[1]*DAMetaUIView.scaleFactor)
        }
        
        container!.cachedMetadata = view
        
        return container!
    }
    
    func processScale9View(view:Dictionary<String, AnyObject>) -> DAUIImageView
    {
        var center:CGRect?
        var sprite:DAUIImageView?
        var size:CGRect?
        
        let children = view["children"] as! NSArray as [AnyObject]
        
        for raw_view in children
        {
            if let view = raw_view as? Dictionary<String,AnyObject>
            {
                if let view_type = view["type"] as? NSString as? String
                {
                    switch view_type
                    {
                    case "image":
                        sprite = processImageView(view) as? DAUIImageView
                    case "placeholder":
                        processPlaceholder(view)
                        
                        if let name = view["name"] as? NSString as? String
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
                        fatalError("scale9 containers can only contain a single image and two placeholders")
                    }
                }
            }
        }

        if let image = sprite?.image
        {

            //uiview uses actual pixel insets and not UV insets
            print("TODO: replace image with resizableImageWithCapInsets")
//            sprite!.centerRect = DAMetaUIView.getCenterRect(outerRect:sprite!.frame, innerRect:center!)
//            sprite!.width = size!.width
//            sprite!.height = size!.height
//            
//            if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
//            {
//                sprite!.position = processPosition(position)
//            }
            
            return sprite!
        }
        
        
        return DAUIImageView()
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
    
    func processTextView(view:Dictionary<String, AnyObject>) -> DAUILabel
    {
        //{"name":"header","type":"text","position":[-1,627.5],"size":[272,31],"color":"ff686f","font":"Arial","justification":"center","fontSize":40,"text":"TESTING PSD"}
        
        if let font = view["font"] as? NSString as? String
        {
            print("CREATING LABEL")
            let label = DAUILabel()
            
            let font_name = DAFont.getFont(font)
            var font_size:CGFloat = 14
            if let fs = view["fontSize"] as? NSNumber as? CGFloat
            {
                font_size = fs*DAMetaUIView.scaleFactor
            }
            
            if let font = UIFont(name: font_name, size: font_size)
            {
                label.font = font
            }else{
                print("ERROR -- COULD NOT CREATE FONT \(font_name)")
            }
            
            if let name = view["name"] as? NSString as? String
            {
                labels[name] = label
                label.name = name
            }
            
            if let size = view["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                label.resetSize = CGSize(width:size[0]*DAMetaUIView.scaleFactor, height:size[1]*DAMetaUIView.scaleFactor)
            }

            if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                label.resetPosition = processPosition(position, size:label.resetSize)
            }
            
            if let font_color_hex = view["color"] as? NSString as? String
            {
                label.textColor = UIColor(rgba:"#\(font_color_hex)FF")
            }
            
            if let text = view["text"] as? NSString as? String
            {
                label.text = text
            }
            
            if let align = view["justification"] as? NSString as? String
            {
                if(align == "center")
                {
                    label.textAlignment = NSTextAlignment.Center
                }else if(align == "left"){
                    label.textAlignment = NSTextAlignment.Left
                }else if(align == "right"){
                    label.textAlignment = NSTextAlignment.Right
                }else{
                    print("[DAMetaUIView] -- INVALID LABEL ORIENTATION ON LABEL \(label.name) -- \(align)")
                }
            }
            
            labels[label.name!] = label
            print("RETURNING \(label)")
            return label
        }
        
        return DAUILabel()
    }
    
    func processImageView(view:Dictionary<String, AnyObject>) -> DAUIView
    {
        if let image_name = view["name"] as? NSString as? String
        {
            let image = DAUIImageView(named: image_name)
            
            image.name = image_name
            
            //image size is implicit -- not in the json
            image.resetSize = image.image.image!.size*DAMetaUIView.scaleFactor
            
            if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                image.resetPosition = processPosition(position, size:image.resetSize)
            }
            
            let image_type = image_name.split("_")[0]
            
            //simple scale button!
            if(image_type == "scalebtn")
            {
                print("TODO: SIMPLE SCALE BUTTON")
                
                let container = DAUIButton()
                
                return container
//                let container = DAScaleButton()
//                container.position = image.position
//                image.position = CGPoint(x:0,y:0)
//                container.addChild(image)
//                container.updateDisplay()
//                
//                if let btn_name = (view["name"] as? NSString as? String)?.replace("scalebtn_",withString:"")
//                {
//                    buttons[btn_name] = container as DAButtonBase
//                    container.name = btn_name
//                }
//                
//                return container
            }
            
            
            images[image_name] = image
            
            return image
        }
        
        return DAUIView()
    }
    
    //no return type here
    func processPlaceholder(view:Dictionary<String, AnyObject>) -> DAUIView?
    {
        if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            if let size = view["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                if let name = view["name"] as? NSString as? String
                {
                    placeholders[name] = CGRect(x: position[0] - size[0]/2.0, y: position[1] - size[1]/2.0, width: size[0], height: size[1])
                    
                    if(name.rangeOfString("modal", options: [], range: nil, locale: nil) != nil)
                    {
                        print("TODO: ADD MODALS")
//                        let modal = SKSpriteView(color: "#230211".toColor(), size: placeholders[name]!.size)
//                        modal.alpha = 0.7
//                        modal.name = "modal"
//                        modal.position = placeholders[name]!.center
//                        return modal
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
    
    func printDisplayTree(view:DAUIView, currentDepth depth:Int)
    {
        let tab = Array<String>(count: depth, repeatedValue: "  ").joinWithSeparator("") + "->"
        let view_name = (view.name == nil ? view.description : view.name!)
        print("\(tab) \(view_name)     \(view.frame.center)")
        
        if let container = view as? DAUIContainer
        {
            for child:AnyObject in container.subviews
            {
                if let view_child = child as? DAUIView
                {
                    printDisplayTree(view_child, currentDepth: depth + 1)
                }
                
            }
        }
    }
    
}