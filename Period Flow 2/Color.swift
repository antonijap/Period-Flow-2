//
//  Color.swift
//  Period Flow 2
//
//  Created by Antonija on 11/06/2017.
//  Copyright © 2017 Antonija Pek. All rights reserved.
//

import Foundation
import UIKit


enum Color {
    static let primary = UIColor.rgb(red: 85, green: 80, blue: 227, alpha: 1.0)
    static let accent = UIColor.rgb(red: 255, green: 254, blue: 179, alpha: 1.0)
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
