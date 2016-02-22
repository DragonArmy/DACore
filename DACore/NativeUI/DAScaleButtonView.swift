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
            transform = CGAffineTransformMakeScale(DAScaleButton.DOWN_SCALE,DAScaleButton.DOWN_SCALE)
        }else{
            transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
}
