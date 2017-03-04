//
//  Extensions.swift
//  UPC
//
//  Created by Никита Римский on 04.03.17.
//  Copyright © 2017 Никита Римский. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}

struct Colours {
    static let red = UIColor(hex: "FC4E84")
    static let green = UIColor(hex: "65F2BB")
    static let yellow = UIColor(hex: "F9E970")
}
