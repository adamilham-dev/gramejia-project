//
//  CustomFontUtil.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit


public enum CustomFontUtil {
    public static func registerCustomFont() {
        let fontNunito = [
            "Nunito-Black",
            "Nunito-BlackItalic",
            "Nunito-Bold",
            "Nunito-BoldItalic",
            "Nunito-ExtraBold",
            "Nunito-ExtraBoldItalic",
            "Nunito-ExtraLight",
            "Nunito-ExtraLightItalic",
            "Nunito-Italic",
            "Nunito-Light",
            "Nunito-LightItalic",
            "Nunito-Medium",
            "Nunito-MediumItalic",
            "Nunito-Regular",
            "Nunito-SemiBold",
            "Nunito-SemiBoldItalic"
        ]
        
        for font in fontNunito {
            _ = UIFont.registerFont(bundle: .main, fontName: font, fontExtension: "ttf")
        }
    }
}
