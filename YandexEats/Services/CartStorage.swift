//
//  CartStorage.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import Foundation

/// хранилище айтемов, специально помечано Actor, т.к. преназанчено только для экторов, для решения состояния гонки
protocol CartItmesStorage: Actor {
    var items: [CartItem] { get }
    
    func deleteAllCartItems()
    func updateCartItem(item: CartItem) throws
    func updateCartItem(items: [CartItem]) throws
}

final actor CartItemsStorageMock: CartItmesStorage {
    
    private init() {
        self.items = [
            .init(id: UUID().uuidString, name: "Лимон", count: 4, price: 50, currency: "₽", imageUrl: "1"),
            .init(id: UUID().uuidString, name: "Огурец", count: 14, price: 20, currency: "₽", imageUrl: "2")
        ]
    }
    
//    MARK: - Properties
    static let shared = CartItemsStorageMock()
    var items = [CartItem]()
    
//    MARK: - Editing Funcs
/// удаляет все айтемы
    func deleteAllCartItems() {
        self.items = .init()
    }
    
///находит и безопасно обновляет айтем
    func updateCartItem(item: CartItem) throws {
        guard let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }
        if item.count == .zero {
            self.items.remove(at: index)
        } else {
            self.items[index] = item
        }
    }
    /// находит и безопасно обновляет все айтемы
    func updateCartItem(items: [CartItem]) throws {
        var errorIDs = [String]()
        
        for item in items {
            guard let index = self.items.firstIndex(where: { $0.id == item.id }) else {
                errorIDs.append(item.id)
                continue
            }
            
            self.items[index] = item
        }
        
        self.items = self.items.filter { $0.count != .zero }
        
        if !errorIDs.isEmpty { throw CartManagerError.notFoundItems(withIDs: errorIDs) }
    }
    
}
