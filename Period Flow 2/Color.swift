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
    static let primary = UIColor.rgb(red: 255, green: 60, blue: 121, alpha: 1.0)
    static let accent = UIColor.rgb(red: 30, green: 28, blue: 95, alpha: 1.0)
    static let blackWithOpacity = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: 0.2)
    static let whiteWithOpacity = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0.3)

}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
