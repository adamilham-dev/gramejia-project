//
//  Date+Ext.swift
//  gramejia
//
//  Created by Adam on 08/12/24.
//

import UIKit

extension Date {
    func formatToString(style: DateFormatter.Style = .long) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        
        return dateFormatter.string(from: self)
    }
}
