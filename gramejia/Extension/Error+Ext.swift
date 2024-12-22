//
//  Error+Ext.swift
//  gramejia
//
//  Created by Adam on 29/11/24.
//

import Foundation

enum DatabaseError: LocalizedError {
    case dataNotFound
    case invalidDatabase
    case dataAlreadyExist
}


enum CustomError: LocalizedError {
    case wrongCredential
}

