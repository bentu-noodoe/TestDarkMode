//
//  String+Localized.swift
//  TestDarkMode
//
//  Created by ZhengXun Tu on 2019/8/6.
//  Copyright © 2019 Noodoe. All rights reserved.
//

import UIKit

extension String {

    static func localizedString(_ str: String) -> String {
        return str
    }

    func rect(withLimitedHeight height: CGFloat, andFont font: UIFont) -> CGRect {
        let context = NSStringDrawingContext()
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        return self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: context)
    }

    func rect(withLimitedWidth width: CGFloat, andFont font: UIFont) -> CGRect {
        let context = NSStringDrawingContext()
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: context)
    }

    func numberOfLines(fromWidth width: CGFloat, andFont font: UIFont) -> Int {
        let totalheight = rect(withLimitedWidth: width, andFont: font).height
        return Int(totalheight / font.lineHeight)
    }

}
