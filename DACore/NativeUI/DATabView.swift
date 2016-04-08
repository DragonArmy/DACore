//
//  DAUITabView.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

//most contaienr types are DAUIContainerBase children, whereas a DAUIContainer is explicitly a container
//and holds subviews but no content of its own
class DATabView : DAView
{
    let stateWillChange = Signal<DATabView>()
    let stateDidChange = Signal<DATabView>()
    let signalTabClicked = Signal<DATabView>()
    
    var states = Set<String>()
    var content:[DAView] = [] //a cache of all our starting children
    
    var cycle:[String] = []
    
    var allLinkedViews = Set<UIView>()
    var linkedViews = [String:Set<UIView>]()
    
    private var _currentState:String = ""
    var currentState:String
    {
        get
        {
            return _currentState
        }
        set(value)
        {
            //could bail out here if we're setting it to our current value, but there's a chance
            //we're resetting the current state to refresh linked dDAisplay nodes... so do it every time
            //just to be safe
            _currentState = value
            
            for view in allLinkedViews
            {
                view.hidden = true
            }
            
            if let linked_views = linkedViews[value]
            {
                for view in linked_views
                {
                    view.hidden = false
                }
            }
            
            //ok, so it appears that invisible nodes block touches! just setting the non-active pieces to hidden=true and userInteractionEnabled=false makes it a dead button
            //so instead we keep a copy of our children and add only those that are active
            for view in content
            {
                if(view.superview != nil)
                {
                    view.removeFromSuperview()
                }
                
                if let state = view.name?.split("_").last
                {
                    if(state == value)
                    {
                        addSubview(view)
                    }
                }
            }
        }
    }
    
    override init()
    {
        super.init()
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    //we need all our tab contents to reset, not just the currently selected one
    override func reset(recursive:Bool=true)
    {
        for view in content
        {
            if(view.superview == nil)
            {
                addSubview(view)
            }
        }
        
        super.reset(recursive)
        self.currentState = _currentState
    }
    
    
    func linkView(view:UIView, toState state:String)
    {
        allLinkedViews.insert(view)
        
        if(linkedViews[state] != nil)
        {
            linkedViews[state]!.insert(view)
        }else{
            linkedViews[state] = Set<DAView>()
            linkedViews[state]!.insert(view)
        }
        
        self.currentState = _currentState
    }
    
    func unlinkView(view:UIView, fromState state:String)
    {
        //remove the linked node from the requested state
        if var current_views = linkedViews[state]
        {
            current_views.remove(view)
        }
        
        //see if any other states are using that node
        var got_one = false
        for view_set in linkedViews.values
        {
            if view_set.contains(view)
            {
                got_one = true
            }
        }
        
        //if no one is linked to me, remove me!
        if !got_one
        {
            allLinkedViews.remove(view)
        }
    }
    
    //if we don't have a cycle set up, just return the current state!
    var nextStateInCycle:String
    {
        if(cycle.isEmpty)
        {
            return currentState
        }
        
        //if we're not in the cycle (i.e. locked), stay where we are
        if let index = cycle.indexOf(currentState)
        {
            let next_index = (index + 1) % cycle.count
            return cycle[next_index]
        }else{
            return currentState
        }
    }
    
    func handleButtonClick(button:DAButtonViewBase)
    {
        let next_state = nextStateInCycle
        if(_currentState == next_state)
        {
            signalTabClicked.fire(self)
        }else{
            stateWillChange.fire(self)
            
            currentState = next_state
            reset(true)
            
            stateDidChange.fire(self)
        }
    }
    
    func createStates()
    {
        var any_state:String = ""
        
        for ui_view in subviews
        {
            if let view = ui_view as? DAView
            {
                if let button = view as? DAButtonViewBase
                {
                    button.onButtonClick.listen(self, callback:handleButtonClick)
                }
                
                if let state = view.name?.split("_").last
                {
                    states.insert(state)
                    if(any_state == "")
                    {
                        any_state = state
                    }
                }
                
                content.append(view)
            }
        }
        
        if(any_state == "")
        {
            print("[ERROR] cannont have a Tab with no states!")
        }
        
        //print("SETTING INITIAL STATE: " + any_state)
        currentState = any_state
    }
}