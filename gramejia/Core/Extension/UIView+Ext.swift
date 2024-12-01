//
//  UIView+Ext.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit

extension UIView {
    func addBorder(borderWidth: CGFloat, borderColor: UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    func setCorner(cornerRadius: CGFloat, clipToBounds: Bool = true, maskToBounds: Bool = true) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = clipToBounds
        self.clipsToBounds = maskToBounds
    }
    
    func setCorner(cornerRadius: CGFloat, corners: UIRectCorner, clipToBounds: Bool = true, maskToBounds: Bool = true) {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.cornerRadius = cornerRadius
        var cornerMask: CACornerMask = []
            
        if corners.contains(.topLeft) {
            cornerMask.insert(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            cornerMask.insert(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            cornerMask.insert(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            cornerMask.insert(.layerMaxXMaxYCorner)
        }
        self.layer.maskedCorners = cornerMask
    }
    
}
