//
//  MultilineButton.swift
//  EasyReader
//
//  Created by Gorelov Oleg on 10/05/17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import UIKit

//@IBDesignable
class MultilineButton:UIButton {
    
    //MARK: - Setup
    func setup () {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center

        self.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, for: .vertical)
        self.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, for: .horizontal)
    }
    
    //MARK: - Method overrides
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        return self.titleLabel!.intrinsicContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}
