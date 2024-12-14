//
//  Double+Ext.swift
//  gramejia
//
//  Created by Adam on 14/12/24.
//

import Foundation

extension Double {
    func toRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "id_ID")
        guard let formattedString = formatter.string(from: NSNumber(value: self)) else {
            return "Rp0"
        }
        return formattedString + ",-"
    }
}
