//
//  DAMetaUIView.swift
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import UIKit


class DAMetaView : DAContainerView
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
    private var assetFolder:String
    private var rootContainer:String?

    //MOVED to superclass
//    var rootWidth:CGFloat = 0
//    var rootHeight:CGFloat = 0
    
    var placeholders    = [String:DAView]()
    var containers      = [String:DAContainerView]()
    var tabs            = [String:DATabView]()
    var buttons         = [String:DAButtonViewBase]()
    var images          = [String:DAImageView]()
    var labels          = [String:DALabelView]()
     
    static func setup(device_tag:String, scale_factor:CGFloat)
    {
        DAMetaView.deviceTag = device_tag
        DAMetaView.scaleFactor = scale_factor
        
        
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
            var device_tag = DAMetaView.deviceTag
            if(omit_device_tag)
            {
                device_tag = ""
            }
            
            
            if let meta_url = bundle.URLForResource("\(file_root)\(device_tag)/\(file_root)\(device_tag)", withExtension: "txt")
            {
                print(meta_url)
                
                let metadata = try! String(contentsOfURL: meta_url, encoding: NSUTF8StringEncoding)
                
                let data = metadata.dataUsingEncoding(NSUTF8StringEncoding)!
                
                let json = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? Dictionary<String, AnyObject>
                
                DAMetaView.LoadedMetadata[file_root] = json
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
                DAMetaView.loadMetadata([(closure_file, closure_omit)])
                //print("FINISHED LOADING \(closure_file)")
            }
            
        }
    }
    
    override init()
    {
        fileRoot = ""
        rootContainer = ""
        assetFolder = ""
        super.init()
    }
    
    init(file_root:String, fromContainer container_name:String?, resolutionIndependent omit_device_tag:Bool)
    {
        print("INIT \(file_root):\(container_name):\(omit_device_tag)")
        fileRoot = file_root
        rootContainer = container_name
        
        var device_tag = DAMetaView.deviceTag
        if(omit_device_tag)
        {
            device_tag = ""
        }
        assetFolder = "\(file_root)\(device_tag)"
        
        super.init(frame:CGRect.zero)
        
        name = file_root
        
        if(file_root == "")
        {
            return
        }
        
        if(DAMetaView.LoadedMetadata.indexForKey(file_root) != nil)
        {
            processMetadata(DAMetaView.LoadedMetadata[file_root]!)
        }else{
            print("LOADING \(file_root) -------------------")
            
            //synchronously load metadata if we initialize a MetaView
            //print("SYNCHRONOUS LOAD: \(file_root)")
            
            DAMetaView.loadMetadata([(file_root, omit_device_tag)])
            
            if let json = DAMetaView.LoadedMetadata[file_root]
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
        
        //scale9 placeholders are in the wrong coordinate system until AFTER we reset the tree, so have to do this after
        postProcessScale9Views(self)
        
        //we probably don't want our root view centered at 0,0, so assume we want it at rootWidth/2, rootHeight/2
        center = CGPoint(x:rootWidth/2, y:rootHeight/2)
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
    func containerWithName(container_name:String) -> DAContainerView?
    {
        if(container_name.split("_").first! == "container")
        {
            print("[ERROR] containerWithName provides the container_, you may omit it from your call!")
        }
        
        
        return containers["container_\(container_name)"]
    }
    
    func tabWithName(tab_name:String) -> DATabView?
    {
        if(tab_name.split("_").first! == "tab")
        {
            print("[ERROR] tabWithName provides the tab_, you may omit it from your call!")
        }
        
        return tabs[tab_name]
    }
    
    //simplest of the getters, doesn't prefix anything
    func imageWithName(image_name:String) -> DAImageView?
    {
        return images[image_name]
    }
    
    func labelWithName(label_name:String) -> DALabelView?
    {
        if(label_name.split("_").first! == "txt")
        {
            print("[ERROR] labelWithName omits the txt_, you may omit it from your call!")
        }
        
        return labels[label_name]
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func buttonWithName(button_name:String) -> DAButtonViewBase?
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
        
        return placeholders[placeholder_name]?.frame
    }
    
    let DEBUG = false
    func processMetadata(json:Dictionary<String,AnyObject>)
    {
//        print("PROCESS METADATA")
        if let root_width = json["root_width"] as? NSNumber as? Int
        {
            rootWidth = CGFloat(root_width)*DAMetaView.scaleFactor
            if(DEBUG)
            {
                print("ROOT WIDTH: \(rootWidth)")
            }
        }
        
        if let root_height = json["root_height"] as? NSNumber as? Int
        {
            rootHeight = CGFloat(root_height)*DAMetaView.scaleFactor
            if(DEBUG)
            {
                print("ROOT WIDTH: \(rootHeight)")
            }
        }
        
        resetSize = CGSize(width: rootWidth, height: rootHeight)
        
        if let children = json["children"] as? NSArray as? [AnyObject]
        {
            if(rootContainer == nil)
            {
                let view_children = processChildren(children)
                
                for view_child in view_children
                {
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
                            
                            if let da_view = view as? DAView
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
    func processChildren(children:[AnyObject]) -> [DAView]
    {
        var child_views:[DAView] = []
        
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
        
        return child_views
    }
    
    func processPosition(coords:[CGFloat]) -> CGPoint
    {
        var x = coords[0]
        var y = coords[1]

        //apply the scale factor
        x = x * DAMetaView.scaleFactor
        y = y * DAMetaView.scaleFactor
        
        return CGPoint(x:x, y:y)
    }
    
    func processContainerView(view:Dictionary<String, AnyObject>) -> DAView
    {
        var container:DAView!
        
        if let container_name = view["name"] as? NSString as? String
        {
            
            let container_type = container_name.split("_")[0]
            
            switch(container_type)
            {
                case "container":
                    container = DAContainerView()
                case "btn":
                    container = DAButtonView()
                    
                    let btn_name = container_name.replace("btn_",withString:"")
                    buttons[btn_name] = container as? DAButtonViewBase
                    container.name = btn_name
                    
                case "scalebtn":
                    print("TODO: SCALE BUTTONS")
                    container = DAScaleButtonView()

                    let btn_name = container_name.replace("scalebtn_",withString:"")
                    buttons[btn_name] = container as? DAButtonViewBase
                    container.name = btn_name
                case "progress":
                    print("ERROR: PROGRESS BARS NOT SUPPORTED YET")
                    container = DAContainerView()
                case "tab":
                    container = DATabView()
                    
                    let tab_name = container_name.replace("tab_", withString:"")
                    tabs[tab_name] = container as? DATabView
                    container.name = tab_name
                    
                case "scale9":
                    //actually a container in view-land
                    container = DAScale9View()
                case "paragraph":
                    print("ERROR: PARAGRAPH NOT SUPPORTED YET")
                    container = DAContainerView()
                default:
                    print("ERROR: UNRECOGNIZED CONTAINER TYPE: \(container_type)")
                    container = DAContainerView()
            }
        }
        
        //assign default container name if we didn't already assign a name
        if(container != nil && container.name == nil)
        {
            container.name = view["name"] as? NSString as? String
        }
        
        if let children = view["children"] as? NSArray as? [AnyObject]
        {
            let view_children = processChildren(children)
            for view_child in view_children
            {
                container!.addSubview(view_child)
            }
        }
        
        if let scale9 = container as? DAScale9View
        {
            for subview in scale9.subviews
            {
                if let dasub = subview as? DAView
                {
                    print("SUBVIEW CHILD: \(dasub.name)")
                }
            }
        }
        
        if let button = container as? DAButtonViewBase
        {
            button.updateDisplay()
        }
        
        if let tab = container as? DATabView
        {
            print("TODO: POST PROCESS TABS")
            tab.createStates()
        }
        
        if let size = view["size"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.resetSize = CGSize(width:size[0]*DAMetaView.scaleFactor, height:size[1]*DAMetaView.scaleFactor)
        }
        
        if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.resetPosition = processPosition(position)
        }
        
        
        if let pivot = view["pivot"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            container!.pivot = CGPoint(x: pivot[0]*DAMetaView.scaleFactor, y: pivot[1]*DAMetaView.scaleFactor)
        }
        
        container.cachedMetadata = view
        
        if let real_container = container as? DAContainerView
        {
            containers[container.name!] = real_container
        }
        
        return container
    }
    
    func postProcessScale9Views(view:DAView)
    {
        for child:AnyObject in view.subviews
        {
            if let scale9 = child as? DAScale9View
            {
                postProcessScale9View(scale9)
            }
            
            if let view_child = child as? DAView
            {
                postProcessScale9Views(view_child)
            }
            
        }
    }
    
    func postProcessScale9View(view:DAView)
    {
        var center:DAView!
        var sprite:DAImageView!
        var size:DAView!
        
        for view:AnyObject in view.subviews
        {
            if let daview = view as? DAView
            {
                switch(daview.name!)
                {
                    case "size":
                        size = daview
                    case "center":
                        center = daview
                    default:
                        //not size, not center, assume it's our image!
                        if let image = daview as? DAImageView
                        {
                            sprite = image
                            
                        }else{
                            fatalError("FOUND SOMETHING EXTRA IN A SCALE9 -- \(daview)")
                        }
                }
            }
        }
        
        let image_view = sprite.image
        

        //uiview uses actual pixel insets and not UV insets
        let center_inset = DAMetaView.getCenterInset(outerRect: sprite.frame, innerRect: center.frame)
        //let center_inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let cap_image = image_view.image!.resizableImageWithCapInsets(center_inset)
        image_view.image = cap_image
        
        sprite.frame = size.frame
//            sprite!.resetPosition = size!.origin
//            sprite!.resetSize = size!.size
        
//            sprite!.centerRect = DAMetaView.getCenterRect(outerRect:sprite!.frame, innerRect:center!)
//            sprite!.width = size!.width
//            sprite!.height = size!.height
//            
//            if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
//            {
//                sprite!.position = processPosition(position)
//            }
    }
    
    static func getCenterInset(outerRect outer:CGRect, innerRect inner:CGRect) -> UIEdgeInsets
    {
        //PIXEL INSETS USE REAL IMAGE PIXELS NOT POINTS
        let left = (inner.minX - outer.minX) / 1
        let bottom = (outer.maxY - inner.maxY)  / 1
        let right = (outer.maxX - inner.maxX)  / 1
        let top = (inner.minY - outer.minY)  / 1

        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func processTextView(view:Dictionary<String, AnyObject>) -> DALabelView
    {
        if let font = view["font"] as? NSString as? String
        {
            let label = DALabelView()
            
            let font_name = DAFont.getFont(font)
            var font_size:CGFloat = 14
            if let fs = view["fontSize"] as? NSNumber as? CGFloat
            {
                font_size = fs*DAMetaView.scaleFactor
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
                label.resetSize = CGSize(width:size[0]*DAMetaView.scaleFactor, height:size[1]*DAMetaView.scaleFactor)
            }

            if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                label.resetPosition = processPosition(position)
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
                    label.resetPosition = CGPoint(x: label.resetPosition.x + label.resetSize.width/2, y: label.resetPosition.y)
                }else if(align == "right"){
                    label.textAlignment = NSTextAlignment.Right
                    label.resetPosition = CGPoint(x: label.resetPosition.x - label.resetSize.width/2, y: label.resetPosition.y)
                }else{
                    print("[DAMetaView] -- INVALID LABEL ORIENTATION ON LABEL \(label.name) -- \(align)")
                }
            }
            
            labels[label.name!] = label
            return label
        }
        
        return DALabelView()
    }
    
    func processImageView(view:Dictionary<String, AnyObject>) -> DAView
    {
        if let image_name = view["name"] as? NSString as? String
        {
            let image = DAImageView(named: "\(assetFolder)/\(image_name)")
            
            image.name = image_name
            
            //image size is implicit -- not in the json
            image.resetSize = image.image.image!.size*DAMetaView.scaleFactor*image.image.image!.scale
            
            if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                image.resetPosition = processPosition(position)
            }
            
            let image_type = image_name.split("_")[0]
            
            if(image_type == "flipX")
            {
                image.image.transform = CGAffineTransformMakeScale(-1, 1)
            }
            
            //simple scale button!
            if(image_type == "scalebtn")
            {
                let container = DAScaleButtonView()
                
                let btn_name = image_name.replace("scalebtn_",withString:"")
                buttons[btn_name] = container
                container.name = btn_name
                
                container.resetPosition = image.resetPosition
                container.resetSize = image.resetSize
                
                image.resetPosition = CGPoint.zero
                container.addSubview(image)
                container.updateDisplay()

                return container
            }
            
            
            images[image_name] = image
            
            return image
        }
        
        return DAView()
    }
    
    //no return type here
    func processPlaceholder(view:Dictionary<String, AnyObject>) -> DAView?
    {
        if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            if let size = view["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                if let name = view["name"] as? NSString as? String
                {
                    
                    let view = DAView()
                    view.resetPosition = processPosition(position)
                    view.resetSize = CGSize(width: size[0]*DAMetaView.scaleFactor, height: size[1]*DAMetaView.scaleFactor)
                    view.name = name
                    
                    placeholders[name] = view
                    
                    if(name.rangeOfString("modal", options: [], range: nil, locale: nil) != nil)
                    {
                        print("TODO: ADD MODALS")
//                        let modal = SKSpriteView(color: "#230211".toColor(), size: placeholders[name]!.size)
//                        modal.alpha = 0.7
//                        modal.name = "modal"
//                        modal.position = placeholders[name]!.center
//                        return modal
                    }
                    
                    return view
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
    
    func printDisplayTree(view:DAView, currentDepth depth:Int)
    {
        let tab = Array<String>(count: depth, repeatedValue: "  ").joinWithSeparator("") + "->"
        let view_name = (view.name == nil ? view.description : view.name!)
        print("\(tab) \(view_name)     \(view.frame.center)")
        

        for child:AnyObject in view.subviews
        {
            if let view_child = child as? DAView
            {
                printDisplayTree(view_child, currentDepth: depth + 1)
            }
            
        }
    }
    
}