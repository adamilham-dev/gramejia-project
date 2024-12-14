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
    
    func formatISODate(to format: String = "E, dd MMM yyyy") -> String? {
            let isoFormatter = ISO8601DateFormatter()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.locale = Locale(identifier: "en_US")
            
            guard let date = isoFormatter.date(from: self) else {
                return nil
            }
            
            return dateFormatter.string(from: date)
        }
}
