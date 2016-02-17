//
//  DAUIImage.swift
//  catchsports
//
//  Created by Will Hankinson on 2/16/16.
//  Copyright © 2016 Dragon Army. All rights reserved.
//

import UIKit

class DAUIImageView : DAUIView
{
    var image = UIImageView()
    
    override init()
    {
        super.init()
    }
    
    init(named:String)
    {
        image = UIImageView(image: UIImage(named: named))
        super.init(frame: CGRect(origin: CGPoint.zero, size: image.image!.size))
        addSubview(image)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
