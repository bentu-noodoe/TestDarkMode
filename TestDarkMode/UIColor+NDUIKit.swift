//
//  UIColor+NDUIKit.swift
//  Sunray
//
//  Created by 蘇柄臣 on 2016/4/22.
//  Copyright © 2016年 Noodoe. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hexString: String) {
        let validCharacterSet = CharacterSet(charactersIn: "#1234567890abcdefABCDEF")
        guard hexString.rangeOfCharacter(from: validCharacterSet.inverted) == nil else {
//            Logger.fault("Exist invalid character from color code(\(hexString))")
            return nil
        }
        
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
//            Logger.error("Invalid color code(\(hexString))")
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var rgb:Int = Int(round(a * 255)) << 24
        rgb |= Int(round(r * 255)) << 16
        rgb |= Int(round(g * 255)) << 8
        rgb |= Int(round(b * 255))
        return NSString(format:"#%08x", rgb) as String
    }
    
    func toHexStringWithoutAlpha() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var rgb:Int = Int(round(r * 255)) << 16
        rgb |= Int(round(g * 255)) << 8
        rgb |= Int(round(b * 255))
        
        return NSString(format:"#%06x", rgb) as String
    }

    var hue: CGFloat {
        get {
            return self.HSBA().0
        }
    }

    var saturation: CGFloat {
        get {
            return self.HSBA().1
        }
    }

    var brightness: CGFloat {
        get {
            return self.HSBA().2
        }
    }
    
    var alpha: CGFloat {
        get {
            return self.HSBA().3
        }
    }

    func HSBA() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0, b: CGFloat = 0, s: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
}
