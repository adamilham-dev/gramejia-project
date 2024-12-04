//
//  UIFont+Ext.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit

extension UIFont {
    public static func nunitoBlack(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Black", size: size)
    }
    
    public static func nunitoBlackItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-BlackItalic", size: size)
    }
    
    public static func nunitoBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Bold", size: size)
    }
    
    public static func nunitoBoldItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-BoldItalic", size: size)
    }
    
    public static func nunitoExtraBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-ExtraBold", size: size)
    }
    
    public static func nunitoExtraBoldItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-ExtraBoldItalic", size: size)
    }
    
    public static func nunitoExtraLight(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-ExtraLight", size: size)
    }
    
    public static func nunitoExtraLightItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-ExtraLightItalic", size: size)
    }
    
    public static func nunitoItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Italic", size: size)
    }
    
    public static func nunitoLight(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Light", size: size)
    }
    
    public static func nunitoLightItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-LightItalic", size: size)
    }
    
    public static func nunitoMedium(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Medium", size: size)
    }
    
    public static func nunitoMediumItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-MediumItalic", size: size)
    }
    
    public static func nunitoRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Regular", size: size)
    }
    
    public static func nunitoSemiBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-SemiBold", size: size)
    }
    
    public static func nunitoSemiBoldItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-SemiBoldItalic", size: size)
    }
    
    static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {

        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            fatalError("Couldn't find font \(fontName)")
        }

        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }

        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            return false
        }

        return true
    }
}
