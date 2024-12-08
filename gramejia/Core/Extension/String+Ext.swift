//
//  String+Ext.swift
//  gramejia
//
//  Created by Adam on 08/12/24.
//

import UIKit

extension String {
    func formatToDate(style: DateFormatter.Style = .long) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        
        return dateFormatter.date(from: self)
    }
    
    func formatToDateISO8601(style: DateFormatter.Style = .long) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        
        return dateFormatter.date(from: self)?.ISO8601Format()
    }
    
    func formatISO8601ToDate() -> Date? {
        let isoFormatter = ISO8601DateFormatter()

        return isoFormatter.date(from: self)
    }
}
