//
//  TestViewController.swift
//  catchsports
//
//  Created by Will Hankinson on 2/17/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


class TestViewController : UIViewController
{
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.blueColor()
        
        testPipelineTemplate()
//        testSimpleTemplate()
    }
    
    
    
    var selectedIndex = 0
    var test:DAMetaView!
    func testPipelineTemplate()
    {
        test = DAMetaView(file_root: "ui_pipeline_template")!
        view.addSubview(test)
        
        test.containerWithName("size_test")!.removeFromSuperview()
        test.printDisplayTree()
        
        if let label = test.labelWithName("top")
        {
            label.reset()
            label.text = "THIS IS A LONGER LEFT JUSTIFIED TF"
            label.sizeToFit()
        }
        
        if let label = test.labelWithName("bottom")
        {
            label.reset()
            label.text = "THIS IS A LONGER RIGHT JUSTIFIED TF"
            label.sizeToFit()
        }
        
        for button in test.buttons.values
        {
            button.onButtonClick.listen(self, callback:handleTemplateButton)
        }
        
        test.tabWithName("square")!.cycle = ["on","off"]
    }
    
    func handleTemplateButton(button:DAButtonViewBase)
    {
        let name = button.name!
        switch(name)
        {
            case "moveUp":
                selectedIndex = (selectedIndex + 1) % 3
                let ph = test.placeholderWithName(["first","second","third"][selectedIndex])!
                print(ph)
                test.imageWithName("smartFrame")!.frame = ph
            
            case "moveDown":
                selectedIndex -= 1
                if(selectedIndex < 0)
                {
                    selectedIndex += 3
                }
                let ph = test.placeholderWithName(["first","second","third"][selectedIndex])!
                print(ph)
                test.imageWithName("smartFrame")!.frame = ph
            
            
            
            default:
                print("NO LOGIC YET FOR \(name)")
        }
    }
    
    
    func testSimpleTemplate()
    {
        let test = DAMetaView(file_root: "simple_template")!
        test.printDisplayTree()
        view.addSubview(test)
        

        print(test.labelWithName("header")!)
        print(test.labelWithName("header")!.text)
        
        
        let rotator = test.containerWithName("rotator")!
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI*2)
        rotateAnimation.duration = 4
        rotateAnimation.repeatCount = 10000
        rotator.layer.addAnimation(rotateAnimation, forKey: nil)
        
        
        let rotator2 = test.containerWithName("inner_rotator")!
        rotator2.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
 
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
   
}