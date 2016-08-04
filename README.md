# DACore
Core UI Framework built on top of Photoshop-based UI export pipeline, used for native/spritekit iOS apps.

DA Export
----------------------
This framework makes use of an Adobe Generator (Photoshop plugin) and essentially replaces XCode's Interface Builder with Photoshop. By using a fairly simple naming convention for layers in PS, the plugin is able to export all metadata needed for creating a view that looks identical to that document in either SpriteKit or native UIViews.

Supported Features
----------------------
* **/UI** -- SpriteKit-based UI framework
	* DAMetaNode - responsible for parsing metadata and creating scene graphs
	* DAButton - a button with distinct up/down states
	* DAScaleButton - a button with a single state that scales down on press
	* DAProgressBar - helper for making progress bars
	* DAScroller - a node to simulate ios-style "springy" scrolling views
	* DATabButton - a control for showing/hiding content (often used for toggles but can also be used to show/hide entire hierarchies of content)
* **/NativeUI** -- Native UIView-based UI framework, with 
	* DAMetaView - responsible for parsing metadata and creating scene graphs
	* DAButtonView - a button with distinct up/down states
	* DAScaleButtonView - a button with a single state that scales down on press
	* DAImageView - responsible for layout of an image within a view (pivots, etc)
	* DALabelView - responsible for layout of a text field with pivots, etc
	* DAScale9View (kinda janky) - attempts to create a scale9 image
	* DATabView - a control for showing/hiding content based on state
* **/animation** -- Flump parser written in Swift, which converts keyframe data to SKActions (currently SpriteKit only, but no reason a FlumpView couldn't duplicate FlumpNode for DAMetaView isntead of DAMetaNode)
	* Flump - actual parser with structs for things like layers and keyframes
	* FlumpNode - equivalent of a Flash MovieClip - displays a flump animation in the scene graph and contains animation controls

Launched Projects
----------------------
* [Little Broken Robots (iOS + SpriteKit)](https://itunes.apple.com/us/app/little-broken-robots/id977183254?mt=8)
* more coming soon! 

TODOs
----------------------
* remove Extensions.swift and rewrite code to not lean on lazy language hacks  
* move BaseModel to its own repo or document it here
* move DASoundManager to its own repo or document it here
* make it a framework/pod once the code settles and Swift3 is stable
* update to latest Signals and link it as a proper dependency


Third Party Code
----------------------
* Signals: https://github.com/artman/Signals
* Flump: https://github.com/tconkling/flump  (not using any flump code, but need the exporter to make use of my flump code)
