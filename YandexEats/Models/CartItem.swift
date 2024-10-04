//
//  CartItem.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 02.09.2024.
//

import Foundation

/// моделб айтема корзины
struct CartItem {
    let id: String
    let name: String
    let count: Int
    let price: Int
    let currency: String
    let imageUrl: String
}
