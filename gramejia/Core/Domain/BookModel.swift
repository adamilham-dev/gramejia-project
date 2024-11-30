//
//  BookModel.swift
//  gramejia
//
//  Created by Rivaldo Fernandes on 30/11/24.
//

import Foundation

struct BookModel: Identifiable {
    let id: String
    let author: String
    let coverImage: String?
    let price: Double
    let publishedDate: String
    let publisher: String
    let stock: Int64
    let synopsis: String
    let title: String
    let updatedDate: String
}
