//
//  UINavigationBarAppearance+Functional.swift
//  TestDarkMode
//
//  Created by ZhengXun Tu on 2019/8/6.
//  Copyright © 2019 Noodoe. All rights reserved.
//

import UIKit

extension UINavigationBarAppearance {

    func setBackgroundColor(_ color: UIColor?) -> Self {
        backgroundColor = color        
        return self
    }

    func setTransparentBackground() -> Self {
        configureWithTransparentBackground()
        return self
    }

    func setOpaqueBackground() -> Self {
        configureWithOpaqueBackground()
        return self
    }

    func setDefaultBackground() -> Self {
        configureWithDefaultBackground()
        return self
    }

    //NOT TESTED
    func setTranslucent(_ val: Bool) -> Self {
        if val {
            backgroundImage = UIImage()
            shadowImage = UIImage()
        } else {
            backgroundImage = nil
            shadowImage = nil
        }
        return self
    }

}
