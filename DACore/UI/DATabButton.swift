//
//  DAStateButton.swift
//  testing
//
//  Created by Will Hankinson on 3/19/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import SpriteKit

class DATabButton : DAContainerBase
{
    let stateWillChange = Signal<DATabButton>()
    let stateDidChange = Signal<DATabButton>()
    
    var states = Set<String>()
    var content:[SKNode] = []
    
    var cycle:[String] = []
    
    var allLinkedNodes = Set<SKNode>()
    var linkedNodes = [String:Set<SKNode>]()

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
            //we're resetting the current state to refresh linked display nodes... so do it every time
            //just to be safe
            _currentState = value
            
            for node in allLinkedNodes
            {
                node.hidden = true
            }
            
            if let linked_nodes = linkedNodes[value]
            {
                for node in linked_nodes
                {
                    node.hidden = false
                }
            }
            
            //ok, so it appears that invisible nodes block touches! just setting the non-active pieces to hidden=true and userInteractionEnabled=false makes it a dead button
            //so instead we keep a copy of our children and add only those that are active
            removeAllChildren()
            for node in content
            {
                if let state = node.name?.split("_").last
                {
                    if(state == value)
                    {
                        addChild(node)
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
    
    func linkNode(node:SKNode, toState state:String)
    {
        allLinkedNodes.insert(node)
        
        if let current_nodes = linkedNodes[state]
        {
            linkedNodes[state]!.insert(node)
        }else{
            linkedNodes[state] = Set<SKNode>()
            linkedNodes[state]!.insert(node)
        }
        
        self.currentState = _currentState
    }
    
    func unlinkNode(node:SKNode, fromState state:String)
    {
        if var current_nodes = linkedNodes[state]
        {
            current_nodes.remove(node)
        }
        
        var got_one = false
        for(key, node_set) in linkedNodes
        {
            if node_set.contains(node)
            {
                got_one = true
            }
        }
        
        //if no one is linked to me, remove me!
        if !got_one
        {
            allLinkedNodes.remove(node)
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
        if let index = find(cycle, currentState)
        {
            let next_index = (index + 1) % cycle.count
            return cycle[next_index]
        }else{
            return currentState
        }
    }
    
    func handleButtonClick(button:DAButtonBase)
    {
        var next_state = nextStateInCycle
        if(_currentState != next_state)
        {
            stateWillChange.fire(self)
            
            currentState = next_state
            
            stateDidChange.fire(self)
        }
    }
    
    func createStates()
    {
        var any_state:String = ""
        
        for any_node in children
        {
            if let button = any_node as? DAButtonBase
            {
                button.onButtonClick.listen(self, callback:handleButtonClick)
            }
            
            if let node = any_node as? SKNode
            {
                if let state = node.name?.split("_").last
                {
                    states.insert(state)
                    if(any_state == "")
                    {
                        any_state = state
                    }
                }
                
                content.append(node)
            }
        }
        
        if(any_state == "")
        {
            println("[ERROR] cannont have a Tab with no states!")
        }
        
        //println("SETTING INITIAL STATE: " + any_state)
        currentState = any_state
    }
}
