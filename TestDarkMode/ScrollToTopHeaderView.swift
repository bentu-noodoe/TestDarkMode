//
//  ScrollToTopHeaderView.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/11.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

class ScrollToTopHeaderView: UIView, NibOwnerLoadable {

    var scrollToTopClosure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func configure(_ scrollToTopClosure: (() -> Void)?) {
        self.scrollToTopClosure = scrollToTopClosure
    }

    @IBAction func scrollToTopButtonPressed(_ sender: Any) {
        scrollToTopClosure?()
    }
    
}
