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
    static var assetPath:String = "screens/"
    
    
    private var fileRoot:String
    private var rootContainer:String?

    //MOVED to superclass
//    var rootWidth:CGFloat = 0
//    var rootHeight:CGFloat = 0
    
    var placeholders    = [String:CGRect]()
    var containers      = [String:DAContainerView]()
    var tabs            = [String:DATabView]()
    var buttons         = [String:DAButtonViewBase]()
    var images          = [String:DAImageView]()
    var labels          = [String:DALabelView]()
     
    static func setup(_ device_tag:String, scaleFactor scale_factor:CGFloat)
    {
        DAMetaView.deviceTag = device_tag
        DAMetaView.scaleFactor = scale_factor
        
        
//        let available_fonts = UIFont.familyNames()
//        for(var i:Int = 0; i < available_fonts.count; i++)
//        {
//            let font_family = available_fonts[i]
//            let font_names = UIFont.fontNamesForFamilyName(font_family)
//            
//            print("\(font_family): \(font_names)")
//        }
    }
    
    // tuple of (String,bool) is for file_root and whether it's resolutionIndependent or not
    static func loadMetadata(_ file_root_list:[(String, Bool)])
    {
        let bundle = Bundle.main
        
        for (file_root, omit_device_tag) in file_root_list
        {
            var device_tag = DAMetaView.deviceTag
            if(omit_device_tag)
            {
                device_tag = ""
            }
            
            
            if let meta_url = bundle.url(forResource: "\(assetPath)\(file_root)\(device_tag)/\(file_root)\(device_tag)", withExtension: "txt")
            {
                print(meta_url)
                
                let metadata = try! String(contentsOf: meta_url, encoding: String.Encoding.utf8)
                
                let data = metadata.data(using: String.Encoding.utf8)!
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject>
                
                DAMetaView.LoadedMetadata[file_root] = json
            }else{
                print("ERROR ERROR ERROR -- \(assetPath)\(file_root)\(device_tag) NOT FOUND")
            }
        }
    }
    
    // tuple of (String,bool) is for file_root and whether it's resolutionIndependent or not
    static func preloadMetadataAsynch(_ file_root_list:[(String, Bool)])
    {
        for (file_root, omit_device_tag) in file_root_list
        {
            let closure_file = file_root
            let closure_omit = omit_device_tag
            
            DispatchQueue.main.async {
                DAMetaView.loadMetadata([(closure_file, closure_omit)])
            }
            
        }
    }
    
    override init()
    {
        fileRoot = ""
        rootContainer = ""
        super.init()
    }
    
    init(from_view:DAView)
    {
        fileRoot = ""
        rootContainer = from_view.name!
        
        super.init()
        
        assetFolder =  from_view.assetFolder        
        
        rootWidth = from_view.frame.size.width
        rootHeight = from_view.frame.size.height
        
        let container = processContainerView(from_view.cachedMetadata)
        
        resetSize = container.resetSize
        resetPosition = CGPoint.zero //CGPoint(x: rootWidth/2, y: rootHeight/2)
        pivot = container.pivot
        
        for view in container.subviews
        {
            view.removeFromSuperview()
            addSubview(view)
        }
        
        reset(recursive: true)
        center = CGPoint(x:rootWidth/2, y:rootHeight/2)
    }
    
    
    init(file_root:String, fromContainer container_name:String?, resolutionIndependent omit_device_tag:Bool)
    {
        fileRoot = file_root
        rootContainer = container_name
        
        var device_tag = DAMetaView.deviceTag
        if(omit_device_tag)
        {
            device_tag = ""
        }
        
        super.init(frame:CGRect.zero)
        
        assetFolder = "\(DAMetaView.assetPath)\(file_root)\(device_tag)"
        
        name = file_root
        
        if(file_root == "")
        {
            return
        }
        
        if(DAMetaView.LoadedMetadata.index(forKey: file_root) != nil)
        {
            processMetadata(DAMetaView.LoadedMetadata[file_root]!)
        }else{
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
        reset(recursive: true)
        
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
    func container(withName container_name:String) -> DAContainerView?
    {
        if(container_name.split("_").first! == "container")
        {
            print("[ERROR] containerWithName provides the container_, you may omit it from your call!")
        }
        
        
        return containers["container_\(container_name)"]
    }
    
    func tab(withName tab_name:String) -> DATabView?
    {
        if(tab_name.split("_").first! == "tab")
        {
            print("[ERROR] tabWithName provides the tab_, you may omit it from your call!")
        }
        
        return tabs[tab_name]
    }
    
    //simplest of the getters, doesn't prefix anything
    func image(withName image_name:String) -> DAImageView?
    {
        return images[image_name]
    }
    
    func label(withName label_name:String) -> DALabelView?
    {
        if(label_name.split("_").first! == "txt")
        {
            print("[ERROR] labelWithName omits the txt_, you may omit it from your call!")
        }
        
        return labels[label_name]
    }
    
    //buttons keep a name hash around because they can come from a scalebtn image, a scalebtn container, or a btn
    func button(withName button_name:String) -> DAButtonViewBase?
    {
        if(button_name.split("_").first! == "btn")
        {
            print("[ERROR] buttonWithName omits the btn_, you may omit it from your call!")
        }
        
        return buttons[button_name]
    }
    
    func placeholder(withName placeholder_name:String) -> CGRect?
    {
        if(placeholder_name.split("_").first! == "placeholder")
        {
            print("[ERROR] placeholderWithName provides the placeholder_, you may omit it from your call!")
        }
        
        return placeholders[placeholder_name]
    }
    
    let DEBUG = false
    func processMetadata(_ json:Dictionary<String,AnyObject>)
    {
//        print("PROCESS METADATA")
        
        if let platform = json["coordinate_system"] as? NSString as? String
        {
            if(platform != "native_ui")
            {
                fatalError("OOOPS YOU DIDN'T EXPORT FOR NATIVE UI")
            }
        }else{
            fatalError("OOOPS YOU'RE PROBABLY USING AN OLD EXPORTER. MISSING coordinate_system KEY")
        }
        
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
    func processChildren(_ children:[AnyObject]) -> [DAView]
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
    
    func processPosition(_ coords:[CGFloat]) -> CGPoint
    {
        var x = coords[0]
        var y = coords[1]

        //apply the scale factor
        x = x * DAMetaView.scaleFactor
        y = y * DAMetaView.scaleFactor
        
        return CGPoint(x:x, y:y)
    }
    
    func processContainerView(_ view:Dictionary<String, AnyObject>) -> DAView
    {
        var container:DAView!
        
        if let container_name:String = view["name"] as? NSString as? String
        {
            
            let container_type:String = container_name.split("_")[0]
            
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
                    //shhhh, not actually a container
                    return processScale9View(view)
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
    
    func processScale9View(_ node:Dictionary<String, AnyObject>, useTextureCache use_texture_cache:Bool=false) -> DAImageView
    {
        var center:CGRect!
        var image:DAImageView!
        var size:CGRect!
        
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
                            image = processImageView(node) as! DAImageView
                        case "placeholder":
                            processPlaceholder(node)
                            
                            if let name = node["name"] as? NSString as? String
                            {
                                if(name == "size")
                                {
                                    size = placeholder(withName:name)!
                                }else if(name == "center"){
                                    center = placeholder(withName:name)!
                                }else{
                                    print("EXTRA SCALE9 PLACEHOLDER: \(name)")
                                }
                                
                            }
                        default:
                            fatalError("SCALE9 containers can only contain a single image and two placeholders")
                    }
                }
            }
        }
        
        //set our initial frame so our center inset isn't all screwy
        image.reset()
        
        //get the uiimageview
        let image_view = image.image
        let center_inset = DAMetaView.getCenterInset(outerRect: image.frame, innerRect: center)
        
        let cap_image = image_view.image!.resizableImage(withCapInsets: center_inset)
        image_view.image = cap_image
        
        image.frame = size
        image.resetPosition = size.origin
        image.resetSize = size.size
        
        return image
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
    
    func processTextView(_ view:Dictionary<String, AnyObject>) -> DALabelView
    {
        if let font = view["font"] as? NSString as? String
        {
            let label = DALabelView()
            
            let font_name = DAFont.get(font)
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
            
            if let alpha = view["alpha"] as? NSNumber as? CGFloat
            {
                if(alpha < 1.0)
                {
                    label.isOpaque = false
                    label.alpha = alpha
                }
            }
            
            if let align = view["justification"] as? NSString as? String
            {
                if(align == "center")
                {
                    label.textAlignment = NSTextAlignment.center
                }else if(align == "left"){
                    label.textAlignment = NSTextAlignment.left
                    label.resetPosition = CGPoint(x: label.resetPosition.x + label.resetSize.width/2, y: label.resetPosition.y)
                }else if(align == "right"){
                    label.textAlignment = NSTextAlignment.right
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
    
    static func imageNamed(fileRoot:String, name:String) -> UIImage
    {
        let path = "\(DAMetaView.assetPath)\(fileRoot)\(deviceTag)/\(name)"
        return UIImage(named: path)!
    }
    
    func processImageView(_ view:Dictionary<String, AnyObject>) -> DAView
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
                image.image.transform = CGAffineTransform(scaleX: -1, y: 1)
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
    @discardableResult func processPlaceholder(_ view:Dictionary<String, AnyObject>) -> DAView?
    {
        if let position = view["position"] as? NSArray as? [NSNumber] as? [CGFloat]
        {
            if let size = view["size"] as? NSArray as? [NSNumber] as? [CGFloat]
            {
                if let name = view["name"] as? NSString as? String
                {
                    placeholders[name] = CGRect(x: position[0]*DAMetaView.scaleFactor, y: position[1]*DAMetaView.scaleFactor, width: size[0]*DAMetaView.scaleFactor, height: size[1]*DAMetaView.scaleFactor)
                    
                    if(name.indexOf("modal") >= 0)
                    {
                        let modal = DAView(frame: placeholders[name]!)
                        modal.isOpaque = false
                        modal.alpha = 0.7
                        modal.name = "modal"
                        modal.backgroundColor = "#230211".toUIColor()
                        
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
    
    func printDisplayTree(_ view:DAView, currentDepth depth:Int)
    {
        let tab = Array<String>(repeating: "  ", count: depth).joined(separator:"") + "->"
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
