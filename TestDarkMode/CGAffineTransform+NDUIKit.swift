//
//  CGAffineTransform+NDUIKit.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/17.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

extension CGAffineTransform {
    
    static func pullScrollView(withContentOffset contentOffset: CGPoint, toScale view: UIView) -> CGAffineTransform {
        let posContentOffsetY = abs(contentOffset.y)
        let ratio = posContentOffsetY / view.bounds.size.height
        let scaleNumber = 1 + ratio
        let scale = CGAffineTransform(scaleX: scaleNumber, y: scaleNumber)
        let translate = CGAffineTransform(translationX: 0, y: -posContentOffsetY / 2)
        return translate.concatenating(scale)
    }
    
}
