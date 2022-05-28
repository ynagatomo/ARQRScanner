//
//  UIColor+extensions.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/28.
//

import UIKit

extension UIColor {
    static func randomColor(saturation: CGFloat = 0.8, brightness: CGFloat = 0.8, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hue: CGFloat.random(in: 0.0...1.0),
                       saturation: saturation,
                       brightness: brightness,
                       alpha: alpha)
    }
}
