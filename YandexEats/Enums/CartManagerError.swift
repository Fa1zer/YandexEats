//
//  CartManagerError.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import Foundation

/// ошибки менеджера корзины
enum CartManagerError: Error {
    case cartIsAlreadyEmpty
    case notFoundItem(withID: String)
    case notFoundItems(withIDs: [String])
}
