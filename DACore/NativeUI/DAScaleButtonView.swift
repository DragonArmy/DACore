//
//  DAScaleButtonView.swift
//  catchsports
//
//  Created by Will Hankinson on 2/22/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DAScaleButtonView : DAButtonViewBase
{
    static var DOWN_SCALE:CGFloat = 0.85
    
    override func updateDisplay()
    {
        if(_isButtonDown)
        {
            transform = CGAffineTransform(scaleX: DAScaleButton.DOWN_SCALE,y: DAScaleButton.DOWN_SCALE)
        }else{
            transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
}
