//
//  UIColorExtension.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/9.
//

import UIKit

extension UIColor {
    
    var r: CGFloat {
        var red: CGFloat = 0
        self.getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    
    var g: CGFloat {
        var green: CGFloat = 0
        self.getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    
    var b: CGFloat {
        var blue: CGFloat = 0
        self.getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
    
    var a: CGFloat {
        return cgColor.alpha
    }
    
    static func interpolate(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        let red = from.r + (to.r - from.r) * progress
        let green = from.g + (to.g - from.g) * progress
        let blue = from.b + (to.b - from.b) * progress
        let alpha = from.a + (to.a - from.a) * progress
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
