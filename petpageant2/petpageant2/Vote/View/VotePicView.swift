//
//  VotePicView.swift
//  petpageant2
//
//  Created by Michael Sweeney on 1/4/19.
//  Copyright © 2019 Novasoft. All rights reserved.
//

import UIKit

class VotePicView: UIView {
    
    let kCONTENT_XIB_NAME = "VotePicView"
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        contentView.backgroundColor = UIColor.blue
    }
}
