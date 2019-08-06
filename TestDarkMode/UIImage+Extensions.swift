//
//  UIImage+Extensions.swift
//  TestDarkMode
//
//  Created by ZhengXun Tu on 2019/8/6.
//  Copyright © 2019 Noodoe. All rights reserved.
//

import UIKit

extension UIImage {

    class func image(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }

}
